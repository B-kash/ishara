import { readFileSync } from "node:fs";
import { join } from "node:path";
import { createPool, repositoryRoot } from "./db-utils.mjs";

const defaultImportPath = join(repositoryRoot, "data", "mock-signs.json");

const requiredFields = [
  "id",
  "conceptId",
  "englishWord",
  "nepaliWord",
  "meaningEnglish",
  "meaningNepali",
  "category",
];

function categoryNameToId(categoryName) {
  return categoryName
    .toLowerCase()
    .replace(/ & /g, "-")
    .replace(/\s+/g, "-");
}

function parseImportPathFromArgs() {
  const customPath = process.argv[2];
  if (!customPath) {
    return defaultImportPath;
  }

  return join(repositoryRoot, customPath);
}

function loadSignRecords(importPath) {
  const fileContents = readFileSync(importPath, "utf8");
  const parsed = JSON.parse(fileContents);

  if (!Array.isArray(parsed)) {
    throw new Error("Import file must be a JSON array of sign records.");
  }

  return parsed;
}

function validateSignRecord(signRecord, recordIndex) {
  const recordLabel = `Record ${recordIndex + 1}`;

  if (!signRecord || typeof signRecord !== "object") {
    throw new Error(`${recordLabel}: must be an object.`);
  }

  for (const fieldName of requiredFields) {
    const fieldValue = signRecord[fieldName];
    if (typeof fieldValue !== "string" || !fieldValue.trim()) {
      throw new Error(`${recordLabel}: "${fieldName}" is required.`);
    }
  }

  if (signRecord.videoUrl != null && typeof signRecord.videoUrl !== "string") {
    throw new Error(`${recordLabel}: "videoUrl" must be a string or null.`);
  }

  if (
    signRecord.thumbnailUrl != null &&
    typeof signRecord.thumbnailUrl !== "string"
  ) {
    throw new Error(`${recordLabel}: "thumbnailUrl" must be a string or null.`);
  }

  return {
    signId: signRecord.id.trim(),
    conceptId: signRecord.conceptId.trim(),
    englishWord: signRecord.englishWord.trim().toLowerCase(),
    nepaliWord: signRecord.nepaliWord.trim(),
    meaningEnglish: signRecord.meaningEnglish.trim(),
    meaningNepali: signRecord.meaningNepali.trim(),
    categoryName: signRecord.category.trim(),
    videoUrl: signRecord.videoUrl?.trim() || null,
    thumbnailUrl: signRecord.thumbnailUrl?.trim() || null,
  };
}

function validateNoDuplicatesInFile(normalizedRecords) {
  const signIds = new Set();
  const conceptIds = new Set();

  for (const record of normalizedRecords) {
    if (signIds.has(record.signId)) {
      throw new Error(`Duplicate sign id in file: "${record.signId}".`);
    }
    signIds.add(record.signId);

    if (conceptIds.has(record.conceptId)) {
      throw new Error(`Duplicate concept id in file: "${record.conceptId}".`);
    }
    conceptIds.add(record.conceptId);
  }
}

async function findWordConceptId(client, language, wordText, excludeConceptId) {
  const result = await client.query(
    `select concept_id
     from words
     where language = $1
       and lower(word) = lower($2)
       and concept_id <> $3
     limit 1`,
    [language, wordText, excludeConceptId],
  );

  return result.rows[0]?.concept_id;
}

async function importSignRecord(client, record) {
  const categoryId = categoryNameToId(record.categoryName);

  const existingEnglishConceptId = await findWordConceptId(
    client,
    "en",
    record.englishWord,
    record.conceptId,
  );
  if (existingEnglishConceptId) {
    throw new Error(
      `English word "${record.englishWord}" already belongs to concept "${existingEnglishConceptId}".`,
    );
  }

  const existingNepaliConceptId = await findWordConceptId(
    client,
    "ne",
    record.nepaliWord,
    record.conceptId,
  );
  if (existingNepaliConceptId) {
    throw new Error(
      `Nepali word "${record.nepaliWord}" already belongs to concept "${existingNepaliConceptId}".`,
    );
  }

  const existingSign = await client.query(
    "select id from signs where id = $1",
    [record.signId],
  );
  if (existingSign.rows.length > 0) {
    return { status: "skipped", signId: record.signId };
  }

  const existingConcept = await client.query(
    "select id from concepts where id = $1",
    [record.conceptId],
  );
  if (existingConcept.rows.length > 0) {
    throw new Error(`Concept "${record.conceptId}" already exists.`);
  }

  await client.query(
    `insert into categories (id, name)
     values ($1, $2)
     on conflict (id) do nothing`,
    [categoryId, record.categoryName],
  );

  await client.query(
    `insert into concepts (id, category_id, meaning_english, meaning_nepali)
     values ($1, $2, $3, $4)`,
    [
      record.conceptId,
      categoryId,
      record.meaningEnglish,
      record.meaningNepali,
    ],
  );

  await client.query(
    `insert into words (concept_id, language, word)
     values ($1, 'en', $2), ($1, 'ne', $3)`,
    [record.conceptId, record.englishWord, record.nepaliWord],
  );

  await client.query(
    `insert into signs (id, concept_id, video_url, thumbnail_url)
     values ($1, $2, $3, $4)`,
    [record.signId, record.conceptId, record.videoUrl, record.thumbnailUrl],
  );

  return { status: "inserted", signId: record.signId };
}

async function runImport() {
  const importPath = parseImportPathFromArgs();
  const rawRecords = loadSignRecords(importPath);
  const normalizedRecords = rawRecords.map((record, index) =>
    validateSignRecord(record, index),
  );
  validateNoDuplicatesInFile(normalizedRecords);

  const pool = createPool();
  const client = await pool.connect();
  const results = { inserted: 0, skipped: 0 };

  try {
    await client.query("begin");

    for (const record of normalizedRecords) {
      const outcome = await importSignRecord(client, record);
      if (outcome.status === "inserted") {
        results.inserted += 1;
        console.log(`insert ${outcome.signId}`);
      } else {
        results.skipped += 1;
        console.log(`skip   ${outcome.signId} (already exists)`);
      }
    }

    await client.query("commit");
    console.log(
      `Import finished: ${results.inserted} inserted, ${results.skipped} skipped.`,
    );
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

console.log(`Import from ${parseImportPathFromArgs()}`);
runImport().catch((error) => {
  console.error("Import failed:", error.message);
  process.exit(1);
});

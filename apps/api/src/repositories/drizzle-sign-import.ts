import { and, eq, ne, sql } from "drizzle-orm";
import type { IsharaDatabaseExecutor } from "../db/client.js";
import type {
  BulkSignImportResult,
  NormalizedSignImportRecord,
  SignImportOutcome,
} from "../data/sign-import.js";
import {
  normalizeSignImportRecord,
  validateNoDuplicateSignIdsInBatch,
} from "../data/sign-import.js";
import { categories, concepts, signs, words } from "../db/schema.js";

async function findWordConceptId(
  database: IsharaDatabaseExecutor,
  language: string,
  wordText: string,
  excludeConceptId: string,
): Promise<string | undefined> {
  const matchingWord = await database.query.words.findFirst({
    where: and(
      eq(words.language, language),
      sql`lower(${words.word}) = lower(${wordText})`,
      ne(words.conceptId, excludeConceptId),
    ),
    columns: { conceptId: true },
  });

  return matchingWord?.conceptId;
}

export async function importSignRecordWithDatabase(
  database: IsharaDatabaseExecutor,
  record: NormalizedSignImportRecord,
): Promise<SignImportOutcome> {
  const existingEnglishConceptId = await findWordConceptId(
    database,
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
    database,
    "ne",
    record.nepaliWord,
    record.conceptId,
  );
  if (existingNepaliConceptId) {
    throw new Error(
      `Nepali word "${record.nepaliWord}" already belongs to concept "${existingNepaliConceptId}".`,
    );
  }

  const existingSign = await database.query.signs.findFirst({
    where: eq(signs.id, record.signId),
    columns: { id: true },
  });
  if (existingSign) {
    return {
      status: "skipped",
      signId: record.signId,
      message: "Sign already exists.",
    };
  }

  const existingConcept = await database.query.concepts.findFirst({
    where: eq(concepts.id, record.conceptId),
    columns: { id: true },
  });
  if (existingConcept) {
    throw new Error(`Concept "${record.conceptId}" already exists.`);
  }

  await database.insert(categories).values({
    id: record.categoryId,
    name: record.categoryName,
  }).onConflictDoNothing();

  await database.insert(concepts).values({
    id: record.conceptId,
    categoryId: record.categoryId,
    meaningEnglish: record.meaningEnglish,
    meaningNepali: record.meaningNepali,
  });

  await database.insert(words).values([
    {
      conceptId: record.conceptId,
      language: "en",
      word: record.englishWord,
    },
    {
      conceptId: record.conceptId,
      language: "ne",
      word: record.nepaliWord,
    },
  ]);

  await database.insert(signs).values({
    id: record.signId,
    conceptId: record.conceptId,
    videoUrl: record.videoUrl,
    thumbnailUrl: record.thumbnailUrl,
  });

  return { status: "inserted", signId: record.signId };
}

export async function bulkImportSignRecordsWithDatabase(
  database: IsharaDatabaseExecutor,
  rawRecords: unknown[],
): Promise<BulkSignImportResult> {
  const normalizedRecords = rawRecords.map((record, index) =>
    normalizeSignImportRecord(record, index),
  );
  validateNoDuplicateSignIdsInBatch(normalizedRecords);

  const outcomes: SignImportOutcome[] = [];
  const errors: string[] = [];
  let inserted = 0;
  let skipped = 0;
  let failed = 0;

  try {
    await database.transaction(async (transaction) => {
      for (const record of normalizedRecords) {
        try {
          const outcome = await importSignRecordWithDatabase(transaction, record);
          outcomes.push(outcome);

          if (outcome.status === "inserted") {
            inserted += 1;
          } else {
            skipped += 1;
          }
        } catch (error) {
          failed += 1;
          const message =
            error instanceof Error ? error.message : "Import failed for record.";
          errors.push(`${record.signId}: ${message}`);
          outcomes.push({
            status: "skipped",
            signId: record.signId,
            message,
          });
          throw error;
        }
      }
    });
  } catch {
    return {
      inserted: 0,
      skipped: 0,
      failed,
      outcomes,
      errors,
    };
  }

  return { inserted, skipped, failed, outcomes, errors };
}

export async function importSingleSignRecordWithDatabase(
  database: IsharaDatabaseExecutor,
  rawRecord: unknown,
): Promise<SignImportOutcome> {
  const normalizedRecord = normalizeSignImportRecord(rawRecord, 0);

  return database.transaction(async (transaction) => {
    return importSignRecordWithDatabase(transaction, normalizedRecord);
  });
}

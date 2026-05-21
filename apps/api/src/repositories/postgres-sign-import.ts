import type pg from "pg";
import type {
  BulkSignImportResult,
  NormalizedSignImportRecord,
  SignImportOutcome,
} from "../data/sign-import.js";
import {
  normalizeSignImportRecord,
  validateNoDuplicateSignIdsInBatch,
} from "../data/sign-import.js";

async function findWordConceptId(
  client: pg.PoolClient,
  language: string,
  wordText: string,
  excludeConceptId: string,
): Promise<string | undefined> {
  const result = await client.query<{ concept_id: string }>(
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

export async function importSignRecordWithClient(
  client: pg.PoolClient,
  record: NormalizedSignImportRecord,
): Promise<SignImportOutcome> {
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

  const existingSign = await client.query<{ id: string }>(
    "select id from signs where id = $1",
    [record.signId],
  );
  if (existingSign.rows.length > 0) {
    return {
      status: "skipped",
      signId: record.signId,
      message: "Sign already exists.",
    };
  }

  const existingConcept = await client.query<{ id: string }>(
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
    [record.categoryId, record.categoryName],
  );

  await client.query(
    `insert into concepts (id, category_id, meaning_english, meaning_nepali)
     values ($1, $2, $3, $4)`,
    [
      record.conceptId,
      record.categoryId,
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

export async function bulkImportSignRecordsWithPool(
  pool: pg.Pool,
  rawRecords: unknown[],
): Promise<BulkSignImportResult> {
  const normalizedRecords = rawRecords.map((record, index) =>
    normalizeSignImportRecord(record, index),
  );
  validateNoDuplicateSignIdsInBatch(normalizedRecords);

  const client = await pool.connect();
  const outcomes: SignImportOutcome[] = [];
  const errors: string[] = [];
  let inserted = 0;
  let skipped = 0;
  let failed = 0;

  try {
    await client.query("begin");

    for (const record of normalizedRecords) {
      try {
        const outcome = await importSignRecordWithClient(client, record);
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
      }
    }

    if (failed > 0) {
      await client.query("rollback");
      return {
        inserted: 0,
        skipped: 0,
        failed,
        outcomes,
        errors,
      };
    }

    await client.query("commit");
    return { inserted, skipped, failed, outcomes, errors };
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}

export async function importSingleSignRecordWithPool(
  pool: pg.Pool,
  rawRecord: unknown,
): Promise<SignImportOutcome> {
  const normalizedRecord = normalizeSignImportRecord(rawRecord, 0);
  const client = await pool.connect();

  try {
    await client.query("begin");
    const outcome = await importSignRecordWithClient(client, normalizedRecord);
    await client.query("commit");
    return outcome;
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}

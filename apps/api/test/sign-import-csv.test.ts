import assert from "node:assert/strict";
import { describe, test } from "node:test";
import { parseSignRecordsFromCsv } from "../src/data/sign-import-csv.js";
import { normalizeSignImportRecord } from "../src/data/sign-import.js";

describe("parseSignRecordsFromCsv", () => {
  test("parses header aliases and normalizes rows", () => {
    const csvContent = [
      "sign_id,concept_id,english_word,nepali_word,meaning_english,meaning_nepali,category_name",
      "good-day,concept-good-day,good day,शुभ दिन,A positive day greeting.,शुभ दिनको अभिवादन।,Greetings",
    ].join("\n");

    const rawRecords = parseSignRecordsFromCsv(csvContent);
    assert.equal(rawRecords.length, 1);

    const normalized = normalizeSignImportRecord(rawRecords[0], 0);
    assert.equal(normalized.signId, "good-day");
    assert.equal(normalized.conceptId, "concept-good-day");
    assert.equal(normalized.englishWord, "good day");
    assert.equal(normalized.categoryName, "Greetings");
  });
});

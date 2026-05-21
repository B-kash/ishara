import assert from "node:assert/strict";
import { describe, test } from "node:test";
import {
  buildSignBrowsePage,
  filterSignRecordsAfterCursor,
  prepareBrowseSignRecords,
} from "../src/data/sign-browse-pagination.js";
import type { SignRecord } from "../src/types/sign-record.js";

const sampleSignRecords: SignRecord[] = [
  {
    id: "hello",
    conceptId: "c1",
    englishWord: "hello",
    nepaliWord: "नमस्ते",
    meaningEnglish: "hi",
    meaningNepali: "hi",
    category: "Greetings",
    videoUrl: null,
    thumbnailUrl: null,
  },
  {
    id: "mother",
    conceptId: "c2",
    englishWord: "mother",
    nepaliWord: "आमा",
    meaningEnglish: "parent",
    meaningNepali: "parent",
    category: "Family",
    videoUrl: null,
    thumbnailUrl: null,
  },
  {
    id: "water",
    conceptId: "c3",
    englishWord: "water",
    nepaliWord: "पानी",
    meaningEnglish: "drink",
    meaningNepali: "drink",
    category: "Food",
    videoUrl: null,
    thumbnailUrl: null,
  },
];

describe("sign-browse-pagination", () => {
  test("filterSignRecordsAfterCursor returns ids greater than cursor", () => {
    const sorted = [...sampleSignRecords].sort((left, right) =>
      left.id.localeCompare(right.id),
    );
    const filtered = filterSignRecordsAfterCursor(sorted, "hello");

    assert.deepEqual(
      filtered.map((sign) => sign.id),
      ["mother", "water"],
    );
  });

  test("buildSignBrowsePage sets nextCursor when more items exist", () => {
    const page = buildSignBrowsePage(sampleSignRecords, 2);

    assert.equal(page.items.length, 2);
    assert.equal(page.hasMore, true);
    assert.equal(page.nextCursor, "mother");
  });

  test("prepareBrowseSignRecords filters by Nepali vowel", () => {
    const pageItems = prepareBrowseSignRecords(sampleSignRecords, {
      limit: 10,
      letter: "आ",
      letterLanguage: "ne",
    });

    assert.deepEqual(
      pageItems.map((sign) => sign.id),
      ["mother"],
    );
  });

  test("prepareBrowseSignRecords filters by English letter", () => {
    const pageItems = prepareBrowseSignRecords(sampleSignRecords, {
      limit: 10,
      letter: "h",
      letterLanguage: "en",
    });

    assert.deepEqual(
      pageItems.map((sign) => sign.id),
      ["hello"],
    );
  });
});

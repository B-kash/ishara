import assert from "node:assert/strict";
import { describe, test } from "node:test";
import {
  buildSignBrowsePage,
  filterSignGraphsAfterCursor,
  prepareBrowseSignGraphs,
} from "../src/data/sign-browse-pagination.js";
import { buildSignGraphFromFlatInput } from "../src/db/sign-graph.js";

const sampleSignGraphs = [
  buildSignGraphFromFlatInput({
    signId: "hello",
    conceptId: "c1",
    englishWord: "hello",
    nepaliWord: "नमस्ते",
    meaningEnglish: "hi",
    meaningNepali: "hi",
    categoryName: "Greetings",
  }),
  buildSignGraphFromFlatInput({
    signId: "mother",
    conceptId: "c2",
    englishWord: "mother",
    nepaliWord: "आमा",
    meaningEnglish: "parent",
    meaningNepali: "parent",
    categoryName: "Family",
  }),
  buildSignGraphFromFlatInput({
    signId: "water",
    conceptId: "c3",
    englishWord: "water",
    nepaliWord: "पानी",
    meaningEnglish: "drink",
    meaningNepali: "drink",
    categoryName: "Food",
  }),
];

describe("sign-browse-pagination", () => {
  test("filterSignGraphsAfterCursor returns ids greater than cursor", () => {
    const sorted = [...sampleSignGraphs].sort((left, right) =>
      left.sign.id.localeCompare(right.sign.id),
    );
    const filtered = filterSignGraphsAfterCursor(sorted, "hello");

    assert.deepEqual(
      filtered.map((signGraph) => signGraph.sign.id),
      ["mother", "water"],
    );
  });

  test("buildSignBrowsePage sets nextCursor when more items exist", () => {
    const page = buildSignBrowsePage(sampleSignGraphs, 2);

    assert.equal(page.items.length, 2);
    assert.equal(page.hasMore, true);
    assert.equal(page.nextCursor, "mother");
  });

  test("prepareBrowseSignGraphs filters by Nepali vowel", () => {
    const pageItems = prepareBrowseSignGraphs(sampleSignGraphs, {
      limit: 10,
      letter: "आ",
      letterLanguage: "ne",
    });

    assert.deepEqual(
      pageItems.map((signGraph) => signGraph.sign.id),
      ["mother"],
    );
  });

  test("prepareBrowseSignGraphs filters by English letter", () => {
    const pageItems = prepareBrowseSignGraphs(sampleSignGraphs, {
      limit: 10,
      letter: "h",
      letterLanguage: "en",
    });

    assert.deepEqual(
      pageItems.map((signGraph) => signGraph.sign.id),
      ["hello"],
    );
  });
});

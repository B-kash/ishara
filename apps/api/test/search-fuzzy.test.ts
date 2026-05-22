import assert from "node:assert/strict";
import { describe, test } from "node:test";
import {
  fuzzyMatchScore,
  fuzzyTermMatches,
  levenshteinDistance,
} from "../src/data/search-fuzzy.js";
import { scoreBilingualSearch } from "../src/data/sign-search-matching.js";
import { buildSignGraphFromFlatInput } from "../src/db/sign-graph.js";

const motherSignGraph = buildSignGraphFromFlatInput({
  signId: "mother",
  conceptId: "mother-concept",
  englishWord: "mother",
  nepaliWord: "आमा",
  meaningEnglish: "A female parent.",
  meaningNepali: "आमाले जन्माउनुभएको सन्तानको लागि महिला अभिभावक।",
  categoryName: "Family",
});

describe("search-fuzzy", () => {
  test("levenshteinDistance counts edits", () => {
    assert.equal(levenshteinDistance("mother", "motr"), 2);
    assert.equal(levenshteinDistance("mother", "mom"), 4);
    assert.equal(levenshteinDistance("mot", "mom"), 1);
  });

  test("fuzzyTermMatches accepts typo motr for mother", () => {
    assert.equal(fuzzyTermMatches("mother", "motr"), true);
  });

  test("fuzzyTermMatches accepts mom against mother prefix", () => {
    assert.equal(fuzzyTermMatches("mother", "mom"), true);
    assert.ok(fuzzyMatchScore("mother", "mom") >= 50);
  });

  test("fuzzyTermMatches rejects unrelated words", () => {
    assert.equal(fuzzyTermMatches("mother", "school"), false);
  });
});

describe("scoreBilingualSearch", () => {
  test("matches English mother", () => {
    assert.ok(scoreBilingualSearch(motherSignGraph, "mother") > 0);
  });

  test("matches Nepali आमा", () => {
    assert.ok(scoreBilingualSearch(motherSignGraph, "आमा") > 0);
  });

  test("fuzzy matches mom and motr in English", () => {
    assert.ok(scoreBilingualSearch(motherSignGraph, "mom") > 0);
    assert.ok(scoreBilingualSearch(motherSignGraph, "motr") > 0);
  });
});

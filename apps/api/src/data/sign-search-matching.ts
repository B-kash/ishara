import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import { fuzzyMatchScore } from "./search-fuzzy.js";
import {
  normalizeEnglishText,
  normalizeNepaliText,
  normalizeSearchQuery,
} from "./search-normalization.js";
import { expandSearchTerms } from "./search-synonyms.js";

const nepaliScriptPattern = /[\u0900-\u097F]/;

function normalizeSignWord(
  signRecord: SignRecord,
  language: SearchLanguageCode,
): string {
  const wordText =
    language === "en" ? signRecord.englishWord : signRecord.nepaliWord;

  if (language === "en") {
    return normalizeEnglishText(wordText);
  }

  return normalizeNepaliText(wordText);
}

export function buildSearchTerms(
  searchQuery: string,
  language: SearchLanguageCode,
): string[] {
  const normalizedQuery = normalizeSearchQuery(searchQuery, language);
  if (!normalizedQuery) {
    return [];
  }

  return expandSearchTerms(normalizedQuery, language);
}

export function collectBilingualSearchTerms(searchQuery: string): string[] {
  const trimmedQuery = searchQuery.trim();
  if (!trimmedQuery) {
    return [];
  }

  const englishTerms = buildSearchTerms(trimmedQuery, "en");
  const nepaliTerms = buildSearchTerms(trimmedQuery, "ne");
  const uniqueTerms = new Set([...englishTerms, ...nepaliTerms]);

  return [...uniqueTerms];
}

export function detectDisplayLanguage(searchQuery: string): SearchLanguageCode {
  if (nepaliScriptPattern.test(searchQuery)) {
    return "ne";
  }

  return "en";
}

export function scoreBilingualSearch(
  signRecord: SignRecord,
  searchQuery: string,
): number {
  const trimmedQuery = searchQuery.trim();
  if (!trimmedQuery) {
    return 0;
  }

  const englishWord = normalizeSignWord(signRecord, "en");
  const nepaliWord = normalizeSignWord(signRecord, "ne");
  const englishTerms = buildSearchTerms(trimmedQuery, "en");
  const nepaliTerms = buildSearchTerms(trimmedQuery, "ne");

  let bestScore = 0;

  for (const searchTerm of englishTerms) {
    bestScore = Math.max(bestScore, fuzzyMatchScore(englishWord, searchTerm));
    bestScore = Math.max(bestScore, fuzzyMatchScore(nepaliWord, searchTerm));
  }

  for (const searchTerm of nepaliTerms) {
    bestScore = Math.max(bestScore, fuzzyMatchScore(nepaliWord, searchTerm));
    bestScore = Math.max(bestScore, fuzzyMatchScore(englishWord, searchTerm));
  }

  return bestScore;
}

export function signRecordMatchesBilingualSearch(
  signRecord: SignRecord,
  searchQuery: string,
): boolean {
  return scoreBilingualSearch(signRecord, searchQuery) > 0;
}

export function sortSignRecordsBySearchScore(
  signRecords: SignRecord[],
  searchQuery: string,
): SignRecord[] {
  return [...signRecords].sort(
    (left, right) =>
      scoreBilingualSearch(right, searchQuery) -
      scoreBilingualSearch(left, searchQuery),
  );
}

import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import {
  normalizeEnglishText,
  normalizeNepaliText,
  normalizeSearchQuery,
} from "./search-normalization.js";
import { expandSearchTerms } from "./search-synonyms.js";

function getSignWordText(
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

function termMatchesWord(normalizedWord: string, searchTerm: string): boolean {
  if (normalizedWord === searchTerm) {
    return true;
  }

  if (normalizedWord.includes(searchTerm)) {
    return true;
  }

  return searchTerm.includes(normalizedWord);
}

export function signRecordMatchesSearch(
  signRecord: SignRecord,
  searchQuery: string,
  language: SearchLanguageCode,
): boolean {
  const normalizedQuery = normalizeSearchQuery(searchQuery, language);
  if (!normalizedQuery) {
    return false;
  }

  const searchTerms = expandSearchTerms(normalizedQuery, language);
  const normalizedWord = getSignWordText(signRecord, language);

  return searchTerms.some((searchTerm) =>
    termMatchesWord(normalizedWord, searchTerm),
  );
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

import type { SearchLanguageCode } from "../types/sign-record.js";
import { normalizeEnglishText, normalizeNepaliText } from "./search-normalization.js";

const englishSynonymGroups: string[][] = [
  ["mother", "mom"],
  ["father", "dad"],
];

const nepaliSynonymGroups: string[][] = [
  ["स्कूल", "विद्यालय"],
];

function normalizeSynonymTerm(
  term: string,
  language: SearchLanguageCode,
): string {
  if (language === "en") {
    return normalizeEnglishText(term);
  }

  return normalizeNepaliText(term);
}

function getSynonymGroups(language: SearchLanguageCode): string[][] {
  return language === "en" ? englishSynonymGroups : nepaliSynonymGroups;
}

export function expandSearchTerms(
  normalizedQuery: string,
  language: SearchLanguageCode,
): string[] {
  const searchTerms = new Set<string>([normalizedQuery]);

  for (const synonymGroup of getSynonymGroups(language)) {
    const normalizedGroup = synonymGroup.map((term) =>
      normalizeSynonymTerm(term, language),
    );

    if (!normalizedGroup.includes(normalizedQuery)) {
      continue;
    }

    for (const synonymTerm of normalizedGroup) {
      searchTerms.add(synonymTerm);
    }
  }

  return [...searchTerms];
}

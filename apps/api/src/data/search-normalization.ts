import type { SearchLanguageCode } from "../types/search-language.js";

export function normalizeEnglishText(text: string): string {
  return text.trim().toLowerCase();
}

export function normalizeNepaliText(text: string): string {
  return text.trim();
}

export function normalizeSearchQuery(
  searchQuery: string,
  language: SearchLanguageCode,
): string {
  if (language === "en") {
    return normalizeEnglishText(searchQuery);
  }

  return normalizeNepaliText(searchQuery);
}

import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import { getAllSignRecords } from "./sign-repository.js";

export function parseSearchLanguage(
  languageInput: string | undefined,
): SearchLanguageCode | null {
  const normalizedLanguage = languageInput?.trim().toLowerCase();
  if (normalizedLanguage === "en" || normalizedLanguage === "english") {
    return "en";
  }
  if (normalizedLanguage === "ne" || normalizedLanguage === "nepali") {
    return "ne";
  }
  return null;
}

export function searchSignRecords(
  searchQuery: string,
  language: SearchLanguageCode,
): SignRecord[] {
  const normalizedQuery = searchQuery.trim().toLowerCase();
  if (!normalizedQuery) {
    return [];
  }

  return getAllSignRecords().filter((sign) => {
    const wordText =
      language === "en"
        ? sign.englishWord.toLowerCase()
        : sign.nepaliWord.toLowerCase();
    return wordText.includes(normalizedQuery);
  });
}

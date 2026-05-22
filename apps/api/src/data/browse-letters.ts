import type { SignGraph } from "../db/sign-graph.js";
import type { SearchLanguageCode } from "../types/search-language.js";
import {
  normalizeEnglishText,
  normalizeNepaliText,
} from "./search-normalization.js";

export const englishBrowseLetters = "abcdefghijklmnopqrstuvwxyz"
  .split("")
  .map((letter) => letter);

/** Nepali swaras (vowels), then vyanjan (क through ज्ञ). */
export const nepaliVowelLetters = [
  "अ",
  "आ",
  "इ",
  "ई",
  "उ",
  "ऊ",
  "ए",
  "ऐ",
  "ओ",
  "औ",
  "ओं",
  "अं",
  "अः",
  "ऋ",
];

export const nepaliConsonantLetters = [
  "क",
  "ख",
  "ग",
  "घ",
  "ङ",
  "च",
  "छ",
  "ज",
  "झ",
  "ञ",
  "ट",
  "ठ",
  "ड",
  "ढ",
  "ण",
  "त",
  "थ",
  "द",
  "ध",
  "न",
  "प",
  "फ",
  "ब",
  "भ",
  "म",
  "य",
  "र",
  "ल",
  "व",
  "श",
  "ष",
  "स",
  "ह",
  "क्ष",
  "त्र",
  "ज्ञ",
];

export const nepaliBrowseLetters = [
  ...nepaliVowelLetters,
  ...nepaliConsonantLetters,
];

const englishLetterPattern = /^[a-z]$/;
const nepaliLetterPattern = /^[\u0900-\u097F]+$/;

export function isValidBrowseLetter(
  letter: string,
  letterLanguage: SearchLanguageCode,
): boolean {
  if (letterLanguage === "en") {
    return englishLetterPattern.test(letter);
  }

  if (!nepaliLetterPattern.test(letter) || letter.length > 4) {
    return false;
  }

  return (
    nepaliVowelLetters.includes(letter) ||
    nepaliConsonantLetters.includes(letter)
  );
}

export function signGraphMatchesBrowseLetter(
  signGraph: SignGraph,
  letter: string,
  letterLanguage: SearchLanguageCode,
): boolean {
  const wordText =
    letterLanguage === "en"
      ? signGraph.englishWord.word
      : signGraph.nepaliWord.word;

  const normalizedWord =
    letterLanguage === "en"
      ? normalizeEnglishText(wordText)
      : normalizeNepaliText(wordText);

  const normalizedLetter =
    letterLanguage === "en" ? letter.toLowerCase() : letter;

  return normalizedWord.startsWith(normalizedLetter);
}

export function buildLetterPrefixPattern(
  letter: string,
  letterLanguage: SearchLanguageCode,
): string {
  const normalizedLetter =
    letterLanguage === "en" ? letter.toLowerCase() : letter;

  return `${normalizedLetter}%`;
}

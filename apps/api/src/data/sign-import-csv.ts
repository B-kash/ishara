import { normalizeSignImportRecord } from "./sign-import.js";

const csvHeaderAliases: Record<string, string> = {
  id: "id",
  signid: "id",
  sign_id: "id",
  conceptid: "conceptId",
  concept_id: "conceptId",
  englishword: "englishWord",
  english_word: "englishWord",
  nepaliword: "nepaliWord",
  nepali_word: "nepaliWord",
  meaningenglish: "meaningEnglish",
  meaning_english: "meaningEnglish",
  meaningnepali: "meaningNepali",
  meaning_nepali: "meaningNepali",
  category: "category",
  categoryname: "category",
  category_name: "category",
  videourl: "videoUrl",
  video_url: "videoUrl",
  thumbnailurl: "thumbnailUrl",
  thumbnail_url: "thumbnailUrl",
};

function normalizeCsvHeader(header: string): string {
  const trimmedHeader = header.trim();
  const aliasKey = trimmedHeader
    .replace(/\s+/g, "")
    .replace(/-/g, "_")
    .toLowerCase();

  return csvHeaderAliases[aliasKey] ?? trimmedHeader;
}

function parseCsvLine(line: string): string[] {
  const values: string[] = [];
  let currentValue = "";
  let insideQuotes = false;

  for (let charIndex = 0; charIndex < line.length; charIndex += 1) {
    const character = line[charIndex];

    if (character === '"') {
      const nextCharacter = line[charIndex + 1];
      if (insideQuotes && nextCharacter === '"') {
        currentValue += '"';
        charIndex += 1;
        continue;
      }

      insideQuotes = !insideQuotes;
      continue;
    }

    if (character === "," && !insideQuotes) {
      values.push(currentValue);
      currentValue = "";
      continue;
    }

    currentValue += character;
  }

  values.push(currentValue);
  return values;
}

function rowToSignRecord(
  headers: string[],
  rowValues: string[],
): Record<string, string | null> {
  const record: Record<string, string | null> = {};

  for (let columnIndex = 0; columnIndex < headers.length; columnIndex += 1) {
    const canonicalField = headers[columnIndex];
    if (!canonicalField) {
      continue;
    }

    const cellValue = rowValues[columnIndex]?.trim() ?? "";
    record[canonicalField] = cellValue.length > 0 ? cellValue : null;
  }

  return record;
}

export function parseSignRecordsFromCsv(csvContent: string): unknown[] {
  const nonEmptyLines = csvContent
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  if (nonEmptyLines.length < 2) {
    throw new Error("CSV must include a header row and at least one data row.");
  }

  const headerRow = parseCsvLine(nonEmptyLines[0]!);
  const canonicalHeaders = headerRow.map(normalizeCsvHeader);

  const requiredCanonicalFields = [
    "id",
    "conceptId",
    "englishWord",
    "nepaliWord",
    "meaningEnglish",
    "meaningNepali",
    "category",
  ];

  for (const requiredField of requiredCanonicalFields) {
    if (!canonicalHeaders.includes(requiredField)) {
      throw new Error(`CSV is missing required column: ${requiredField}.`);
    }
  }

  const rawRecords: unknown[] = [];

  for (let rowIndex = 1; rowIndex < nonEmptyLines.length; rowIndex += 1) {
    const rowValues = parseCsvLine(nonEmptyLines[rowIndex]!);
    rawRecords.push(rowToSignRecord(canonicalHeaders, rowValues));
  }

  return rawRecords;
}

export function normalizeSignRecordsFromCsv(csvContent: string) {
  const rawRecords = parseSignRecordsFromCsv(csvContent);
  return rawRecords.map((record, index) =>
    normalizeSignImportRecord(record, index),
  );
}

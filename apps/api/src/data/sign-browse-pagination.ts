import type { SearchLanguageCode, SignRecord } from "../types/sign-record.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import { signRecordMatchesBrowseLetter } from "./browse-letters.js";

export interface BrowsePageQuery {
  cursor?: string;
  limit: number;
  letter?: string;
  letterLanguage?: SearchLanguageCode;
}

export function buildSignBrowsePage(
  signRecords: SignRecord[],
  limit: number,
): SignBrowsePage {
  const hasMore = signRecords.length > limit;
  const pageItems = hasMore ? signRecords.slice(0, limit) : signRecords;
  const lastItem = pageItems.at(-1);

  return {
    items: pageItems,
    nextCursor: hasMore && lastItem ? lastItem.id : null,
    hasMore,
  };
}

export function filterSignRecordsAfterCursor(
  sortedSignRecords: SignRecord[],
  cursor: string | undefined,
): SignRecord[] {
  if (!cursor) {
    return sortedSignRecords;
  }

  return sortedSignRecords.filter((signRecord) => signRecord.id > cursor);
}

export function prepareBrowseSignRecords(
  signRecords: SignRecord[],
  query: BrowsePageQuery,
): SignRecord[] {
  const sortedSignRecords = [...signRecords].sort((left, right) =>
    left.id.localeCompare(right.id),
  );

  const letterFilteredSignRecords =
    query.letter && query.letterLanguage
      ? sortedSignRecords.filter((signRecord) =>
          signRecordMatchesBrowseLetter(
            signRecord,
            query.letter!,
            query.letterLanguage!,
          ),
        )
      : sortedSignRecords;

  const cursorFilteredSignRecords = filterSignRecordsAfterCursor(
    letterFilteredSignRecords,
    query.cursor,
  );

  return cursorFilteredSignRecords.slice(0, query.limit + 1);
}

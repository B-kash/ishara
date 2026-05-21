import type { SignRecord } from "../types/sign-record.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";

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

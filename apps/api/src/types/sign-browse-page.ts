import type { SignRecord } from "./sign-record.js";

export interface SignBrowsePage {
  items: SignRecord[];
  nextCursor: string | null;
  hasMore: boolean;
}

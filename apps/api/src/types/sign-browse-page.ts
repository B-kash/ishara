import type { SignGraph } from "../db/sign-graph.js";

export interface SignBrowsePage {
  items: SignGraph[];
  nextCursor: string | null;
  hasMore: boolean;
}

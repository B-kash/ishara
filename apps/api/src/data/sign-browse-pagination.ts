import type { SignGraph } from "../db/sign-graph.js";
import type { SignBrowsePage } from "../types/sign-browse-page.js";
import type { SearchLanguageCode } from "../types/search-language.js";
import { signGraphMatchesBrowseLetter } from "./browse-letters.js";

export interface BrowsePageQuery {
  cursor?: string;
  limit: number;
  letter?: string;
  letterLanguage?: SearchLanguageCode;
}

export function buildSignBrowsePage(
  signGraphs: SignGraph[],
  limit: number,
): SignBrowsePage {
  const hasMore = signGraphs.length > limit;
  const pageItems = hasMore ? signGraphs.slice(0, limit) : signGraphs;
  const lastItem = pageItems.at(-1);

  return {
    items: pageItems,
    nextCursor: hasMore && lastItem ? lastItem.sign.id : null,
    hasMore,
  };
}

export function filterSignGraphsAfterCursor(
  sortedSignGraphs: SignGraph[],
  cursor: string | undefined,
): SignGraph[] {
  if (!cursor) {
    return sortedSignGraphs;
  }

  return sortedSignGraphs.filter((signGraph) => signGraph.sign.id > cursor);
}

export function prepareBrowseSignGraphs(
  signGraphs: SignGraph[],
  query: BrowsePageQuery,
): SignGraph[] {
  const sortedSignGraphs = [...signGraphs].sort((left, right) =>
    left.sign.id.localeCompare(right.sign.id),
  );

  const letterFilteredSignGraphs =
    query.letter && query.letterLanguage
      ? sortedSignGraphs.filter((signGraph) =>
          signGraphMatchesBrowseLetter(
            signGraph,
            query.letter!,
            query.letterLanguage!,
          ),
        )
      : sortedSignGraphs;

  const cursorFilteredSignGraphs = filterSignGraphsAfterCursor(
    letterFilteredSignGraphs,
    query.cursor,
  );

  return cursorFilteredSignGraphs.slice(0, query.limit + 1);
}

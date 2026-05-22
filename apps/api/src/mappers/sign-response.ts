import type { SignGraph } from "../db/sign-graph.js";
import type { SearchLanguageCode } from "../types/search-language.js";
import type { SignDetail, SignSearchResult } from "../types/api-responses.js";

export function toSignSearchResult(
  signGraph: SignGraph,
  language: SearchLanguageCode,
): SignSearchResult {
  return {
    id: signGraph.sign.id,
    englishWord: signGraph.englishWord.word,
    nepaliWord: signGraph.nepaliWord.word,
    category: signGraph.category.name,
    meaning:
      language === "en"
        ? signGraph.concept.meaningEnglish
        : signGraph.concept.meaningNepali,
  };
}

export function toSignDetail(signGraph: SignGraph): SignDetail {
  return {
    id: signGraph.sign.id,
    englishWord: signGraph.englishWord.word,
    nepaliWord: signGraph.nepaliWord.word,
    category: signGraph.category.name,
    meaning: signGraph.concept.meaningEnglish,
    videoUrl: signGraph.sign.videoUrl,
    thumbnailUrl: signGraph.sign.thumbnailUrl,
    videoDurationSeconds: null,
  };
}

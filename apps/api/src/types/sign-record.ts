export type SearchLanguageCode = "en" | "ne";

export interface SignRecord {
  id: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  category: string;
  /** Future CDN URL for the sign video (metadata only). */
  videoUrl: string | null;
  /** Preview image when video is missing or before playback. */
  thumbnailUrl: string | null;
}

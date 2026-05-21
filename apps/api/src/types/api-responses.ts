export interface Category {
  id: string;
  name: string;
}

export interface CategoryListResponse {
  items: Category[];
}

export interface SignSearchResult {
  id: string;
  englishWord: string;
  nepaliWord: string;
  category: string;
  meaning: string;
}

export interface SignSearchResponse {
  items: SignSearchResult[];
}

export interface SignBrowsePageInfo {
  nextCursor: string | null;
  hasMore: boolean;
}

export interface SignBrowseResponse {
  items: SignSearchResult[];
  pageInfo: SignBrowsePageInfo;
}

export interface SignDetail {
  id: string;
  englishWord: string;
  nepaliWord: string;
  category: string;
  meaning: string;
  videoUrl: string | null;
  thumbnailUrl: string | null;
  videoDurationSeconds: number | null;
}

export type ApiErrorCode =
  | "VALIDATION_ERROR"
  | "NOT_FOUND"
  | "UNAUTHORIZED"
  | "DATABASE_ERROR"
  | "INTERNAL_ERROR";

export interface ApiErrorBody {
  code: ApiErrorCode;
  message: string;
}

export interface ApiErrorResponse {
  error: ApiErrorBody;
}

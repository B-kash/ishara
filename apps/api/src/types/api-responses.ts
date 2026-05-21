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

export interface SignDetail {
  id: string;
  englishWord: string;
  nepaliWord: string;
  category: string;
  meaning: string;
  videoUrl: string | null;
  thumbnailUrl: string | null;
}

export type ApiErrorCode =
  | "VALIDATION_ERROR"
  | "NOT_FOUND"
  | "DATABASE_ERROR"
  | "INTERNAL_ERROR";

export interface ApiErrorBody {
  code: ApiErrorCode;
  message: string;
}

export interface ApiErrorResponse {
  error: ApiErrorBody;
}

import type {
  ApiErrorCode,
  ApiErrorResponse,
} from "../types/api-responses.js";

export function buildApiErrorResponse(
  code: ApiErrorCode,
  message: string,
): ApiErrorResponse {
  return {
    error: {
      code,
      message,
    },
  };
}

export function validationErrorResponse(
  message = "Invalid request",
): ApiErrorResponse {
  return buildApiErrorResponse("VALIDATION_ERROR", message);
}

export function notFoundErrorResponse(message: string): ApiErrorResponse {
  return buildApiErrorResponse("NOT_FOUND", message);
}

export function databaseErrorResponse(
  message = "Database is unavailable",
): ApiErrorResponse {
  return buildApiErrorResponse("DATABASE_ERROR", message);
}

export function internalErrorResponse(
  message = "Something went wrong",
): ApiErrorResponse {
  return buildApiErrorResponse("INTERNAL_ERROR", message);
}

export function unauthorizedErrorResponse(
  message = "Unauthorized",
): ApiErrorResponse {
  return buildApiErrorResponse("UNAUTHORIZED", message);
}

export function isDatabaseError(error: unknown): boolean {
  if (!error || typeof error !== "object") {
    return false;
  }

  const errorRecord = error as Record<string, unknown>;
  if (errorRecord["code"] === "ECONNREFUSED" || errorRecord["code"] === "ENOTFOUND") {
    return true;
  }

  return errorRecord["name"] === "error" && typeof errorRecord["severity"] === "string";
}

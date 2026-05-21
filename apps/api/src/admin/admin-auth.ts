import { createHmac, timingSafeEqual } from "node:crypto";

export interface AdminAuthConfig {
  username: string;
  password: string;
  sessionSecret: string;
  sessionTtlMs: number;
}

export interface AdminSessionClaims {
  username: string;
  expiresAt: number;
}

const sessionSeparator = ".";

function encodePayload(claims: AdminSessionClaims): string {
  return Buffer.from(JSON.stringify(claims)).toString("base64url");
}

function decodePayload(encodedPayload: string): AdminSessionClaims | null {
  try {
    const decodedJson = Buffer.from(encodedPayload, "base64url").toString("utf8");
    const parsed = JSON.parse(decodedJson) as AdminSessionClaims;

    if (
      typeof parsed.username !== "string" ||
      typeof parsed.expiresAt !== "number"
    ) {
      return null;
    }

    return parsed;
  } catch {
    return null;
  }
}

function signPayload(encodedPayload: string, sessionSecret: string): string {
  return createHmac("sha256", sessionSecret)
    .update(encodedPayload)
    .digest("base64url");
}

function signaturesMatch(expected: string, actual: string): boolean {
  const expectedBuffer = Buffer.from(expected);
  const actualBuffer = Buffer.from(actual);

  if (expectedBuffer.length !== actualBuffer.length) {
    return false;
  }

  return timingSafeEqual(expectedBuffer, actualBuffer);
}

export function createAdminSessionToken(
  username: string,
  sessionSecret: string,
  sessionTtlMs: number,
): string {
  const claims: AdminSessionClaims = {
    username,
    expiresAt: Date.now() + sessionTtlMs,
  };
  const encodedPayload = encodePayload(claims);
  const signature = signPayload(encodedPayload, sessionSecret);
  return `${encodedPayload}${sessionSeparator}${signature}`;
}

export function verifyAdminSessionToken(
  token: string,
  sessionSecret: string,
): AdminSessionClaims | null {
  const separatorIndex = token.lastIndexOf(sessionSeparator);
  if (separatorIndex <= 0) {
    return null;
  }

  const encodedPayload = token.slice(0, separatorIndex);
  const providedSignature = token.slice(separatorIndex + 1);
  const expectedSignature = signPayload(encodedPayload, sessionSecret);

  if (!signaturesMatch(expectedSignature, providedSignature)) {
    return null;
  }

  const claims = decodePayload(encodedPayload);
  if (!claims || claims.expiresAt <= Date.now()) {
    return null;
  }

  return claims;
}

function constantTimeStringsMatch(left: string, right: string): boolean {
  if (left.length !== right.length) {
    return false;
  }

  return timingSafeEqual(Buffer.from(left), Buffer.from(right));
}

export function validateAdminCredentials(
  username: string,
  password: string,
  adminAuth: AdminAuthConfig,
): boolean {
  return (
    constantTimeStringsMatch(username, adminAuth.username) &&
    constantTimeStringsMatch(password, adminAuth.password)
  );
}

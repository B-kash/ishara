import type { FastifyReply, FastifyRequest } from "fastify";
import type { AdminAuthConfig } from "./admin-auth.js";
import { verifyAdminSessionToken } from "./admin-auth.js";
import { unauthorizedErrorResponse } from "../errors/api-error.js";

export interface AdminRouteContext {
  adminAuth: AdminAuthConfig;
}

declare module "fastify" {
  interface FastifyRequest {
    adminSession?: {
      username: string;
    };
  }
}

function readBearerToken(authorizationHeader: string | undefined): string | null {
  if (!authorizationHeader) {
    return null;
  }

  const bearerPrefix = "Bearer ";
  if (!authorizationHeader.startsWith(bearerPrefix)) {
    return null;
  }

  const token = authorizationHeader.slice(bearerPrefix.length).trim();
  return token.length > 0 ? token : null;
}

export function createRequireAdminAuth(adminAuth: AdminAuthConfig) {
  return async function requireAdminAuth(
    request: FastifyRequest,
    reply: FastifyReply,
  ): Promise<void> {
    const token = readBearerToken(request.headers.authorization);
    if (!token) {
      reply.status(401).send(unauthorizedErrorResponse("Login required."));
      return;
    }

    const sessionClaims = verifyAdminSessionToken(token, adminAuth.sessionSecret);
    if (!sessionClaims) {
      reply.status(401).send(unauthorizedErrorResponse("Session expired or invalid."));
      return;
    }

    request.adminSession = { username: sessionClaims.username };
  };
}

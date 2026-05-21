import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import fastifyStatic from "@fastify/static";
import cors from "@fastify/cors";
import Fastify, { type FastifyInstance } from "fastify";
import type { AdminAuthConfig } from "./admin/admin-auth.js";
import type { CorsOriginSetting, DataSource } from "./config/env.js";
import { registerAppContext } from "./context/register-app-context.js";
import {
  databaseErrorResponse,
  internalErrorResponse,
  isDatabaseError,
} from "./errors/api-error.js";
import type { SignRepository } from "./repositories/sign-repository.js";
import { adminRoutes } from "./routes/admin.js";
import { categoryRoutes } from "./routes/categories.js";
import { signRoutes } from "./routes/signs.js";

const apiDirectory = dirname(fileURLToPath(import.meta.url));
const adminPublicDirectory = join(apiDirectory, "../../admin/public");

export interface CreateServerOptions {
  dataSource: DataSource;
  signRepository: SignRepository;
  adminAuth?: AdminAuthConfig | null;
  enableMedia?: boolean;
  enableAdminPanel?: boolean;
  logger?: boolean;
  corsOrigin?: CorsOriginSetting;
}

export async function createServer(
  options: CreateServerOptions,
): Promise<FastifyInstance> {
  const {
    dataSource,
    signRepository,
    adminAuth = null,
    enableMedia = false,
    enableAdminPanel = Boolean(adminAuth),
    logger = false,
    corsOrigin = true,
  } = options;

  const server = Fastify({ logger });

  await registerAppContext(server, { signRepository, dataSource });

  server.setErrorHandler((error, request, reply) => {
    const log = request.app?.log ?? server.log;
    log.error(error);

    if (isDatabaseError(error)) {
      return reply.status(503).send(databaseErrorResponse());
    }

    return reply.status(500).send(internalErrorResponse());
  });

  await server.register(cors, { origin: corsOrigin });

  if (enableMedia) {
    const mediaDirectory = join(apiDirectory, "../../../data/media");
    await server.register(fastifyStatic, {
      root: mediaDirectory,
      prefix: "/media/",
      decorateReply: false,
    });
  }

  server.get("/health", async (request) => {
    return {
      status: "ok",
      dataSource: request.app.dataSource,
    };
  });

  await server.register(categoryRoutes);
  await server.register(signRoutes);

  if (enableAdminPanel && adminAuth) {
    await server.register(adminRoutes, { adminAuth });
    await server.register(fastifyStatic, {
      root: adminPublicDirectory,
      prefix: "/admin/",
      decorateReply: false,
    });
    server.get("/admin", async (_request, reply) => {
      return reply.redirect("/admin/");
    });
  }

  return server;
}

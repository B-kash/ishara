import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import fastifyStatic from "@fastify/static";
import cors from "@fastify/cors";
import Fastify, { type FastifyInstance } from "fastify";
import type { DataSource } from "./config/env.js";
import {
  databaseErrorResponse,
  internalErrorResponse,
  isDatabaseError,
} from "./errors/api-error.js";
import { setSignRepository } from "./repositories/active-sign-repository.js";
import type { SignRepository } from "./repositories/sign-repository.js";
import { categoryRoutes } from "./routes/categories.js";
import { signRoutes } from "./routes/signs.js";

const apiDirectory = dirname(fileURLToPath(import.meta.url));

export interface CreateServerOptions {
  dataSource: DataSource;
  signRepository: SignRepository;
  enableMedia?: boolean;
  logger?: boolean;
}

export async function createServer(
  options: CreateServerOptions,
): Promise<FastifyInstance> {
  const { dataSource, signRepository, enableMedia = false, logger = false } =
    options;

  setSignRepository(signRepository);

  const server = Fastify({ logger });

  server.setErrorHandler((error, request, reply) => {
    request.log.error(error);

    if (isDatabaseError(error)) {
      return reply.status(503).send(databaseErrorResponse());
    }

    return reply.status(500).send(internalErrorResponse());
  });

  await server.register(cors, { origin: true });

  if (enableMedia) {
    const mediaDirectory = join(apiDirectory, "../../../data/media");
    await server.register(fastifyStatic, {
      root: mediaDirectory,
      prefix: "/media/",
      decorateReply: false,
    });
  }

  server.get("/health", async () => {
    return {
      status: "ok",
      dataSource,
    };
  });

  await server.register(categoryRoutes);
  await server.register(signRoutes);

  return server;
}

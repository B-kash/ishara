import { config as loadDotenv } from "dotenv";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import cors from "@fastify/cors";
import Fastify from "fastify";
import { loadConfig } from "./config/env.js";
import { setSignRepository } from "./repositories/active-sign-repository.js";
import { createSignRepository } from "./repositories/create-sign-repository.js";
import { categoryRoutes } from "./routes/categories.js";
import { signRoutes } from "./routes/signs.js";

const apiDirectory = dirname(fileURLToPath(import.meta.url));
loadDotenv({ path: join(apiDirectory, "../../../.env") });

const appConfig = loadConfig();
const signRepository = createSignRepository(appConfig);
setSignRepository(signRepository);

const server = Fastify({ logger: true });

await server.register(cors, { origin: true });

server.get("/health", async () => {
  return {
    status: "ok",
    dataSource: appConfig.dataSource,
  };
});

await server.register(categoryRoutes);
await server.register(signRoutes);

const shutdown = async () => {
  await signRepository.close();
  await server.close();
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

try {
  await server.listen({ port: appConfig.port, host: appConfig.host });
  server.log.info(`Data source: ${appConfig.dataSource}`);
} catch (error) {
  server.log.error(error);
  process.exit(1);
}

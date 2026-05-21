import { config as loadDotenv } from "dotenv";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { loadConfig } from "./config/env.js";
import { createServer } from "./create-server.js";
import { createSignRepository } from "./repositories/create-sign-repository.js";

const apiDirectory = dirname(fileURLToPath(import.meta.url));
loadDotenv({ path: join(apiDirectory, "../../../.env") });

const appConfig = loadConfig();
const signRepository = createSignRepository(appConfig);
const server = await createServer({
  dataSource: appConfig.dataSource,
  signRepository,
  enableMedia: true,
  logger: true,
  corsOrigin: appConfig.corsOrigin,
});

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

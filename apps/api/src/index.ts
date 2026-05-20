import Fastify from "fastify";
import { signRoutes } from "./routes/signs.js";

const port = Number(process.env.PORT ?? 3000);
const host = process.env.HOST ?? "0.0.0.0";

const server = Fastify({ logger: true });

server.get("/health", async () => {
  return { status: "ok" };
});

await server.register(signRoutes);

try {
  await server.listen({ port, host });
} catch (error) {
  server.log.error(error);
  process.exit(1);
}

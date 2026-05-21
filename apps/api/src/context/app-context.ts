import type { FastifyBaseLogger } from "fastify";
import type { DataSource } from "../config/env.js";
import type { SignRepository } from "../repositories/sign-repository.js";

export interface AppContext {
  signRepository: SignRepository;
  dataSource: DataSource;
  log: FastifyBaseLogger;
}

declare module "fastify" {
  interface FastifyRequest {
    app: AppContext;
    _appContext?: AppContext;
  }
}

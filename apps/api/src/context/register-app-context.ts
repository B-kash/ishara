import type { FastifyInstance, FastifyRequest } from "fastify";
import type { DataSource } from "../config/env.js";
import type { SignRepository } from "../repositories/sign-repository.js";
import type { AppContext } from "./app-context.js";
import "./app-context.js";

export interface RegisterAppContextOptions {
  signRepository: SignRepository;
  dataSource: DataSource;
}

export async function registerAppContext(
  server: FastifyInstance,
  options: RegisterAppContextOptions,
): Promise<void> {
  const { signRepository, dataSource } = options;

  server.decorateRequest("app", {
    getter(this: FastifyRequest): AppContext {
      if (!this._appContext) {
        throw new Error("Request app context is not initialized.");
      }

      return this._appContext;
    },
    setter(this: FastifyRequest, value: AppContext) {
      this._appContext = value;
    },
  });

  server.addHook("onRequest", async (request) => {
    request.app = {
      signRepository,
      dataSource,
      log: request.log,
    };
  });
}

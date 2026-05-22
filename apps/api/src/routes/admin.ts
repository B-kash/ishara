import multipart from "@fastify/multipart";
import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { parseSignRecordsFromCsv } from "../data/sign-import-csv.js";
import {
  createAdminSessionToken,
  validateAdminCredentials,
  type AdminAuthConfig,
} from "../admin/admin-auth.js";
import { createRequireAdminAuth } from "../admin/require-admin-auth.js";
import {
  databaseErrorResponse,
  internalErrorResponse,
  unauthorizedErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
import { DrizzleSignRepository } from "../repositories/drizzle-sign-repository.js";
import {
  createSignBodyToImportRecord,
  validateCreateSignRequestBody,
} from "../validation/admin-sign-validation.js";

export interface RegisterAdminRoutesOptions {
  adminAuth: AdminAuthConfig;
}

interface AdminLoginBody {
  username?: string;
  password?: string;
}

function adminRequiresPostgres(
  request: FastifyRequest,
  reply: FastifyReply,
): DrizzleSignRepository | null {
  if (request.app.dataSource !== "postgres") {
    reply
      .status(503)
      .send(
        validationErrorResponse(
          "Admin sign management requires DATA_SOURCE=postgres.",
        ),
      );
    return null;
  }

  const signRepository = request.app.signRepository;
  if (!(signRepository instanceof DrizzleSignRepository)) {
    reply.status(503).send(internalErrorResponse("Database repository unavailable."));
    return null;
  }

  return signRepository;
}

export async function adminRoutes(
  server: FastifyInstance,
  options: RegisterAdminRoutesOptions,
): Promise<void> {
  const { adminAuth } = options;
  const requireAdminAuth = createRequireAdminAuth(adminAuth);

  await server.register(multipart, {
    limits: {
      fileSize: 5 * 1024 * 1024,
      files: 1,
    },
  });

  server.post("/admin/login", async (request, reply) => {
    const body = request.body as AdminLoginBody;
    const username = body.username?.trim() ?? "";
    const password = body.password ?? "";

    if (!username || !password) {
      return reply
        .status(400)
        .send(validationErrorResponse("Username and password are required."));
    }

    if (!validateAdminCredentials(username, password, adminAuth)) {
      return reply
        .status(401)
        .send(unauthorizedErrorResponse("Invalid username or password."));
    }

    const token = createAdminSessionToken(
      username,
      adminAuth.sessionSecret,
      adminAuth.sessionTtlMs,
    );

    return {
      token,
      expiresAt: new Date(Date.now() + adminAuth.sessionTtlMs).toISOString(),
      username,
    };
  });

  server.get(
    "/admin/session",
    { preHandler: requireAdminAuth },
    async (request) => {
      return {
        username: request.adminSession?.username ?? adminAuth.username,
      };
    },
  );

  server.get(
    "/admin/categories",
    { preHandler: requireAdminAuth },
    async (request, reply) => {
      try {
        const categories = await request.app.signRepository.getAllCategories();
        return { items: categories };
      } catch (error) {
        request.app.log.error(error);
        return reply.status(503).send(databaseErrorResponse());
      }
    },
  );

  server.post(
    "/admin/signs",
    { preHandler: requireAdminAuth },
    async (request, reply) => {
      const postgresRepository = adminRequiresPostgres(request, reply);
      if (!postgresRepository) {
        return;
      }

      const bodyResult = validateCreateSignRequestBody(request.body);
      if (!bodyResult.ok) {
        return reply.status(400).send(validationErrorResponse(bodyResult.message));
      }

      try {
        const outcome = await postgresRepository.importSignRecord(
          createSignBodyToImportRecord(bodyResult.value),
        );

        return reply.status(outcome.status === "inserted" ? 201 : 200).send({
          outcome,
        });
      } catch (error) {
        request.app.log.error(error);

        if (error instanceof Error) {
          return reply.status(400).send(validationErrorResponse(error.message));
        }

        return reply.status(500).send(internalErrorResponse());
      }
    },
  );

  server.post(
    "/admin/signs/bulk",
    { preHandler: requireAdminAuth },
    async (request, reply) => {
      const postgresRepository = adminRequiresPostgres(request, reply);
      if (!postgresRepository) {
        return;
      }

      try {
        const contentType = request.headers["content-type"] ?? "";

        if (contentType.includes("multipart/form-data")) {
          const upload = await request.file();
          if (!upload) {
            return reply
              .status(400)
              .send(validationErrorResponse("Upload a CSV or JSON file."));
          }

          const fileBuffer = await upload.toBuffer();
          const fileText = fileBuffer.toString("utf8");
          const fileName = upload.filename.toLowerCase();

          if (fileName.endsWith(".csv")) {
            const rawRecords = parseSignRecordsFromCsv(fileText);
            const result = await postgresRepository.bulkImportSignRecords(rawRecords);

            return reply
              .status(result.failed > 0 ? 400 : 200)
              .send({ result });
          }

          if (fileName.endsWith(".json")) {
            const parsedJson = JSON.parse(fileText) as unknown;
            if (!Array.isArray(parsedJson)) {
              return reply
                .status(400)
                .send(
                  validationErrorResponse(
                    "JSON file must contain an array of sign records.",
                  ),
                );
            }

            const result = await postgresRepository.bulkImportSignRecords(parsedJson);
            return reply
              .status(result.failed > 0 ? 400 : 200)
              .send({ result });
          }

          return reply
            .status(400)
            .send(validationErrorResponse("Only .csv and .json files are supported."));
        }

        const jsonBody = request.body as { records?: unknown };
        if (!jsonBody || !Array.isArray(jsonBody.records)) {
          return reply
            .status(400)
            .send(
              validationErrorResponse(
                'Send multipart file upload or JSON body { "records": [...] }.',
              ),
            );
        }

        const result = await postgresRepository.bulkImportSignRecords(
          jsonBody.records,
        );

        return reply.status(result.failed > 0 ? 400 : 200).send({ result });
      } catch (error) {
        request.app.log.error(error);

        if (error instanceof SyntaxError) {
          return reply.status(400).send(validationErrorResponse("Invalid JSON file."));
        }

        if (error instanceof Error) {
          return reply.status(400).send(validationErrorResponse(error.message));
        }

        return reply.status(500).send(internalErrorResponse());
      }
    },
  );
}

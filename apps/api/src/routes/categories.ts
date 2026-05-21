import type { FastifyInstance, FastifyRequest } from "fastify";
import {
  databaseErrorResponse,
  notFoundErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
import { getSignRepository } from "../repositories/active-sign-repository.js";
import { toSignSearchResult } from "../mappers/sign-response.js";
import {
  validateRouteId,
  validateSearchLanguageParam,
} from "../validation/request-validation.js";

interface CategoryRouteParams {
  id: string;
}

function getLanguageParam(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["lang"];
}

export async function categoryRoutes(server: FastifyInstance) {
  server.get("/categories", async (request, reply) => {
    try {
      const signRepository = getSignRepository();
      const categories = await signRepository.getAllCategories();
      return { items: categories };
    } catch (error) {
      request.log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/categories/:id/signs", async (request, reply) => {
    const routeParams = request.params as CategoryRouteParams;
    const categoryIdResult = validateRouteId(routeParams.id, "Category");
    if (!categoryIdResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(categoryIdResult.message));
    }

    const languageResult = validateSearchLanguageParam(
      getLanguageParam(request),
    );
    if (!languageResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(languageResult.message));
    }

    try {
      const signRepository = getSignRepository();
      const category = await signRepository.getCategoryById(
        categoryIdResult.value,
      );
      if (!category) {
        return reply
          .status(404)
          .send(notFoundErrorResponse("Category not found"));
      }

      const signRecords = await signRepository.getSignRecordsByCategoryId(
        categoryIdResult.value,
      );
      const items = (signRecords ?? []).map((signRecord) =>
        toSignSearchResult(signRecord, languageResult.value),
      );

      return { items };
    } catch (error) {
      request.log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });
}

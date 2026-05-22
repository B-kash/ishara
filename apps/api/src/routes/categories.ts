import type { FastifyInstance, FastifyRequest } from "fastify";
import {
  databaseErrorResponse,
  notFoundErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
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
    const { signRepository, log } = request.app;

    try {
      const categories = await signRepository.getAllCategories();
      return {
        items: categories.map((category) => ({
          id: category.id,
          name: category.name,
        })),
      };
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/categories/:id/signs", async (request, reply) => {
    const { signRepository, log } = request.app;
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
      const category = await signRepository.getCategoryById(
        categoryIdResult.value,
      );
      if (!category) {
        return reply
          .status(404)
          .send(notFoundErrorResponse("Category not found"));
      }

      const signGraphs = await signRepository.getSignGraphsByCategoryId(
        categoryIdResult.value,
      );
      const items = (signGraphs ?? []).map((signGraph) =>
        toSignSearchResult(signGraph, languageResult.value),
      );

      return { items };
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });
}

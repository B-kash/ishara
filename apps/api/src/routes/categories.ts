import type { FastifyInstance, FastifyRequest } from "fastify";
import { getSignRepository } from "../repositories/active-sign-repository.js";
import { parseSearchLanguage } from "../data/sign-search.js";
import { toSignSearchResult } from "../mappers/sign-response.js";
import type { ApiErrorResponse } from "../types/api-responses.js";

interface CategoryRouteParams {
  id: string;
}

function getLanguageParam(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["lang"];
}

export async function categoryRoutes(server: FastifyInstance) {
  server.get("/categories", async () => {
    const signRepository = getSignRepository();
    const categories = await signRepository.getAllCategories();
    return { items: categories };
  });

  server.get("/categories/:id/signs", async (request, reply) => {
    const { id: categoryId } = request.params as CategoryRouteParams;
    const languageParam = getLanguageParam(request);

    const searchLanguage = parseSearchLanguage(languageParam);
    if (!searchLanguage) {
      const errorBody: ApiErrorResponse = {
        error: "Query parameter lang must be en or ne",
      };
      return reply.status(400).send(errorBody);
    }

    const signRepository = getSignRepository();
    const category = await signRepository.getCategoryById(categoryId);
    if (!category) {
      const errorBody: ApiErrorResponse = { error: "Category not found" };
      return reply.status(404).send(errorBody);
    }

    const signRecords =
      await signRepository.getSignRecordsByCategoryId(categoryId);
    const items = (signRecords ?? []).map((signRecord) =>
      toSignSearchResult(signRecord, searchLanguage),
    );

    return { items };
  });
}

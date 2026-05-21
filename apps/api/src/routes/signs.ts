import type { FastifyInstance, FastifyRequest } from "fastify";
import {
  databaseErrorResponse,
  notFoundErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
import { getSignRepository } from "../repositories/active-sign-repository.js";
import { toSignDetail, toSignSearchResult } from "../mappers/sign-response.js";
import {
  validateRequiredQueryParam,
  validateRouteId,
  validateSearchLanguageParam,
} from "../validation/request-validation.js";

interface SignRouteParams {
  id: string;
}

function getSearchQuery(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["q"];
}

function getLanguageParam(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["lang"];
}

export async function signRoutes(server: FastifyInstance) {
  server.get("/signs/search", async (request, reply) => {
    const searchQueryResult = validateRequiredQueryParam(
      getSearchQuery(request),
      "q",
    );
    if (!searchQueryResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(searchQueryResult.message));
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
      const matchedRecords = await signRepository.searchSignRecords(
        searchQueryResult.value,
        languageResult.value,
      );
      const items = matchedRecords.map((signRecord) =>
        toSignSearchResult(signRecord, languageResult.value),
      );

      return { items };
    } catch (error) {
      request.log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/signs/:id", async (request, reply) => {
    const routeParams = request.params as SignRouteParams;
    const signIdResult = validateRouteId(routeParams.id, "Sign");
    if (!signIdResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(signIdResult.message));
    }

    try {
      const signRepository = getSignRepository();
      const signRecord = await signRepository.getSignById(signIdResult.value);

      if (!signRecord) {
        return reply
          .status(404)
          .send(notFoundErrorResponse("Sign not found"));
      }

      return toSignDetail(signRecord);
    } catch (error) {
      request.log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });
}

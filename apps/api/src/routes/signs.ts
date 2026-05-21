import type { FastifyInstance, FastifyRequest } from "fastify";
import { detectDisplayLanguage } from "../data/sign-search-matching.js";
import {
  databaseErrorResponse,
  notFoundErrorResponse,
  validationErrorResponse,
} from "../errors/api-error.js";
import { toSignDetail, toSignSearchResult } from "../mappers/sign-response.js";
import {
  validateRequiredQueryParam,
  validateRouteId,
} from "../validation/request-validation.js";

interface SignRouteParams {
  id: string;
}

function getSearchQuery(request: FastifyRequest): string | undefined {
  const queryValue = request.query as Record<string, string | undefined>;
  return queryValue["q"];
}

export async function signRoutes(server: FastifyInstance) {
  server.get("/signs/search", async (request, reply) => {
    const { signRepository, log } = request.app;

    const searchQueryResult = validateRequiredQueryParam(
      getSearchQuery(request),
      "q",
    );
    if (!searchQueryResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(searchQueryResult.message));
    }

    try {
      const matchedRecords = await signRepository.searchSignRecords(
        searchQueryResult.value,
      );
      const displayLanguage = detectDisplayLanguage(searchQueryResult.value);
      const items = matchedRecords.map((signRecord) =>
        toSignSearchResult(signRecord, displayLanguage),
      );

      return { items };
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });

  server.get("/signs/:id", async (request, reply) => {
    const { signRepository, log } = request.app;
    const routeParams = request.params as SignRouteParams;
    const signIdResult = validateRouteId(routeParams.id, "Sign");
    if (!signIdResult.ok) {
      return reply
        .status(400)
        .send(validationErrorResponse(signIdResult.message));
    }

    try {
      const signRecord = await signRepository.getSignById(signIdResult.value);

      if (!signRecord) {
        return reply
          .status(404)
          .send(notFoundErrorResponse("Sign not found"));
      }

      return toSignDetail(signRecord);
    } catch (error) {
      log.error(error);
      return reply.status(503).send(databaseErrorResponse());
    }
  });
}

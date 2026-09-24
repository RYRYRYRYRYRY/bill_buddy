import type { FastifyInstance, FastifyReply } from "fastify";

import type { BillerCategory } from "./biller.types.js";
import { BillerRepository } from "./biller.repository.js";
import {
  BillerService,
  BillerServiceError,
} from "./biller.service.js";

const billerService = new BillerService(
  new BillerRepository(),
);

const validBillerCategories: BillerCategory[] = [
  "electricity",
  "water",
  "gas",
  "broadband",
];

function sendServiceError(
  reply: FastifyReply,
  error: unknown,
) {
  if (error instanceof BillerServiceError) {
    return reply
      .code(error.statusCode)
      .send({
        error: {
          code: error.code,
          message: error.message,
        },
      });
  }

  throw error;
}

export async function billerRoutes(
  app: FastifyInstance,
) {
  // GET /api/v1/biller-categories
  app.get(
    "/biller-categories",
    async (_request, reply) => {
      return reply.send({
        categories: billerService.getCategories(),
      });
    },
  );

  // GET /api/v1/billers
  app.get(
    "/billers",
    async (request, reply) => {
      const query = request.query as {
        category?: string;
        q?: string;
        state?: string;
      };

      let category: BillerCategory | undefined;

      if (query.category) {
        if (
          !validBillerCategories.includes(
            query.category as BillerCategory,
          )
        ) {
          return reply.code(400).send({
            error: {
              code: "INVALID_CATEGORY",
              message: "Invalid biller category.",
            },
          });
        }

        category =
          query.category as BillerCategory;
      }

      const billers =
        billerService.getBillers({
          category,
          query: query.q,
          state: query.state,
        });

      return reply.send({
        billers,
      });
    },
  );

  // GET /api/v1/billers/:id
  app.get(
    "/billers/:id",
    async (request, reply) => {
      const { id } = request.params as {
        id: string;
      };

      try {
        const biller =
          billerService.getBillerById(id);

        return reply.send(biller);
      } catch (error) {
        return sendServiceError(
          reply,
          error,
        );
      }
    },
  );

  // POST /api/v1/my-billers
  app.post(
    "/my-billers",
    async (request, reply) => {
      await request.jwtVerify();

      const userId = request.user.sub;

      const body = request.body as {
        billerId?: string;
        nickname?: string;
        params?: Record<string, string>;
      };

      if (
        !body.billerId ||
        !body.nickname ||
        !body.params
      ) {
        return reply.code(422).send({
          error: {
            code: "VALIDATION_ERROR",
            message:
              "billerId, nickname and params are required.",
          },
        });
      }

      try {
        const saved =
          billerService.saveBiller({
            userId,
            billerId: body.billerId,
            nickname: body.nickname,
            params: body.params,
          });

        return reply
          .code(201)
          .send(saved);
      } catch (error) {
        return sendServiceError(
          reply,
          error,
        );
      }
    },
  );
}
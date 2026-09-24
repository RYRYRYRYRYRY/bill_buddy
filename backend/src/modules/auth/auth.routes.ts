import type { FastifyInstance } from "fastify";
import { z } from "zod";

import { AuthService } from "./auth.service.js";
import type { JwtPayload } from "./auth.types.js";

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export async function authRoutes(
  app: FastifyInstance,
) {
  const authService = new AuthService(app);

  app.post(
    "/register",
    async (request, reply) => {
      try {
        const body =
          credentialsSchema.parse(request.body);

        const result =
          await authService.register(
            body.email,
            body.password,
          );

        return reply.code(201).send(result);
      } catch (error) {
        return handleAuthError(
          error,
          reply,
        );
      }
    },
  );

  app.post(
    "/login",
    {
      config: {
        rateLimit: {
          max: 5,
          timeWindow: "1 minute",
        },
      },
    },
    async (request, reply) => {
      try {
        const body =
          credentialsSchema.parse(request.body);

        const result =
          await authService.login(
            body.email,
            body.password,
          );

        return reply.send(result);
      } catch (error) {
        return handleAuthError(
          error,
          reply,
        );
      }
    },
  );

  app.post(
    "/refresh",
    async (request, reply) => {
      try {
        const body =
          refreshSchema.parse(request.body);

        const result =
          await authService.refresh(
            body.refreshToken,
          );

        return reply.send(result);
      } catch (error) {
        return handleAuthError(
          error,
          reply,
        );
      }
    },
  );

  app.post(
    "/logout",
    async (request, reply) => {
      try {
        const body =
          refreshSchema.parse(request.body);

        const result =
          authService.logout(
            body.refreshToken,
          );

        return reply.send(result);
      } catch (error) {
        return handleAuthError(
          error,
          reply,
        );
      }
    },
  );

  app.get(
    "/me",
    async (request, reply) => {
      try {
        await request.jwtVerify();

        const user =
          request.user as JwtPayload;

        const result =
          await authService.getCurrentUser(
            user.sub,
          );

        return reply.send(result);
      } catch (error) {
        if (
          error instanceof Error &&
          error.message === "USER_NOT_FOUND"
        ) {
          return reply.code(404).send({
            error: {
              code: "USER_NOT_FOUND",
              message: "User not found",
            },
          });
        }

        return reply.code(401).send({
          error: {
            code: "UNAUTHORIZED",
            message: "Authentication required",
          },
        });
      }
    },
  );
}

function handleAuthError(
  error: unknown,
  reply: {
    code: (statusCode: number) => {
      send: (payload: unknown) => unknown;
    };
  },
) {
  if (error instanceof z.ZodError) {
    return reply.code(400).send({
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid request",
      },
    });
  }

  if (
    error instanceof Error &&
    error.message === "EMAIL_ALREADY_EXISTS"
  ) {
    return reply.code(409).send({
      error: {
        code: "EMAIL_ALREADY_EXISTS",
        message: "An account with this email already exists",
      },
    });
  }

  if (
    error instanceof Error &&
    error.message === "INVALID_CREDENTIALS"
  ) {
    return reply.code(401).send({
      error: {
        code: "INVALID_CREDENTIALS",
        message: "Invalid email or password",
      },
    });
  }

  if (
    error instanceof Error &&
    (
      error.message === "INVALID_REFRESH_TOKEN" ||
      error.message === "REFRESH_TOKEN_EXPIRED"
    )
  ) {
    return reply.code(401).send({
      error: {
        code: error.message,
        message: "Refresh token is invalid or expired",
      },
    });
  }

  return reply.code(500).send({
    error: {
      code: "INTERNAL_ERROR",
      message: "Something went wrong",
    },
  });
}
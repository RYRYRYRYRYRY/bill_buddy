import Fastify from "fastify";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import jwt from "@fastify/jwt";

import { env } from "./config/env.js";
import { authRoutes } from "./modules/auth/auth.routes.js";
import { billerRoutes } from "./modules/billers/biller.routes.js";

export function buildApp() {
  const app = Fastify({
    logger: true,
  });

  app.register(helmet);

  app.register(cors, {
    origin: true,
    methods: [
      "GET",
      "POST",
      "PUT",
      "PATCH",
      "DELETE",
      "OPTIONS",
    ],
  });

  app.register(rateLimit, {
    max: 100,
    timeWindow: "1 minute",
  });

  app.register(jwt, {
    secret: env.JWT_SECRET,
  });

  app.get("/health", async () => {
    return {
      status: "ok",
    };
  });

  app.register(authRoutes, {
    prefix: "/api/v1/auth",
  });

  app.register(billerRoutes, {
    prefix: "/api/v1",
  });

  return app;
}
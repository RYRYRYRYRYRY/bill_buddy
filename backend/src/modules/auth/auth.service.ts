import type { FastifyInstance } from "fastify";
import { randomBytes } from "node:crypto";
import { z } from "zod";

import {
  authRepository,
  type UserRecord,
} from "./auth.repository.js";

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

export class AuthService {
  constructor(private readonly app: FastifyInstance) {}

  async register(email: string, password: string) {
    const input = credentialsSchema.parse({
      email,
      password,
    });

    const existingUser =
      authRepository.findUserByEmail(input.email);

    if (existingUser) {
      throw new Error("EMAIL_ALREADY_EXISTS");
    }

    const user = authRepository.createUser(
      input.email,
      input.password,
    );

    return this.createAuthResponse(user);
  }

  async login(email: string, password: string) {
    const input = credentialsSchema.parse({
      email,
      password,
    });

    const user =
      authRepository.findUserByEmail(input.email);

    if (!user) {
      throw new Error("INVALID_CREDENTIALS");
    }

    const passwordValid =
      authRepository.verifyPassword(
        input.password,
        user.passwordHash,
      );

    if (!passwordValid) {
      throw new Error("INVALID_CREDENTIALS");
    }

    return this.createAuthResponse(user);
  }

  async refresh(refreshToken: string) {
    if (!refreshToken) {
      throw new Error("INVALID_REFRESH_TOKEN");
    }

    const session =
      authRepository.findSessionByRefreshToken(
        refreshToken,
      );

    if (!session) {
      throw new Error("INVALID_REFRESH_TOKEN");
    }

    if (
      new Date(session.expiresAt).getTime() <=
      Date.now()
    ) {
      authRepository.deleteSession(session.id);

      throw new Error("REFRESH_TOKEN_EXPIRED");
    }

    const user =
      authRepository.findUserById(session.userId);

    if (!user) {
      authRepository.deleteSession(session.id);

      throw new Error("USER_NOT_FOUND");
    }

    const newRefreshToken =
      this.generateRefreshToken();

    const refreshExpiresAt =
      this.getRefreshExpiry();

    authRepository.rotateSession(
      session.id,
      newRefreshToken,
      refreshExpiresAt,
    );

    const accessToken =
      await this.createAccessToken(user);

    return {
      accessToken,
      refreshToken: newRefreshToken,
      user: this.toPublicUser(user),
    };
  }

  logout(refreshToken: string) {
    const session =
      authRepository.findSessionByRefreshToken(
        refreshToken,
      );

    if (session) {
      authRepository.deleteSession(session.id);
    }

    return {
      success: true,
    };
  }

  async getCurrentUser(userId: string) {
    const user =
      authRepository.findUserById(userId);

    if (!user) {
      throw new Error("USER_NOT_FOUND");
    }

    return this.toPublicUser(user);
  }

  private async createAuthResponse(
    user: UserRecord,
  ) {
    const accessToken =
      await this.createAccessToken(user);

    const refreshToken =
      this.generateRefreshToken();

    const refreshExpiresAt =
      this.getRefreshExpiry();

    authRepository.createSession(
      user.id,
      refreshToken,
      refreshExpiresAt,
    );

    return {
      accessToken,
      refreshToken,
      user: this.toPublicUser(user),
    };
  }

  private async createAccessToken(
    user: UserRecord,
  ): Promise<string> {
    return this.app.jwt.sign(
      {
        sub: user.id,
      },
      {
        expiresIn: "15m",
      },
    );
  }

  private generateRefreshToken(): string {
    return randomBytes(48).toString("base64url");
  }

  private getRefreshExpiry(): string {
    const expiresAt = new Date();

    expiresAt.setDate(
      expiresAt.getDate() + 30,
    );

    return expiresAt.toISOString();
  }

  private toPublicUser(user: UserRecord) {
    return {
      id: user.id,
      email: user.email,
    };
  }
}
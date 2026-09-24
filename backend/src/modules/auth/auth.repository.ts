import {
  randomBytes,
  randomUUID,
  scryptSync,
  timingSafeEqual,
  createHash,
} from "node:crypto";

export interface UserRecord {
  id: string;
  email: string;
  passwordHash: string;
  createdAt: string;
}

export interface SessionRecord {
  id: string;
  userId: string;
  refreshTokenHash: string;
  createdAt: string;
  expiresAt: string;
}

export class AuthRepository {
  private readonly users = new Map<string, UserRecord>();
  private readonly sessions = new Map<string, SessionRecord>();

  findUserByEmail(email: string): UserRecord | undefined {
    return this.users.get(email.toLowerCase());
  }

  findUserById(userId: string): UserRecord | undefined {
    for (const user of this.users.values()) {
      if (user.id === userId) {
        return user;
      }
    }

    return undefined;
  }

  createUser(
    email: string,
    password: string,
  ): UserRecord {
    const normalizedEmail = email.toLowerCase();

    const passwordHash = this.hashPassword(password);

    const user: UserRecord = {
      id: randomUUID(),
      email: normalizedEmail,
      passwordHash,
      createdAt: new Date().toISOString(),
    };

    this.users.set(normalizedEmail, user);

    return user;
  }

  verifyPassword(
    password: string,
    passwordHash: string,
  ): boolean {
    const [salt, storedHash] = passwordHash.split(":");

    if (!salt || !storedHash) {
      return false;
    }

    const derivedKey = scryptSync(password, salt, 64);

    const storedKey = Buffer.from(storedHash, "hex");

    if (derivedKey.length !== storedKey.length) {
      return false;
    }

    return timingSafeEqual(derivedKey, storedKey);
  }

  createSession(
    userId: string,
    refreshToken: string,
    expiresAt: string,
  ): SessionRecord {
    const session: SessionRecord = {
      id: randomUUID(),
      userId,
      refreshTokenHash: this.hashToken(refreshToken),
      createdAt: new Date().toISOString(),
      expiresAt,
    };

    this.sessions.set(session.id, session);

    return session;
  }

  findSessionByRefreshToken(
    refreshToken: string,
  ): SessionRecord | undefined {
    const refreshTokenHash = this.hashToken(refreshToken);

    for (const session of this.sessions.values()) {
      if (session.refreshTokenHash === refreshTokenHash) {
        return session;
      }
    }

    return undefined;
  }

  rotateSession(
    sessionId: string,
    newRefreshToken: string,
    expiresAt: string,
  ): SessionRecord | undefined {
    const session = this.sessions.get(sessionId);

    if (!session) {
      return undefined;
    }

    session.refreshTokenHash = this.hashToken(newRefreshToken);
    session.expiresAt = expiresAt;

    return session;
  }

  deleteSession(sessionId: string): void {
    this.sessions.delete(sessionId);
  }

  private hashPassword(password: string): string {
    const salt = randomBytes(16).toString("hex");

    const hash = scryptSync(password, salt, 64).toString("hex");

    return `${salt}:${hash}`;
  }

  private hashToken(token: string): string {
    return createHash("sha256")
      .update(token)
      .digest("hex");
  }
}

export const authRepository = new AuthRepository();
import {
  BillerRepository,
  type BillerListFilters,
} from "./biller.repository.js";

import type {
  BillerCategory,
  SavedBiller,
} from "./biller.types.js";

export class BillerServiceError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly statusCode: number,
  ) {
    super(message);
    this.name = "BillerServiceError";
  }
}

export class BillerService {
  constructor(
    private readonly repository: BillerRepository,
  ) {}

  getCategories(): BillerCategory[] {
    return this.repository.getCategories();
  }

  getBillers(
    filters: BillerListFilters = {},
  ) {
    return this.repository.getBillers(filters);
  }

  getBillerById(id: string) {
    const biller =
      this.repository.getBillerById(id);

    if (!biller) {
      throw new BillerServiceError(
        "BILLER_NOT_FOUND",
        "Biller not found.",
        404,
      );
    }

    return biller;
  }

  saveBiller({
    userId,
    billerId,
    nickname,
    params,
  }: {
    userId: string;
    billerId: string;
    nickname: string;
    params: Record<string, string>;
  }): SavedBiller {
    const biller =
      this.repository.getBillerById(billerId);

    if (!biller) {
      throw new BillerServiceError(
        "BILLER_NOT_FOUND",
        "Biller not found.",
        404,
      );
    }

    const trimmedNickname =
      nickname.trim();

    if (!trimmedNickname) {
      throw new BillerServiceError(
        "VALIDATION_ERROR",
        "Nickname is required.",
        422,
      );
    }

    for (const field of biller.fields) {
      const value = params[field.key];

      if (
        value == null ||
        value.trim() == '' 
      ) {
        throw new BillerServiceError(
          "VALIDATION_ERROR",
          `${field.label} is required.`,
          422,
        );
      }

      let regex: RegExp;

      try {
        regex = new RegExp(field.regex);
      } catch {
        throw new BillerServiceError(
          "INVALID_BILLER_DEFINITION",
          "Biller validation configuration is invalid.",
          500,
        );
      }

      if (!regex.test(value)) {
        throw new BillerServiceError(
          "VALIDATION_ERROR",
          `${field.label} is invalid.`,
          422,
        );
      }
    }

    const savedBiller: SavedBiller = {
      id: crypto.randomUUID(),
      userId,
      billerId,
      nickname: trimmedNickname,
      params,
      autopay: {
        enabled: false,
        maxPaise: 0,
      },
    };

    return this.repository.saveBiller(
      savedBiller,
    );
  }
}
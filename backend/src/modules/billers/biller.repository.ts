import type {
  Biller,
  BillerCategory,
  SavedBiller,
} from "./biller.types.js";

const billers: Biller[] = [
  {
    id: "demo-electricity",
    name: "Demo Electricity Board",
    category: "electricity",
    state: "MH",
    fields: [
      {
        key: "consumerNumber",
        label: "Consumer Number",
        regex: "^[0-9]{8,12}$",
      },
    ],
    allowsPartial: true,
  },
  {
    id: "mumbai-power",
    name: "Mumbai Power",
    category: "electricity",
    state: "MH",
    fields: [
      {
        key: "consumerNumber",
        label: "Consumer Number",
        regex: "^[0-9]{10}$",
      },
    ],
    allowsPartial: false,
  },
  {
    id: "demo-water",
    name: "Demo Water Board",
    category: "water",
    state: "MH",
    fields: [
      {
        key: "accountNumber",
        label: "Account Number",
        regex: "^[0-9]{8,12}$",
      },
    ],
    allowsPartial: false,
  },
  {
    id: "demo-gas",
    name: "Demo Gas",
    category: "gas",
    state: "MH",
    fields: [
      {
        key: "consumerNumber",
        label: "Consumer Number",
        regex: "^[0-9]{8,12}$",
      },
    ],
    allowsPartial: true,
  },
  {
    id: "demo-broadband",
    name: "Demo Broadband",
    category: "broadband",
    state: "MH",
    fields: [
      {
        key: "accountId",
        label: "Account ID",
        regex: "^[A-Za-z0-9]{6,16}$",
      },
    ],
    allowsPartial: false,
  },
];

const savedBillers = new Map<string, SavedBiller>();

export interface BillerListFilters {
  category?: BillerCategory;
  query?: string;
  state?: string;
}

export class BillerRepository {
  getCategories(): BillerCategory[] {
    return [
      ...new Set(
        billers.map((biller) => biller.category),
      ),
    ];
  }

  getBillers(
    filters: BillerListFilters = {},
  ): Biller[] {
    const query =
      filters.query?.trim().toLowerCase();

    return billers.filter((biller) => {
      if (
        filters.category &&
        biller.category !== filters.category
      ) {
        return false;
      }

      if (
        filters.state &&
        biller.state !== filters.state
      ) {
        return false;
      }

      if (
        query &&
        !biller.name
          .toLowerCase()
          .includes(query)
      ) {
        return false;
      }

      return true;
    });
  }

  getBillerById(
    id: string,
  ): Biller | undefined {
    return billers.find(
      (biller) => biller.id === id,
    );
  }

  saveBiller(
    savedBiller: SavedBiller,
  ): SavedBiller {
    savedBillers.set(
      savedBiller.id,
      savedBiller,
    );

    return savedBiller;
  }

  getSavedBillerById(
    userId: string,
    id: string,
  ): SavedBiller | undefined {
    return [...savedBillers.values()].find(
      (saved) =>
        saved.userId === userId &&
        saved.id === id,
    );
  }

  getSavedBillers(
    userId: string,
  ): SavedBiller[] {
    return [...savedBillers.values()].filter(
      (saved) => saved.userId === userId,
    );
  }
}
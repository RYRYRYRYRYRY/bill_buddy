export type BillerCategory =
  | "electricity"
  | "water"
  | "gas"
  | "broadband";

export interface BillerField {
  key: string;
  label: string;
  regex: string;
}

export interface Biller {
  id: string;
  name: string;
  category: BillerCategory;
  state: string;
  fields: BillerField[];
  allowsPartial: boolean;
}

export interface SavedBiller {
  id: string;
  userId: string;
  billerId: string;
  nickname: string;
  params: Record<string, string>;
  autopay: {
    enabled: boolean;
    maxPaise: number;
  };
}
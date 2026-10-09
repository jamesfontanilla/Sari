export type ProductKind = "rice" | "can" | "bottle" | "noodles" | "soda" | "coffee";

export type AvatarLook = { bg: string; hair: string; shirt: string; long?: boolean };

export type Product = {
  id: string;
  name: string;
  kind: ProductKind;
  category: string;
  unit: string; // plural, e.g. "cans"; UI singularizes when qty is 1
  qty: number;
  threshold: number; // low stock when qty <= threshold
  buyPrice: number;
  sellPrice: number;
  lastRestocked: number;
  aliases: string[];
};

export type Customer = {
  id: string;
  name: string;
  nickname?: string;
  look: AvatarLook;
  createdAt: number;
};

export type TxType = "sale" | "restock" | "utang_add" | "utang_payment";

export type TxItem = { productId: string; qty: number; unitPrice: number };

export type Transaction = {
  id: string;
  type: TxType;
  amount: number;
  timestamp: number;
  customerId?: string;
  items: TxItem[];
  notes?: string;
};

/** A parsed, not-yet-saved transaction (output of the parser, input of the store). */
export type Intent = {
  type: TxType;
  customerId?: string;
  customerName?: string; // set when the customer is new
  amount: number;
  items: TxItem[];
  notes?: string;
  balanceAfter?: number; // payments only
};

export type ChatMessage = {
  id: string;
  from: "user" | "sari";
  text: string; // supports **bold**
  tip?: string;
  timestamp: number;
  pending?: Intent;
  status?: "saved" | "cancelled";
};

/** Money put into the business (e.g. the first supply). */
export type CapitalEntry = { id: string; amount: number; timestamp: number; note: string };

export type AppState = {
  version: number;
  products: Product[];
  customers: Customer[];
  transactions: Transaction[];
  chat: ChatMessage[];
  onboarded: boolean;
  capital: CapitalEntry[];
  /** Overall revenue typed for a day (key = String(start-of-day timestamp)). */
  dailyRevenue: Record<string, number>;
};

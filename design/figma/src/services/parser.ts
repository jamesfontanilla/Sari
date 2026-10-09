import { balanceOf } from "../data/selectors";
import type { AppState, Intent, TxItem, TxType } from "../data/types";
import { peso } from "./format";

export type ParseResult = { intent: Intent } | { error: string };

const NUMBER_WORDS: Record<string, number> = {
  isa: 1, dalawa: 2, tatlo: 3, apat: 4, lima: 5, anim: 6, pito: 7, walo: 8, siyam: 9, sampu: 10,
  limampu: 50, isandaan: 100, sandaan: 100, dalawandaan: 200, limandaan: 500,
};

const HONORIFICS = new Set(["mang", "aling", "kuya", "ate", "tito", "tita", "lola", "lolo"]);
const UNITS = "(?:pcs?|piraso|lata|packs?|bote|sachets?)";
const esc = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

function normalize(text: string): string {
  let t = text.toLowerCase().replace(/[“”"']/g, " ");
  t = t.replace(/₱\s*(\d+)/g, "$1 pesos");
  t = t.replace(/(\d+)\s*(?:php|pesos?|piso)\b/g, "$1 pesos");
  t = t.replace(/\b[a-zñ]+\b/g, (w) => (w in NUMBER_WORDS ? String(NUMBER_WORDS[w]) : w));
  t = t.replace(/[^a-z0-9ñ ]+/g, " ").replace(/\s+/g, " ").trim();
  return t;
}

function detectType(t: string): TxType | null {
  if (/\b(bayad|nagbayad|binayaran|bayaran)\b/.test(t)) return "utang_payment";
  if (/\b(utang|inutang|pautang)\b/.test(t)) return "utang_add";
  if (/\b(restock|dumating|nag restock)\b/.test(t)) return "restock";
  if (/\b(benta|nabenta|nagbenta|bumili|binili|nagbili)\b/.test(t)) return "sale";
  return null;
}

const titleCase = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

function findCustomer(t: string, state: AppState): { id?: string; name?: string } {
  for (const c of state.customers) {
    const names = [c.name, c.nickname].filter(Boolean).map((n) => n!.toLowerCase());
    if (names.some((n) => new RegExp(`\\b${esc(n)}\\b`).test(t))) return { id: c.id, name: c.name };
  }
  const m = t.match(/\b(?:si|ni|kay)\s+(.+)/);
  if (m) {
    // First word after si/ni/kay that is not an honorific (mang, aling, ...) or a number.
    const name = m[1].split(" ").find((w) => !HONORIFICS.has(w) && !/^\d+$/.test(w));
    if (name) return { name: titleCase(name) };
  }
  return {};
}

export function parseCommand(text: string, state: AppState): ParseResult {
  const t = normalize(text);
  const type = detectType(t);
  if (!type) return { error: "unknown" };

  // Products and their quantities.
  const items: TxItem[] = [];
  const consumed = new Set<number>();
  for (const p of state.products) {
    for (const alias of [...p.aliases].sort((a, b) => b.length - a.length)) {
      const re = new RegExp(`(?:\\b(\\d+)\\s*${UNITS}?\\s+)?\\b${esc(alias)}\\b`);
      const m = re.exec(t);
      if (!m) continue;
      let qty = 1;
      if (m[1] && parseInt(m[1], 10) <= 50) {
        qty = parseInt(m[1], 10);
        consumed.add(m.index);
      }
      if (!items.some((i) => i.productId === p.id)) {
        items.push({ productId: p.id, qty, unitPrice: type === "restock" ? p.buyPrice : p.sellPrice });
      }
      break;
    }
  }

  // Amount: "N pesos" wins; otherwise the first number that is not a quantity.
  let amount = 0;
  const pesos = /(\d+) pesos/.exec(t);
  if (pesos) {
    amount = parseInt(pesos[1], 10);
  } else {
    for (const m of t.matchAll(/\b\d+\b/g)) {
      if (!consumed.has(m.index!)) {
        amount = parseInt(m[0], 10);
        break;
      }
    }
  }
  if (items.length === 0 && pesos === null) {
    // Numbers that are still attached to an item slot cannot be amounts.
    amount = amount || 0;
  }
  const itemsTotal = items.reduce((s, i) => s + i.qty * i.unitPrice, 0);
  const { id: customerId, name: customerName } = findCustomer(t, state);

  if (type === "utang_payment") {
    if (!customerName) return { error: "Kanino galing ang bayad?" };
    if (!customerId) return { error: `Hindi ko kilala si ${customerName}.` };
    const balance = balanceOf(state.transactions, customerId);
    if (balance <= 0) return { error: `Walang utang si ${customerName}.` };
    if (amount <= 0) return { error: "Magkano ang binayad?" };
    const paid = Math.min(amount, balance);
    return { intent: { type, customerId, amount: paid, items: [], balanceAfter: balance - paid } };
  }

  if (type === "utang_add") {
    if (!customerName) return { error: "Kanino ang utang?" };
    const total = amount || itemsTotal;
    if (total <= 0) return { error: "Magkano ang utang?" };
    return { intent: { type, customerId, customerName: customerId ? undefined : customerName, amount: total, items } };
  }

  if (items.length === 0) return { error: type === "sale" ? "Anong paninda ang nabenta?" : "Anong paninda ang na-restock?" };
  const total = amount || itemsTotal;
  return { intent: { type, amount: total, items } };
}

export const TYPE_LABEL: Record<TxType, string> = {
  sale: "Benta",
  utang_add: "Utang",
  utang_payment: "Bayad",
  restock: "Restock",
};

export function itemsText(items: TxItem[], state: AppState): string {
  return items
    .map((i) => {
      const name = state.products.find((p) => p.id === i.productId)?.name ?? i.productId;
      return i.qty > 1 ? `${name} ×${i.qty}` : name;
    })
    .join(", ");
}

/** Sari's confirmation line after saving a transaction. */
export function confirmationText(intent: Intent, state: AppState): string {
  const who = intent.customerName ?? state.customers.find((c) => c.id === intent.customerId)?.name ?? "";
  const list = itemsText(intent.items, state);
  switch (intent.type) {
    case "utang_add":
      return `Okay, na-record ko na! Si ${who}, utang ${intent.amount} pesos${list ? ` — ${list}` : ""}.`;
    case "utang_payment":
      return `Salamat! Bayad ni ${who}: ${peso(intent.amount)}. Natitira: ${peso(intent.balanceAfter ?? 0)}.`;
    case "sale":
      return `Na-record ko na ang benta: ${list} — ${peso(intent.amount)}.`;
    case "restock":
      return `Na-restock na: ${list}.`;
  }
}

export const SAMPLE_COMMANDS = [
  "Si Juan, utang 150 pesos, sardinas at bigas",
  "Benta ko ngayon, 3 sardinas 45 pesos",
  "Bayad ni Maria, 200 pesos",
];

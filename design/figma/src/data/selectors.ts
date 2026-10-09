import type { AppState, Customer, Product, Transaction } from "./types";

export const DAY = 86_400_000;

export const startOfDay = (ts: number) => {
  const d = new Date(ts);
  d.setHours(0, 0, 0, 0);
  return d.getTime();
};

export type AgingLevel = "ok" | "warn" | "late";

export function balanceOf(txs: Transaction[], customerId: string): number {
  let bal = 0;
  for (const t of txs) {
    if (t.customerId !== customerId) continue;
    if (t.type === "utang_add") bal += t.amount;
    if (t.type === "utang_payment") bal -= t.amount;
  }
  return Math.max(bal, 0);
}

export function lastPaymentOf(txs: Transaction[], customerId: string): number | undefined {
  let last: number | undefined;
  for (const t of txs) {
    if (t.customerId === customerId && t.type === "utang_payment" && (last === undefined || t.timestamp > last)) {
      last = t.timestamp;
    }
  }
  return last;
}

export function lifetimeCredit(txs: Transaction[], customerId: string): number {
  return txs.filter((t) => t.customerId === customerId && t.type === "utang_add").reduce((s, t) => s + t.amount, 0);
}

/** Days since the last payment, or since the first utang if never paid. null when nothing is owed. */
export function agingDays(txs: Transaction[], customerId: string, now: number): number | null {
  if (balanceOf(txs, customerId) <= 0) return null;
  const last = lastPaymentOf(txs, customerId);
  let since = last;
  if (since === undefined) {
    for (const t of txs) {
      if (t.customerId === customerId && t.type === "utang_add" && (since === undefined || t.timestamp < since)) {
        since = t.timestamp;
      }
    }
  }
  if (since === undefined) return 0;
  return Math.max(Math.floor((now - since) / DAY), 0);
}

export function agingLevel(days: number | null): AgingLevel {
  if (days === null || days < 7) return "ok";
  return days < 21 ? "warn" : "late";
}

export function agingLabel(days: number | null, hasPaid: boolean): string {
  if (days === null) return "Bayad na";
  if (!hasPaid && days < 7) return "Bagong utang";
  const span = days >= 14 ? `${Math.floor(days / 7)} weeks` : days <= 0 ? "ngayon pa lang" : `${days} araw`;
  return days <= 0 ? "Bagong utang" : `${span} na walang bayad`;
}

export function salesOn(state: AppState, dayStart: number): number {
  return state.transactions
    .filter((t) => t.type === "sale" && t.timestamp >= dayStart && t.timestamp < dayStart + DAY)
    .reduce((s, t) => s + t.amount, 0);
}

export function saleCountOn(state: AppState, dayStart: number): number {
  return state.transactions.filter((t) => t.type === "sale" && t.timestamp >= dayStart && t.timestamp < dayStart + DAY).length;
}

export function profitOn(state: AppState, dayStart: number): number {
  const buy = new Map(state.products.map((p) => [p.id, p.buyPrice]));
  let profit = 0;
  for (const t of state.transactions) {
    if (t.type !== "sale" || t.timestamp < dayStart || t.timestamp >= dayStart + DAY) continue;
    for (const i of t.items) profit += (i.unitPrice - (buy.get(i.productId) ?? 0)) * i.qty;
  }
  return profit;
}

/** Percent change of today's sales vs. yesterday's, or null when there is no baseline. */
export function trendPercent(state: AppState, now: number): number | null {
  const today = startOfDay(now);
  const y = salesOn(state, today - DAY);
  if (y <= 0) return null;
  return Math.round(((salesOn(state, today) - y) / y) * 100);
}

export function unitsSold(state: AppState, from: number, to: number): Map<string, number> {
  const map = new Map<string, number>();
  for (const t of state.transactions) {
    if (t.type !== "sale" || t.timestamp < from || t.timestamp >= to) continue;
    for (const i of t.items) map.set(i.productId, (map.get(i.productId) ?? 0) + i.qty);
  }
  return map;
}

export function topSeller(state: AppState, from: number, to: number): { product: Product; qty: number } | null {
  let best: { product: Product; qty: number } | null = null;
  for (const [id, qty] of unitsSold(state, from, to)) {
    const product = state.products.find((p) => p.id === id);
    if (product && (!best || qty > best.qty)) best = { product, qty };
  }
  return best;
}

export const lowStock = (state: AppState): Product[] =>
  state.products.filter((p) => p.qty <= p.threshold).sort((a, b) => a.qty - b.qty);

export type Debtor = { customer: Customer; balance: number; days: number | null };

export function debtors(state: AppState, now: number): Debtor[] {
  return state.customers
    .map((customer) => ({
      customer,
      balance: balanceOf(state.transactions, customer.id),
      days: agingDays(state.transactions, customer.id, now),
    }))
    .filter((d) => d.balance > 0)
    .sort((a, b) => b.balance - a.balance);
}

export const totalUtang = (state: AppState, now: number) => debtors(state, now).reduce((s, d) => s + d.balance, 0);

/** Consecutive days, ending today (or yesterday if nothing yet today), with at least one recorded transaction. */
export function streakDays(state: AppState, now: number): number {
  const days = new Set(state.transactions.map((t) => startOfDay(t.timestamp)));
  let day = startOfDay(now);
  if (!days.has(day)) day -= DAY;
  let n = 0;
  while (days.has(day)) {
    n++;
    day -= DAY;
  }
  return n;
}

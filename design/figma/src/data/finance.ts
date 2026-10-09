import { DAY, startOfDay } from "./selectors";
import type { AppState, Transaction } from "./types";

export type CapitalRow = { id: string; kind: "entry" | "restock"; amount: number; timestamp: number; note: string };

/** Capital entries plus restock purchases (which are also money put into stock), newest first. */
export function capitalRows(state: AppState): CapitalRow[] {
  const rows: CapitalRow[] = state.capital.map((e) => ({ id: e.id, kind: "entry", amount: e.amount, timestamp: e.timestamp, note: e.note }));
  for (const t of state.transactions) {
    if (t.type === "restock" && t.amount > 0) {
      rows.push({ id: t.id, kind: "restock", amount: t.amount, timestamp: t.timestamp, note: t.notes || "Restock" });
    }
  }
  return rows.sort((a, b) => b.timestamp - a.timestamp);
}

export const totalCapital = (state: AppState) => capitalRows(state).reduce((s, r) => s + r.amount, 0);

/** Recorded sale transactions grouped by the start of their day. */
function salesByDay(state: AppState): Map<number, Transaction[]> {
  const map = new Map<number, Transaction[]>();
  for (const t of state.transactions) {
    if (t.type !== "sale") continue;
    const k = startOfDay(t.timestamp);
    map.set(k, [...(map.get(k) ?? []), t]);
  }
  return map;
}

const sumAmount = (txs: Transaction[] | undefined) => (txs ?? []).reduce((s, t) => s + t.amount, 0);

/** The overall revenue the user typed for a day, if any. */
export const typedRevenue = (state: AppState, day: number): number | undefined => state.dailyRevenue[String(day)];

/** Revenue of a day: the typed figure if there is one (it replaces the recorded sales), otherwise the recorded sales. */
export function dayRevenue(state: AppState, day: number, byDay: Map<number, Transaction[]> = salesByDay(state)): number {
  return typedRevenue(state, day) ?? sumAmount(byDay.get(day));
}

export const recordedRevenue = (state: AppState, day: number): number => sumAmount(salesByDay(state).get(day));

/** Benta: the revenue of every day that has recorded sales or a typed figure. */
export function totalRevenue(state: AppState): number {
  const byDay = salesByDay(state);
  const days = new Set<number>([...byDay.keys(), ...Object.keys(state.dailyRevenue).map(Number)]);
  let sum = 0;
  for (const d of days) sum += dayRevenue(state, d, byDay);
  return sum;
}

export type ProfitSummary = { capital: number; revenue: number; kita: number; roi: number | null };

/** Kita = Benta − Puhunan, with the return on capital. */
export function profitSummary(state: AppState): ProfitSummary {
  const capital = totalCapital(state);
  const revenue = totalRevenue(state);
  const kita = revenue - capital;
  return { capital, revenue, kita, roi: capital > 0 ? Math.round((kita / capital) * 100) : null };
}

/** Profit on the items sold (recorded sales only) on one day. */
function dayProfit(state: AppState, txs: Transaction[] | undefined): number {
  const buy = new Map(state.products.map((p) => [p.id, p.buyPrice]));
  let profit = 0;
  for (const t of txs ?? []) for (const i of t.items) profit += (i.unitPrice - (buy.get(i.productId) ?? 0)) * i.qty;
  return profit;
}

/** Revenue and item profit over the days in [from, to) (both at day boundaries). */
function windowTotals(state: AppState, from: number, to: number, byDay: Map<number, Transaction[]>) {
  let sales = 0;
  let profit = 0;
  for (let d = from; d < to; d += DAY) {
    sales += dayRevenue(state, d, byDay);
    profit += dayProfit(state, byDay.get(d));
  }
  return { sales, profit };
}

export const growthPercent = (now: number, previous: number): number | null =>
  previous > 0 ? Math.round(((now - previous) / previous) * 100) : null;

export type PeriodSummary = { revenue: number; profit: number; growth: number | null };

/** Last `days` days versus the `days` before them. */
export function periodSummary(state: AppState, now: number, days: number): PeriodSummary {
  const byDay = salesByDay(state);
  const end = startOfDay(now) + DAY;
  const cur = windowTotals(state, end - days * DAY, end, byDay);
  const prev = windowTotals(state, end - 2 * days * DAY, end - days * DAY, byDay);
  return { revenue: cur.sales, profit: cur.profit, growth: growthPercent(cur.sales, prev.sales) };
}

export type WeekBucket = { start: number; sales: number; profit: number };

/** `n` windows of 7 days ending today, oldest first. */
export function weeklyBuckets(state: AppState, now: number, n = 8): WeekBucket[] {
  const byDay = salesByDay(state);
  const end = startOfDay(now) + DAY;
  const out: WeekBucket[] = [];
  for (let i = n - 1; i >= 0; i--) {
    const to = end - i * 7 * DAY;
    const from = to - 7 * DAY;
    out.push({ start: from, ...windowTotals(state, from, to, byDay) });
  }
  return out;
}

/** This week's sales growth versus last week. */
export function weeklyGrowth(buckets: WeekBucket[]): number | null {
  if (buckets.length < 2) return null;
  return growthPercent(buckets[buckets.length - 1].sales, buckets[buckets.length - 2].sales);
}

export type DayLog = {
  start: number;
  /** Revenue of the day (typed figure if any, otherwise the recorded sales). */
  sales: number;
  /** Recorded sales only. */
  recorded: number;
  /** True when the user typed the day's overall revenue. */
  typed: boolean;
  count: number;
  profit: number;
  top: { name: string; qty: number } | null;
  txs: Transaction[];
};

function dayLogFor(state: AppState, start: number, byDay: Map<number, Transaction[]>): DayLog {
  const txs = [...(byDay.get(start) ?? [])].sort((a, b) => b.timestamp - a.timestamp);
  const units = new Map<string, number>();
  for (const t of txs) for (const i of t.items) units.set(i.productId, (units.get(i.productId) ?? 0) + i.qty);
  let top: DayLog["top"] = null;
  for (const [id, qty] of units) {
    const name = state.products.find((p) => p.id === id)?.name;
    if (name && (!top || qty > top.qty)) top = { name, qty };
  }
  return {
    start,
    sales: dayRevenue(state, start, byDay),
    recorded: sumAmount(txs),
    typed: typedRevenue(state, start) !== undefined,
    count: txs.length,
    profit: dayProfit(state, txs),
    top,
    txs,
  };
}

/** One entry per day for the last `days` days, newest first (days without sales included). */
export function dailyLog(state: AppState, now: number, days = 30): DayLog[] {
  const byDay = salesByDay(state);
  const today = startOfDay(now);
  return Array.from({ length: days }, (_, i) => dayLogFor(state, today - i * DAY, byDay));
}

export type WeekLog = {
  start: number;
  end: number; // last day of the window (start of that day)
  sales: number;
  count: number;
  profit: number;
  growth: number | null;
  bestDay: DayLog | null;
  days: DayLog[]; // newest first
};

/** The last `weeks` 7-day windows (same windows as the growth graph), newest first. */
export function weeklyLog(state: AppState, now: number, weeks = 8): WeekLog[] {
  const byDay = salesByDay(state);
  const today = startOfDay(now);
  const out: WeekLog[] = [];
  for (let w = 0; w < weeks; w++) {
    const days = Array.from({ length: 7 }, (_, i) => dayLogFor(state, today - (w * 7 + i) * DAY, byDay));
    const best = days.reduce<DayLog | null>((b, d) => (d.sales > 0 && (!b || d.sales > b.sales) ? d : b), null);
    out.push({
      start: today - (w * 7 + 6) * DAY,
      end: today - w * 7 * DAY,
      sales: days.reduce((s, d) => s + d.sales, 0),
      count: days.reduce((s, d) => s + d.count, 0),
      profit: days.reduce((s, d) => s + d.profit, 0),
      growth: null,
      bestDay: best,
      days,
    });
  }
  return out.map((wk, i) => ({ ...wk, growth: i + 1 < out.length ? growthPercent(wk.sales, out[i + 1].sales) : null }));
}

export type CalendarCell = { day: number; revenue: number; typed: boolean; recorded: number; trend: "up" | "down" | null } | null;

/** A month grid (Linggo first). `null` cells pad the start of the first week. */
export function monthGrid(state: AppState, year: number, month: number): { cells: CalendarCell[]; total: number } {
  const byDay = salesByDay(state);
  const first = new Date(year, month, 1);
  const count = new Date(year, month + 1, 0).getDate();
  const cells: CalendarCell[] = Array.from({ length: first.getDay() }, () => null);
  let total = 0;
  // The first day that has any revenue has nothing to compare with, so it gets no arrow.
  const firstDay = Math.min(Infinity, ...byDay.keys(), ...Object.keys(state.dailyRevenue).map(Number));
  for (let d = 1; d <= count; d++) {
    const day = startOfDay(new Date(year, month, d).getTime());
    const recorded = sumAmount(byDay.get(day));
    const typed = typedRevenue(state, day) !== undefined;
    const revenue = typedRevenue(state, day) ?? recorded;
    total += revenue;
    let trend: "up" | "down" | null = null;
    if ((typed || revenue > 0) && day > firstDay) {
      const prev = dayRevenue(state, startOfDay(new Date(year, month, d - 1).getTime()), byDay);
      trend = revenue > prev ? "up" : revenue < prev ? "down" : null;
    }
    cells.push({ day, revenue, typed, recorded, trend });
  }
  return { cells, total };
}

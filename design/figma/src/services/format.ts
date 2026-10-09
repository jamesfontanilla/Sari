import { DAY, startOfDay } from "../data/selectors";
import type { Product } from "../data/types";

export const peso = (n: number) => `${n < 0 ? "−" : ""}₱${Math.abs(Math.round(n)).toLocaleString("en-PH")}`;

export function dayLabel(ts: number, now: number): string {
  const diff = Math.round((startOfDay(now) - startOfDay(ts)) / DAY);
  if (diff <= 0) return "Ngayon";
  if (diff === 1) return "Kahapon";
  return new Date(ts).toLocaleDateString("en-PH", { month: "short", day: "numeric", year: "numeric" });
}

export const timeLabel = (ts: number) =>
  new Date(ts).toLocaleTimeString("en-PH", { hour: "numeric", minute: "2-digit" });

export const shortDate = (ts: number) =>
  new Date(ts).toLocaleDateString("en-PH", { month: "short", day: "numeric", year: "numeric" });

export function greeting(now: number): string {
  const h = new Date(now).getHours();
  if (h < 12) return "Magandang umaga";
  if (h < 18) return "Magandang hapon";
  return "Magandang gabi";
}

/** "1 can" / "6 cans": singular when the quantity is 1. */
export const qtyLabel = (qty: number, p: Pick<Product, "unit">) =>
  `${qty} ${qty === 1 ? p.unit.replace(/s$/, "") : p.unit}`;

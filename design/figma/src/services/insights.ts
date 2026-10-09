import {
  DAY,
  agingLevel,
  debtors,
  lowStock,
  profitOn,
  salesOn,
  startOfDay,
  topSeller,
  totalUtang,
  trendPercent,
} from "../data/selectors";
import type { AppState, Intent } from "../data/types";
import { greeting, peso } from "./format";
import { profitSummary, weeklyBuckets, weeklyGrowth } from "../data/finance";
import { parseCommand } from "./parser";

export type Reply = {
  text: string;
  tip?: string;
  pending?: Intent;
  pose?: "confused";
};

const agingPhrase = (days: number | null) =>
  days === null ? "" : days >= 14 ? `${Math.floor(days / 7)} weeks na walang bayad` : `${days} araw na walang bayad`;

/** One short, actionable nudge: low stock first, then the oldest unpaid utang. */
export function nudge(state: AppState, now: number): string | null {
  const low = lowStock(state)[0];
  if (low) return `Heads up — ${low.qty} na lang ${low.name} mo. Pag-restock na siguro bukas?`;
  const late = debtors(state, now)
    .filter((d) => agingLevel(d.days) !== "ok")
    .sort((a, b) => (b.days ?? 0) - (a.days ?? 0))[0];
  if (late) return `Si ${late.customer.name}, ${agingPhrase(late.days)}. Total utang: ${peso(late.balance)}.`;
  return null;
}

export function dailySummary(state: AppState, now: number): { text: string; nudge: string | null } {
  const today = startOfDay(now);
  const sales = salesOn(state, today);
  const yesterday = salesOn(state, today - DAY);
  const profit = profitOn(state, today);
  const diff = sales - yesterday;
  let line = `${greeting(now)}! Kinita mo ngayon: **${peso(sales)}**.`;
  if (yesterday > 0) {
    line += diff >= 0 ? ` Mas mataas ng ${peso(diff)} kaysa kahapon! 💪` : ` Mas mababa ng ${peso(-diff)} kaysa kahapon. Kaya pa 'yan!`;
  }
  if (sales > 0) line += ` Tantyang tubo: ${peso(profit)}.`;
  return { text: line, nudge: nudge(state, now) };
}

function salesAnswer(state: AppState, now: number): Reply {
  const today = startOfDay(now);
  const sales = salesOn(state, today);
  const trend = trendPercent(state, now);
  const best = topSeller(state, today, today + DAY);
  if (sales === 0) return { text: "Wala pang benta ngayon, Aling Maria. Simulan na natin! 💪" };
  const trendText =
    trend === null ? "" : trend >= 0 ? ` Mas mataas ito ng ${trend}% kumpara kahapon.` : ` Mas mababa ito ng ${-trend}% kumpara kahapon.`;
  const bestText = best ? ` Ang pinaka-mabenta mo ngayong araw ay ${best.product.name.toLowerCase()}, na may ${best.qty} piraso.` : "";
  const low = lowStock(state)[0];
  return {
    text: `Oo, Aling Maria! 👋\nKita mo ngayon ay **${peso(sales)}**.${trendText}${bestText}\nTantyang tubo: ${peso(profitOn(state, today))}.`,
    tip: low ? `Mag-restock ka na ng ${low.name.toLowerCase()} bago maubos.` : undefined,
  };
}

function topWeekAnswer(state: AppState, now: number): Reply {
  const end = startOfDay(now) + DAY;
  const best = topSeller(state, end - 7 * DAY, end);
  if (!best) return { text: "Wala pa akong nakikitang benta ngayong linggo." };
  return {
    text: `Ang pinaka-mabenta mo this week ay **${best.product.name}** — ${best.qty} piraso ang nabenta.`,
    tip: best.product.qty <= best.product.threshold ? `${best.product.name} ay ${best.product.qty} na lang. Mag-restock ka na!` : undefined,
  };
}

function utangAnswer(state: AppState, now: number, biggestOnly: boolean): Reply {
  const list = debtors(state, now);
  if (list.length === 0) return { text: "Wala kang may utang ngayon. Ang galing! 🎉" };
  const top = list[0];
  if (biggestOnly) {
    return { text: `Si **${top.customer.name}** ang may pinakamalaking utang: **${peso(top.balance)}**.` };
  }
  const total = totalUtang(state, now);
  const oldest = [...list].sort((a, b) => (b.days ?? 0) - (a.days ?? 0))[0];
  return {
    text: `May **${peso(total)}** na utang pa sa tindahan mo, mula sa ${list.length} suki. Si ${top.customer.name} ang pinakamalaki (${peso(top.balance)}).`,
    tip: agingLevel(oldest.days) !== "ok" ? `Si ${oldest.customer.name}, ${agingPhrase(oldest.days)}. Paalalahanan nang mahinahon.` : undefined,
  };
}

function agingAnswer(state: AppState, now: number): Reply {
  const late = debtors(state, now)
    .filter((d) => agingLevel(d.days) !== "ok")
    .sort((a, b) => (b.days ?? 0) - (a.days ?? 0));
  if (late.length === 0) return { text: "Walang matagal nang hindi nagbabayad. Maayos ang listahan mo! 👍" };
  const lines = late.map((d) => `• ${agingLevel(d.days) === "late" ? "🔴" : "🟡"} ${d.customer.name} — ${peso(d.balance)} (${agingPhrase(d.days)})`);
  return { text: `Sila ang matagal nang walang bayad:\n${lines.join("\n")}` };
}

function capitalAnswer(state: AppState, now: number): Reply {
  const s = profitSummary(state);
  if (s.capital <= 0) {
    return { text: "Wala ka pang nailalagay na puhunan. Pumunta sa Talaan › Puhunan at Kita para idagdag ang unang supply mo." };
  }
  const growth = weeklyGrowth(weeklyBuckets(state, now, 8));
  const growthText = growth === null ? "" : growth >= 0 ? ` Ngayong linggo, tumaas ng ${growth}% ang benta mo.` : ` Ngayong linggo, bumaba ng ${-growth}% ang benta mo.`;
  const head = s.kita >= 0
    ? `Puhunan mo: **${peso(s.capital)}**. Benta: **${peso(s.revenue)}**. Kita: **${peso(s.kita)}**${s.roi !== null ? ` (+${s.roi}% balik)` : ""}.`
    : `Puhunan mo: **${peso(s.capital)}**. Benta pa lang: **${peso(s.revenue)}**. Kulang pa ng **${peso(-s.kita)}** para mabawi ang puhunan.`;
  return { text: `${head}${growthText}`, tip: "Buksan ang Puhunan at Kita para makita ang graph kada linggo." };
}

function restockAnswer(state: AppState): Reply {
  const low = lowStock(state);
  if (low.length === 0) return { text: "Sapat pa ang lahat ng paninda mo ngayon. Ayos! ✅" };
  return {
    text: `Kailangan mo nang mag-restock ng ${low.map((p) => `**${p.name}** (${p.qty})`).join(", ")}.`,
    tip: "Pag-restock na siguro bukas ng umaga bago dumami ang bumibili.",
  };
}

/** Routes a chat message: a transaction command, a known question, or a polite "hindi ko na-gets". */
export function routeChat(text: string, state: AppState, now: number): Reply {
  const parsed = parseCommand(text, state);
  if ("intent" in parsed) return { text: "Ito ba ang gusto mong i-record?", pending: parsed.intent };

  const q = text.toLowerCase();
  if (/puhunan|paglago|lumalago|balik/.test(q)) return capitalAnswer(state, now);
  if (/matagal|hindi nagbabayad|walang bayad|aging/.test(q)) return agingAnswer(state, now);
  if (/pinakamalaki.*utang|utang.*pinakamalaki/.test(q)) return utangAnswer(state, now, true);
  if (/utang/.test(q)) return utangAnswer(state, now, false);
  if (/mabenta|best ?seller/.test(q)) return topWeekAnswer(state, now);
  if (/kumikita|kita|tubo|profit|benta/.test(q)) return salesAnswer(state, now);
  if (/restock|stock|ubos|kulang/.test(q)) return restockAnswer(state);

  const error = "error" in parsed && parsed.error !== "unknown" ? parsed.error : null;
  return { text: `${error ? `${error} ` : ""}Sorry, hindi ko na-gets yun. Puwede mo ulitin?`, pose: "confused" };
}

/** One short line for the Home hero card. */
export function shortSummary(state: AppState, now: number): string {
  const today = startOfDay(now);
  const sales = salesOn(state, today);
  const diff = sales - salesOn(state, today - DAY);
  if (sales === 0) return "Wala pang benta ngayon. Tara, simulan natin! 💪";
  if (salesOn(state, today - DAY) <= 0) return `Kinita mo ngayon: **${peso(sales)}**. 💪`;
  return diff >= 0
    ? `Kinita mo ngayon: **${peso(sales)}** — mas mataas ng ${peso(diff)} kaysa kahapon! 💪`
    : `Kinita mo ngayon: **${peso(sales)}** — mas mababa ng ${peso(-diff)} kaysa kahapon. Kaya pa 'yan!`;
}

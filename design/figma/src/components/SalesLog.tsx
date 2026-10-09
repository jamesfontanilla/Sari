import { useState } from "react";
import { TransactionCard } from "./cards";
import Icon from "./Icon";
import { DAY, startOfDay } from "../data/selectors";
import { dailyLog, weeklyLog, type DayLog, type WeekLog } from "../data/finance";
import type { AppState } from "../data/types";
import { peso } from "../services/format";

const month = (ts: number) => new Date(ts).toLocaleDateString("fil-PH", { month: "short" }).replace(".", "").toUpperCase();
const dayNum = (ts: number) => new Date(ts).getDate();
const weekday = (ts: number) => new Date(ts).toLocaleDateString("fil-PH", { weekday: "long" });
const short = (ts: number) => new Date(ts).toLocaleDateString("fil-PH", { month: "short", day: "numeric" });

function dayName(ts: number, now: number): string {
  const diff = Math.round((startOfDay(now) - ts) / DAY);
  if (diff <= 0) return "Ngayon";
  if (diff === 1) return "Kahapon";
  return weekday(ts);
}

function DayRow({ day, now, state, open, onToggle }: { day: DayLog; now: number; state: AppState; open: boolean; onToggle: () => void }) {
  const empty = day.count === 0 && !day.typed;
  return (
    <div className={`log-item ${empty ? "empty" : ""}`}>
      <button aria-expanded={open} className="row tall log-row" disabled={empty} onClick={onToggle} type="button">
        <span className="date-chip">
          <small>{month(day.start)}</small>
          <b>{dayNum(day.start)}</b>
        </span>
        <span className="row-copy">
          <b>
            {dayName(day.start, now)}
            {day.typed && <span aria-label="Ikaw ang naglagay ng kita" className="typed-mark" title="Ikaw ang naglagay ng kita">✎</span>}
          </b>
          <small>
            {empty ? "Walang benta" : day.count === 0 ? "Walang naitalang benta" : `${day.count} benta${day.top ? ` · Pinaka-mabenta: ${day.top.name} ×${day.top.qty}` : ""}`}
          </small>
        </span>
        <span className="log-amount">
          <strong>{peso(day.sales)}</strong>
          {!empty && day.count > 0 && <small>Tubo {peso(day.profit)}</small>}
        </span>
        {!empty && <Icon name="chevron" size={14} stroke={2.6} />}
      </button>
      {open && !empty && (
        <div className="log-detail">
          {day.txs.map((t) => (
            <TransactionCard key={t.id} state={state} tx={t} />
          ))}
        </div>
      )}
    </div>
  );
}

function WeekRow({ week, now, state, open, onToggle }: { week: WeekLog; now: number; state: AppState; open: boolean; onToggle: () => void }) {
  const empty = week.count === 0;
  return (
    <div className={`log-item ${empty ? "empty" : ""}`}>
      <button aria-expanded={open} className="row tall log-row" disabled={empty} onClick={onToggle} type="button">
        <span className="date-chip wide">
          <small>{month(week.start)}</small>
          <b>
            {dayNum(week.start)}–{dayNum(week.end)}
          </b>
        </span>
        <span className="row-copy">
          <b>{short(week.start)} – {short(week.end)}</b>
          <small>
            {empty ? "Walang benta" : `${week.count} benta${week.bestDay ? ` · Pinakamagandang araw: ${weekday(week.bestDay.start)} (${peso(week.bestDay.sales)})` : ""}`}
          </small>
        </span>
        <span className="log-amount">
          <strong>{peso(week.sales)}</strong>
          {!empty && <small>Tubo {peso(week.profit)}</small>}
          {week.growth !== null && <span className={`tag ${week.growth < 0 ? "tag-down" : "tag-up"}`}>{week.growth >= 0 ? "+" : ""}{week.growth}%</span>}
        </span>
        {!empty && <Icon name="chevron" size={14} stroke={2.6} />}
      </button>
      {open && !empty && (
        <div className="log-detail week-days">
          {week.days.map((d) => (
            <div className={`week-day ${d.count === 0 ? "none" : ""}`} key={d.start}>
              <span>{dayName(d.start, now)}</span>
              <small>{d.count === 0 ? "Walang benta" : `${d.count} benta`}</small>
              <b>{peso(d.sales)}</b>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

/** Tiny two-option toggle: Araw | Linggo. */
function ModeToggle({ mode, onChange }: { mode: "day" | "week"; onChange: (m: "day" | "week") => void }) {
  return (
    <span className="mini-toggle" role="tablist">
      <button aria-selected={mode === "day"} className={mode === "day" ? "on" : ""} onClick={() => onChange("day")} role="tab" type="button">
        Araw
      </button>
      <button aria-selected={mode === "week"} className={mode === "week" ? "on" : ""} onClick={() => onChange("week")} role="tab" type="button">
        Linggo
      </button>
    </span>
  );
}

/** Daily or weekly summary of revenue; tap a row to expand it. */
export default function SalesLog({ state, mode, onModeChange }: { state: AppState; mode: "day" | "week"; onModeChange: (m: "day" | "week") => void }) {
  const now = Date.now();
  const [openKey, setOpenKey] = useState<number | null>(null);
  const toggle = (k: number) => setOpenKey((cur) => (cur === k ? null : k));

  if (mode === "day") {
    const days = dailyLog(state, now, 30);
    const total = days.reduce((s, d) => s + d.sales, 0);
    const count = days.reduce((s, d) => s + d.count, 0);
    return (
      <>
        <div className="context-line">
          <p className="header-sum">
            Huling 30 araw: <b>{peso(total)}</b> · {count} benta
          </p>
          <ModeToggle mode={mode} onChange={onModeChange} />
        </div>
        <div className="card list">
          {days.map((d) => (
            <DayRow day={d} key={d.start} now={now} onToggle={() => toggle(d.start)} open={openKey === d.start} state={state} />
          ))}
        </div>
      </>
    );
  }

  const weeks = weeklyLog(state, now, 8);
  const total = weeks.reduce((s, w) => s + w.sales, 0);
  const count = weeks.reduce((s, w) => s + w.count, 0);
  return (
    <>
      <div className="context-line">
        <p className="header-sum">
          Huling 8 linggo: <b>{peso(total)}</b> · {count} benta
        </p>
        <ModeToggle mode={mode} onChange={onModeChange} />
      </div>
      <div className="card list">
        {weeks.map((w) => (
          <WeekRow key={w.start} now={now} onToggle={() => toggle(w.start)} open={openKey === w.start} state={state} week={w} />
        ))}
      </div>
    </>
  );
}

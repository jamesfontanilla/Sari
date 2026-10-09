import { useState } from "react";
import { monthGrid, recordedRevenue, typedRevenue } from "../data/finance";
import { startOfDay } from "../data/selectors";
import type { AppState } from "../data/types";
import { peso } from "../services/format";
import Icon from "./Icon";
import { PillButton } from "./ui";

const WEEKDAYS = ["Li", "Lu", "Ma", "Mi", "Hu", "Bi", "Sa"];

const monthTitle = (y: number, m: number) => new Date(y, m, 1).toLocaleDateString("fil-PH", { month: "long", year: "numeric" });
const longDay = (ts: number) => new Date(ts).toLocaleDateString("fil-PH", { weekday: "long", month: "long", day: "numeric" });

/** 650 → "650", 1200 → "1.2k", 12500 → "12.5k" */
function compact(n: number): string {
  if (n < 1000) return String(Math.round(n));
  const k = n / 1000;
  return `${Number.isInteger(k) ? k : k.toFixed(1)}k`;
}

/** Month calendar: each day shows its revenue; tap a day to type that night's overall revenue. */
export default function RevenueCalendar({ state, onSet }: { state: AppState; onSet: (day: number, amount: number | null) => void }) {
  const now = Date.now();
  const today = startOfDay(now);
  const nowDate = new Date(now);
  const [cursor, setCursor] = useState({ y: nowDate.getFullYear(), m: nowDate.getMonth() });
  const [selected, setSelected] = useState<number | null>(null);
  const [value, setValue] = useState("");

  const { cells, total } = monthGrid(state, cursor.y, cursor.m);
  const isCurrentMonth = cursor.y === nowDate.getFullYear() && cursor.m === nowDate.getMonth();

  const move = (delta: number) => {
    setSelected(null);
    setCursor((c) => {
      const d = new Date(c.y, c.m + delta, 1);
      return { y: d.getFullYear(), m: d.getMonth() };
    });
  };

  const open = (day: number) => {
    setSelected(day);
    const typed = typedRevenue(state, day);
    const recorded = recordedRevenue(state, day);
    setValue(typed !== undefined ? String(typed) : recorded > 0 ? String(recorded) : "");
  };

  const save = () => {
    if (selected === null) return;
    const trimmed = value.trim();
    onSet(selected, trimmed === "" ? null : Math.max(0, Math.floor(Number(trimmed) || 0)));
    setSelected(null);
  };

  return (
    <div className="calendar">
      <div className="cal-head">
        <button aria-label="Nakaraang buwan" className="cal-nav" onClick={() => move(-1)} type="button">
          <Icon name="back" size={18} stroke={2.6} />
        </button>
        <h3>{monthTitle(cursor.y, cursor.m)}</h3>
        <button aria-label="Susunod na buwan" className="cal-nav" disabled={isCurrentMonth} onClick={() => move(1)} type="button">
          <Icon name="chevron" size={18} stroke={2.6} />
        </button>
      </div>

      <div className="card cal-card">
        <div className="cal-grid cal-weekdays">
          {WEEKDAYS.map((w) => (
            <span key={w}>{w}</span>
          ))}
        </div>
        <div className="cal-grid">
          {cells.map((c, i) => {
            if (!c) return <span key={`pad-${i}`} />;
            const future = c.day > today;
            const isToday = c.day === today;
            const label = new Date(c.day).getDate();
            const show = c.typed || c.revenue > 0;
            return (
              <button
                aria-label={`${longDay(c.day)}${show ? `: ${peso(c.revenue)}` : ""}`}
                className={`cal-cell ${isToday ? "today" : ""} ${selected === c.day ? "selected" : ""} ${c.typed ? "typed" : show ? "recorded" : ""}`}
                disabled={future}
                key={c.day}
                onClick={() => open(c.day)}
                type="button"
              >
                <b>{label}</b>
                <small>{show ? compact(c.revenue) : ""}</small>
                {c.trend && (
                  <span aria-label={c.trend === "up" ? "Tumaas kumpara kahapon" : "Bumaba kumpara kahapon"} className={`trend trend-${c.trend}`} role="img">
                    {c.trend === "up" ? "▲" : "▼"}
                  </span>
                )}
              </button>
            );
          })}
        </div>
        <div className="cal-foot">
          <span>
            Kabuuan ngayong buwan: <b>{peso(total)}</b>
          </span>
          <span className="cal-legend">
            <i className="dot-orange" /> Ikaw ang naglagay
            <i className="dot-grey" /> Mula sa benta
            <b className="trend-up">▲</b> <b className="trend-down">▼</b> vs. kahapon
          </span>
        </div>
      </div>

      {selected !== null && (
        <form
          className="card form-card cal-editor"
          onSubmit={(e) => {
            e.preventDefault();
            save();
          }}
        >
          <h4>{longDay(selected)}</h4>
          <label className="field">
            <span>Kabuuang kita ng araw</span>
            <span className="field-input">
              <i>₱</i>
              <input autoFocus aria-label="Kabuuang kita ng araw" inputMode="numeric" min={0} onChange={(e) => setValue(e.target.value)} placeholder="0" type="number" value={value} />
            </span>
          </label>
          <small className="muted">Naitalang benta: {peso(recordedRevenue(state, selected))}. Papalitan ng inilagay mo ang naitala para sa araw na ito.</small>
          <div className="cal-actions">
            <PillButton onClick={save}>I-save</PillButton>
            {typedRevenue(state, selected) !== undefined && (
              <PillButton
                onClick={() => {
                  onSet(selected, null);
                  setSelected(null);
                }}
                variant="secondary"
              >
                Alisin
              </PillButton>
            )}
            <PillButton onClick={() => setSelected(null)} variant="ghost">
              Isara
            </PillButton>
          </div>
        </form>
      )}
    </div>
  );
}

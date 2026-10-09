import { useState } from "react";
import { TransactionCard } from "../components/cards";
import Icon from "../components/Icon";
import Mascot from "../components/Mascot";
import RevenueCalendar from "../components/RevenueCalendar";
import SalesLog from "../components/SalesLog";
import { Segmented, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import { saleCountOn, salesOn, startOfDay } from "../data/selectors";
import type { TxType } from "../data/types";
import type { Nav } from "../nav";
import { dayLabel, peso } from "../services/format";

const FILTERS: { value: "all" | TxType; label: string }[] = [
  { value: "all", label: "Lahat" },
  { value: "sale", label: "Benta" },
  { value: "utang_add", label: "Utang" },
  { value: "utang_payment", label: "Bayad" },
  { value: "restock", label: "Restock" },
];

type View = "list" | "log" | "calendar";

export default function Transactions({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const [filter, setFilter] = useState<"all" | TxType>("all");
  const [view, setView] = useState<View>("calendar");
  const [logMode, setLogMode] = useState<"day" | "week">("day");
  const now = Date.now();
  const today = startOfDay(now);

  const list = [...state.transactions].filter((t) => filter === "all" || t.type === filter).sort((a, b) => b.timestamp - a.timestamp);
  const groups: { label: string; items: typeof list }[] = [];
  for (const t of list) {
    const label = dayLabel(t.timestamp, now);
    const last = groups[groups.length - 1];
    if (last && last.label === label) last.items.push(t);
    else groups.push({ label, items: [t] });
  }

  return (
    <main className="screen has-nav">
      <TopBar
        right={
          <button aria-label="Puhunan at Kita" className="glass-button glass small" onClick={() => nav.go("capital")} type="button">
            <Icon name="chart" size={20} />
          </button>
        }
        title="Talaan"
      />
      <div className="page">
        <div className="view-switch">
          <Segmented
            onChange={setView}
            options={[
              { value: "calendar", label: "Kalendaryo" },
              { value: "log", label: "Log" },
              { value: "list", label: "Transaksyon" },
            ]}
            value={view}
          />
        </div>

        {view === "calendar" && <RevenueCalendar onSet={store.setDayRevenue} state={state} />}

        {view === "log" && <SalesLog mode={logMode} onModeChange={setLogMode} state={state} />}

        {view === "list" && (
          <>
            <div className="context-line">
              <p className="header-sum">
                Benta ngayon <b>{peso(salesOn(state, today))}</b> · {saleCountOn(state, today)} benta
              </p>
              <label className="filter-pill">
                <span className="sr-only">Salain ang transaksyon</span>
                <select aria-label="Salain ang transaksyon" onChange={(e) => setFilter(e.target.value as "all" | TxType)} value={filter}>
                  {FILTERS.map((f) => (
                    <option key={f.value} value={f.value}>
                      {f.label}
                    </option>
                  ))}
                </select>
                <Icon name="chevron" size={12} stroke={3} />
              </label>
            </div>
            {groups.length === 0 ? (
              <div className="empty-state">
                <Mascot pose="empty" size={130} />
                <p>Wala pang transaksyon dito.</p>
              </div>
            ) : (
              groups.map((g) => (
                <section key={g.label}>
                  <h3 className="group-title">{g.label}</h3>
                  <div className="card list">
                    {g.items.map((t) => (
                      <TransactionCard
                        key={t.id}
                        onClick={t.customerId ? () => nav.go("customer", t.customerId) : undefined}
                        state={state}
                        tx={t}
                      />
                    ))}
                  </div>
                </section>
              ))
            )}
          </>
        )}
      </div>
    </main>
  );
}

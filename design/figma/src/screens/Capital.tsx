import { useState } from "react";
import Icon from "../components/Icon";
import { Chip, PillButton, TopBar } from "../components/ui";
import WeeklyChart from "../components/WeeklyChart";
import { capitalRows, periodSummary, profitSummary, weeklyBuckets, weeklyGrowth } from "../data/finance";
import type { Store } from "../data/store";
import type { Nav } from "../nav";
import { peso, shortDate } from "../services/format";

/** A small inline form: amount + note. */
function EntryForm({ title, notePlaceholder, onSave }: { title: string; notePlaceholder: string; onSave: (amount: number, note: string) => void }) {
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");
  const value = Math.floor(Number(amount) || 0);

  const submit = () => {
    if (value <= 0) return;
    onSave(value, note);
    setAmount("");
    setNote("");
  };

  return (
    <form
      className="card form-card entry-form"
      onKeyDown={(e) => {
        if (e.key === "Enter") {
          e.preventDefault();
          submit();
        }
      }}
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
    >
      <h4>{title}</h4>
      <label className="field">
        <span>Halaga</span>
        <span className="field-input">
          <i>₱</i>
          <input aria-label={`${title}: halaga`} inputMode="numeric" min={0} onChange={(e) => setAmount(e.target.value)} placeholder="0" type="number" value={amount} />
        </span>
      </label>
      <label className="field">
        <span>Tala</span>
        <span className="field-input wide">
          <input aria-label={`${title}: tala`} maxLength={40} onChange={(e) => setNote(e.target.value)} placeholder={notePlaceholder} type="text" value={note} />
        </span>
      </label>
      <PillButton disabled={value <= 0} onClick={submit}>
        <Icon name="plus" size={18} stroke={2.6} /> I-save
      </PillButton>
    </form>
  );
}

export default function Capital({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const now = Date.now();
  const [period, setPeriod] = useState<7 | 30>(7);

  const total = profitSummary(state);
  const per = periodSummary(state, now, period);
  const buckets = weeklyBuckets(state, now, 8);
  const growth = weeklyGrowth(buckets);
  const rows = capitalRows(state);
  const loss = total.kita < 0;
  const fill = total.capital > 0 ? Math.min(100, Math.round((total.revenue / total.capital) * 100)) : 0;

  return (
    <main className="screen flow-screen capital-screen">
      <TopBar onBack={nav.back} title="Puhunan at Kita" />
      <div className="page">
        <section className="card kita-card">
          <div className="kita-row">
            <div>
              <span className="kita-label">Puhunan</span>
              <b>{peso(total.capital)}</b>
            </div>
            <div>
              <span className="kita-label">Benta</span>
              <b>{peso(total.revenue)}</b>
            </div>
          </div>
          <div className="kita-total">
            <span className="kita-label">{loss ? "Wala pang kita" : "Kita (Benta − Puhunan)"}</span>
            <strong className={loss ? "neg" : "pos"}>{peso(total.kita)}</strong>
            {total.roi !== null && <span className={`roi ${loss ? "neg" : "pos"}`}>{total.roi >= 0 ? "+" : ""}{total.roi}% balik</span>}
          </div>
          <div aria-label={`Balik-puhunan ${fill}%`} className="progress" role="img">
            <i style={{ width: `${fill}%` }} />
          </div>
          <small className="muted">
            {loss ? `Kulang pa ng ${peso(-total.kita)} para mabawi ang puhunan.` : "Nabawi mo na ang puhunan mo."}
          </small>
        </section>

        <section className="card period-card">
          <div className="period-head">
            <h3>Tubo sa nabenta</h3>
            <div className="chips tight" role="tablist">
              <Chip active={period === 7} onClick={() => setPeriod(7)}>Linggo</Chip>
              <Chip active={period === 30} onClick={() => setPeriod(30)}>Buwan</Chip>
            </div>
          </div>
          <div className="kita-row">
            <div>
              <span className="kita-label">Benta</span>
              <b>{peso(per.revenue)}</b>
            </div>
            <div>
              <span className="kita-label">Tubo</span>
              <b className="pos">{peso(per.profit)}</b>
            </div>
            <div>
              <span className="kita-label">Paglago</span>
              <b className={per.growth !== null && per.growth < 0 ? "neg" : "pos"}>{per.growth === null ? "—" : `${per.growth >= 0 ? "+" : ""}${per.growth}%`}</b>
            </div>
          </div>
          <small className="muted">Hindi kasama ang paninda na hindi pa nabebenta.</small>
        </section>

        <section className="card chart-card">
          <div className="period-head">
            <h3>Paglago kada linggo</h3>
            {growth !== null && <span className={`tag ${growth < 0 ? "tag-down" : "tag-up"}`}>{growth >= 0 ? "+" : ""}{growth}% ngayong linggo</span>}
          </div>
          <WeeklyChart buckets={buckets} />
          <div className="legend">
            <span><i className="dot-orange" /> Benta</span>
            <span><i className="dot-teal" /> Tubo</span>
          </div>
        </section>

        <h3 className="group-title">Puhunan</h3>
        <div className="card list">
          {rows.length === 0 ? (
            <div className="empty-row muted">Wala pang puhunan. Idagdag ang unang supply mo.</div>
          ) : (
            rows.map((r) => (
              <div className="row" key={r.id}>
                <span className={`tx-icon ${r.kind === "restock" ? "tx-restock" : "tx-pay"}`}>
                  <Icon name={r.kind === "restock" ? "box" : "download"} size={18} />
                </span>
                <span className="row-copy">
                  <b>{r.note}</b>
                  <small>{r.kind === "restock" ? "Restock · " : ""}{shortDate(r.timestamp)}</small>
                </span>
                <strong className="amount">{peso(r.amount)}</strong>
                {r.kind === "entry" && (
                  <button aria-label={`Alisin ang ${r.note}`} className="icon-button remove" onClick={() => store.removeCapital(r.id)} type="button">
                    <Icon name="close" size={16} stroke={2.6} />
                  </button>
                )}
              </div>
            ))
          )}
        </div>
        <EntryForm notePlaceholder="hal. Unang supply" onSave={store.addCapital} title="Magdagdag ng puhunan" />


        <h3 className="group-title">Kita kada gabi</h3>
        <button className="card link-card" onClick={() => nav.go("transactions", "calendar")} type="button">
          <span className="row-copy">
            <b>Kalendaryo ng kita</b>
            <small>Ilagay ang kita ng bawat araw</small>
          </span>
          <Icon name="chevron" size={16} />
        </button>
      </div>
    </main>
  );
}

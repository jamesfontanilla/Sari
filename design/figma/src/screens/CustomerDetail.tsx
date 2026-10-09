import { useState } from "react";
import { TransactionCard, aging } from "../components/cards";
import Avatar from "../components/Avatar";
import { PillButton, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import { agingDays, agingLevel, balanceOf, lifetimeCredit } from "../data/selectors";
import type { Nav } from "../nav";
import { peso } from "../services/format";
import { confirmationText } from "../services/parser";

export default function CustomerDetail({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const c = state.customers.find((x) => x.id === nav.route.id);
  const [form, setForm] = useState<"pay" | "add" | null>(null);
  const [amount, setAmount] = useState("");

  if (!c) {
    return (
      <main className="screen">
        <TopBar onBack={nav.back} title="Suki" />
        <p className="page muted">Hindi ko mahanap ang suki.</p>
      </main>
    );
  }

  const now = Date.now();
  const balance = balanceOf(state.transactions, c.id);
  const days = agingDays(state.transactions, c.id, now);
  const level = agingLevel(days);
  const history = state.transactions.filter((t) => t.customerId === c.id).sort((a, b) => b.timestamp - a.timestamp);
  const value = Math.floor(Number(amount) || 0);
  const valid = value > 0 && (form !== "pay" || value <= balance);

  const open = (kind: "pay" | "add") => {
    setForm(kind);
    setAmount(kind === "pay" ? String(balance) : "");
  };

  const submit = () => {
    if (!valid || !form) return;
    const intent = {
      type: form === "pay" ? ("utang_payment" as const) : ("utang_add" as const),
      customerId: c.id,
      amount: value,
      items: [],
      balanceAfter: form === "pay" ? balance - value : undefined,
    };
    store.commit(intent);
    nav.notify(confirmationText(intent, state));
    setForm(null);
  };

  return (
    <main className="screen flow-screen">
      <TopBar onBack={nav.back} title={c.name} />
      <div className="page">
        <section className="customer-hero">
          <Avatar aging={balance > 0 ? level : undefined} look={c.look} size={72} />
          <strong className="big-amount">{peso(balance)}</strong>
          <span className={`pill pill-${level}`}>{aging(days, state, c.id)}</span>
          <p className="muted">Kabuuang nautang: {peso(lifetimeCredit(state.transactions, c.id))}</p>
        </section>

        {form ? (
          <section className="card form-card">
            <label className="field">
              <span>{form === "pay" ? "Magkano ang binayad?" : "Magkano ang dagdag na utang?"}</span>
              <span className="field-input">
                <i>₱</i>
                <input autoFocus inputMode="numeric" min={0} onChange={(e) => setAmount(e.target.value)} type="number" value={amount} />
              </span>
            </label>
            {form === "pay" && value > balance && <p className="error">Hindi puwedeng higit sa utang ({peso(balance)}).</p>}
            <div className="form-actions">
              <PillButton disabled={!valid} onClick={submit}>I-save</PillButton>
              <PillButton onClick={() => setForm(null)} variant="ghost">Kanselahin</PillButton>
            </div>
          </section>
        ) : (
          <div className="detail-actions">
            <PillButton disabled={balance <= 0} onClick={() => open("pay")}>Magbayad</PillButton>
            <PillButton onClick={() => open("add")} variant="secondary">Dagdag utang</PillButton>
          </div>
        )}

        <h3 className="group-title">Kasaysayan</h3>
        <div className="card list">
          {history.length === 0 ? (
            <div className="empty-row muted">Wala pang transaksyon.</div>
          ) : (
            history.map((t) => <TransactionCard key={t.id} showDate state={state} tx={t} />)
          )}
        </div>
      </div>
    </main>
  );
}

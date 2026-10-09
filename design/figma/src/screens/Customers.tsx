import { useState } from "react";
import { CustomerCard } from "../components/cards";
import Mascot from "../components/Mascot";
import { Chip, PillButton, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import { agingDays, balanceOf, totalUtang } from "../data/selectors";
import type { Nav } from "../nav";
import { peso } from "../services/format";

type Filter = "all" | "owing" | "paid";

export default function Customers({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const now = Date.now();
  const [filter, setFilter] = useState<Filter>("all");
  const [adding, setAdding] = useState(false);
  const [name, setName] = useState("");
  const [amount, setAmount] = useState("");
  const [error, setError] = useState("");

  const save = () => {
    const clean = name.trim().replace(/\s+/g, " ");
    if (!clean) return;
    if (state.customers.some((c) => c.name.toLowerCase() === clean.toLowerCase())) {
      setError(`Nandiyan na si ${clean} sa listahan.`);
      return;
    }
    const value = Math.floor(Number(amount) || 0);
    if (value > 0) store.commit({ type: "utang_add", customerName: clean, amount: value, items: [] });
    else store.addCustomer(clean);
    nav.notify(value > 0 ? `Naidagdag si ${clean} — utang ₱${value.toLocaleString("en-PH")}.` : `Naidagdag si ${clean}.`);
    setAdding(false);
    setName("");
    setAmount("");
    setError("");
  };

  const all = state.customers.map((customer) => ({
    customer,
    balance: balanceOf(state.transactions, customer.id),
    days: agingDays(state.transactions, customer.id, now),
  }));
  const owing = all.filter((d) => d.balance > 0);
  const paid = all.filter((d) => d.balance === 0);
  const list = [...(filter === "all" ? all : filter === "owing" ? owing : paid)].sort((a, b) => b.balance - a.balance);

  return (
    <main className="screen has-nav">
      <TopBar title="Utang" />
      <div className="page">
        <div className="context-line">
          <p className="header-sum">
            Kabuuang utang <b>{peso(totalUtang(state, now))}</b> · {owing.length} suki
          </p>
          <button className="add-pill" onClick={() => { setAdding((a) => !a); setError(""); }} type="button">
            {adding ? "Isara" : "+ Magdagdag"}
          </button>
        </div>
        {adding && (
          <form className="card form-card entry-form" onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); save(); } }} onSubmit={(e) => { e.preventDefault(); save(); }}>
            <h4>Magdagdag ng umutang</h4>
            <label className="field">
              <span>Pangalan</span>
              <span className="field-input wide">
                <input aria-label="Pangalan" autoFocus maxLength={30} onChange={(e) => { setName(e.target.value); setError(""); }} placeholder="hal. Mang Pepe" type="text" value={name} />
              </span>
            </label>
            <label className="field">
              <span>Utang ngayon</span>
              <span className="field-input">
                <i>₱</i>
                <input aria-label="Utang ngayon" inputMode="numeric" min={0} onChange={(e) => setAmount(e.target.value)} placeholder="0" type="number" value={amount} />
              </span>
            </label>
            {error && <p className="error">{error}</p>}
            <PillButton disabled={!name.trim()} onClick={save}>I-save</PillButton>
            <PillButton onClick={() => setAdding(false)} variant="ghost">Kanselahin</PillButton>
          </form>
        )}
        <div className="chips" role="tablist">
          <Chip active={filter === "all"} onClick={() => setFilter("all")}>Lahat ({all.length})</Chip>
          <Chip active={filter === "owing"} onClick={() => setFilter("owing")}>May Utang ({owing.length})</Chip>
          <Chip active={filter === "paid"} onClick={() => setFilter("paid")}>Bayad na ({paid.length})</Chip>
        </div>
        <div className="card list">
          {list.length === 0 ? (
            <div className="empty-state">
              <Mascot pose="empty" size={120} />
              <p>Wala pang nakalistang suki dito.</p>
            </div>
          ) : (
            list.map((d) => <CustomerCard debtor={d} key={d.customer.id} onClick={() => nav.go("customer", d.customer.id)} state={state} />)
          )}
        </div>
      </div>
    </main>
  );
}

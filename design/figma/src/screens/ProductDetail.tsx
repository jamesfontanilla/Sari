import { TransactionCard } from "../components/cards";
import ProductArt from "../components/ProductArt";
import { Stepper, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";
import { peso, shortDate } from "../services/format";

function NumberField({ label, value, onChange, prefix }: { label: string; value: number; onChange: (v: number) => void; prefix?: string }) {
  return (
    <label className="field">
      <span>{label}</span>
      <span className="field-input">
        {prefix && <i>{prefix}</i>}
        <input inputMode="numeric" min={0} onChange={(e) => onChange(Math.max(0, Number(e.target.value) || 0))} type="number" value={value} />
      </span>
    </label>
  );
}

export default function ProductDetail({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const p = state.products.find((x) => x.id === nav.route.id);
  if (!p) {
    return (
      <main className="screen">
        <TopBar onBack={nav.back} title="Paninda" />
        <p className="page muted">Hindi ko mahanap ang paninda.</p>
      </main>
    );
  }
  const low = p.qty <= p.threshold;
  const history = state.transactions.filter((t) => t.items.some((i) => i.productId === p.id)).sort((a, b) => b.timestamp - a.timestamp).slice(0, 8);
  const unit = p.unit.replace(/s$/, "");

  return (
    <main className="screen flow-screen">
      <TopBar onBack={nav.back} title={p.name} />
      <div className="page">
        <section className="detail-hero">
          <ProductArt kind={p.kind} size={96} />
          <div>
            <p className="muted">{p.category}</p>
            <span className={`pill ${low ? "pill-low" : "pill-ok"}`}>{low ? "Low stock" : "Sapat"}</span>
          </div>
        </section>

        <section className="card form-card">
          <div className="field">
            <span>Stock ({unit})</span>
            <Stepper label="stock" onChange={(v) => store.updateProduct(p.id, { qty: v })} value={p.qty} />
          </div>
          <NumberField label="Low-stock threshold" onChange={(v) => store.updateProduct(p.id, { threshold: v })} value={p.threshold} />
          <NumberField label="Presyo ng benta" onChange={(v) => store.updateProduct(p.id, { sellPrice: v })} prefix="₱" value={p.sellPrice} />
          <NumberField label="Presyo ng bili" onChange={(v) => store.updateProduct(p.id, { buyPrice: v })} prefix="₱" value={p.buyPrice} />
        </section>

        <p className="header-sum">
          Tubo kada piraso: <b>{peso(p.sellPrice - p.buyPrice)}</b> · Huling restock: {shortDate(p.lastRestocked)}
        </p>

        <h3 className="group-title">Mga transaksyon</h3>
        <div className="card list">
          {history.length === 0 ? (
            <div className="empty-row muted">Wala pang transaksyon para dito.</div>
          ) : (
            history.map((t) => <TransactionCard key={t.id} showDate state={state} tx={t} />)
          )}
        </div>
      </div>
    </main>
  );
}

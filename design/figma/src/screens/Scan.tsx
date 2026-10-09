import { useEffect, useState } from "react";
import CameraCapture, { type ReceiptRow, type ShelfZone } from "../components/CameraCapture";
import Icon from "../components/Icon";
import ProductArt from "../components/ProductArt";
import { PillButton, Segmented, Stepper, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import type { Intent, ProductKind } from "../data/types";
import type { Nav } from "../nav";
import { peso } from "../services/format";

type Mode = "shelf" | "receipt";

const SHELF: { id: string; label: string; kind: ProductKind; count: number }[] = [
  { id: "sardinas", label: "Sardines", kind: "can", count: 5 },
  { id: "noodles", label: "Noodles", kind: "noodles", count: 8 },
  { id: "tansan", label: "Tansan", kind: "bottle", count: 12 },
  { id: "bigas", label: "Bigas", kind: "rice", count: 3 },
];

const RECEIPT: { id: string; name: string; qty: number; unit: number }[] = [
  { id: "sardinas", name: "Sardinas", qty: 24, unit: 20 },
  { id: "bigas", name: "Bigas", qty: 10, unit: 48 },
  { id: "softdrinks", name: "Softdrinks", qty: 12, unit: 16 },
];

export default function Scan({ store, nav }: { store: Store; nav: Nav }) {
  const [mode, setMode] = useState<Mode>(nav.route.id === "receipt" ? "receipt" : "shelf");
  const [detected, setDetected] = useState(false);
  const [counts, setCounts] = useState<Record<string, number>>(() => Object.fromEntries(SHELF.map((s) => [s.id, s.count])));

  useEffect(() => {
    setDetected(false);
    const timer = window.setTimeout(() => setDetected(true), 1600);
    return () => window.clearTimeout(timer);
  }, [mode]);

  const zones: ShelfZone[] = SHELF.map((s) => ({ label: s.label, kind: s.kind, count: counts[s.id] }));
  const receipt: ReceiptRow[] = RECEIPT.map((r) => ({ name: r.name, qty: r.qty, unit: r.unit }));
  const receiptTotal = RECEIPT.reduce((s, r) => s + r.qty * r.unit, 0);

  const save = () => {
    let intent: Intent;
    let message: string;
    if (mode === "shelf") {
      const items = SHELF.filter((s) => counts[s.id] > 0).map((s) => ({ productId: s.id, qty: counts[s.id], unitPrice: 0 }));
      intent = { type: "restock", amount: 0, items, notes: "Shelf scan" };
      message = "Na-update ang inventory mo.";
    } else {
      intent = {
        type: "restock",
        amount: receiptTotal,
        items: RECEIPT.map((r) => ({ productId: r.id, qty: r.qty, unitPrice: r.unit })),
        notes: "Resibo · ABC Wholesale",
      };
      message = `Na-save ang restock mula sa resibo: ${peso(receiptTotal)}.`;
    }
    store.commit(intent);
    nav.back();
    nav.notify(message);
  };

  return (
    <main className="screen scan-screen">
      <TopBar dark onBack={nav.back} title="Scan Inventory" />
      <div className="scan-mode">
        <Segmented
          onChange={setMode}
          options={[
            { value: "shelf", label: "Shelf" },
            { value: "receipt", label: "Resibo" },
          ]}
          value={mode}
        />
      </div>
      <CameraCapture detected={detected} mode={mode} receipt={receipt} zones={zones} />

      <section aria-live="polite" className={`sheet ${detected ? "open" : ""}`}>
        {mode === "shelf" ? (
          <>
            <h2 className="sheet-title">
              <span className="check-fill">
                <Icon name="check" size={14} stroke={3} />
              </span>
              Inventory Updated!
            </h2>
            <ul className="sheet-list">
              {SHELF.map((s) => (
                <li key={s.id}>
                  <ProductArt kind={s.kind} size={26} />
                  <span>{s.label}</span>
                  <Stepper label={s.label} onChange={(v) => setCounts((c) => ({ ...c, [s.id]: v }))} value={counts[s.id]} />
                  <b>+{counts[s.id]}</b>
                </li>
              ))}
            </ul>
            <PillButton onClick={save}>Tapos na</PillButton>
          </>
        ) : (
          <>
            <h2 className="sheet-title">
              <span className="check-fill">
                <Icon name="receipt" size={14} stroke={2.6} />
              </span>
              Nabasa ko ang resibo
            </h2>
            <ul className="sheet-list">
              {RECEIPT.map((r) => (
                <li key={r.id}>
                  <span>
                    {r.qty} × {r.name}
                  </span>
                  <span className="muted">@ {peso(r.unit)}</span>
                  <b>{peso(r.qty * r.unit)}</b>
                </li>
              ))}
              <li className="total-line">
                <span>Kabuuang gastos</span>
                <b>{peso(receiptTotal)}</b>
              </li>
            </ul>
            <PillButton onClick={save}>I-save ang restock</PillButton>
          </>
        )}
      </section>
    </main>
  );
}

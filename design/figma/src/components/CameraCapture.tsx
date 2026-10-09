import type { ProductKind } from "../data/types";
import Mascot from "./Mascot";
import ProductArt from "./ProductArt";

export type ShelfZone = { label: string; kind: ProductKind; count: number };
export type ReceiptRow = { name: string; qty: number; unit: number };

const ZONE_CLASS = ["z1", "z2", "z3", "z4"];

/** Simulated viewfinder. Shelf mode draws detection boxes; receipt mode draws a paper receipt with OCR highlights. */
export default function CameraCapture({
  mode,
  detected,
  zones,
  receipt,
}: {
  mode: "shelf" | "receipt";
  detected: boolean;
  zones: ShelfZone[];
  receipt: ReceiptRow[];
}) {
  return (
    <div className="camera-view">
      {mode === "shelf" ? (
        <>
          <div className="shelf-board s1" />
          <div className="shelf-board s2" />
          {zones.map((zone, i) => (
            <div className={`zone ${ZONE_CLASS[i]} ${detected ? "found" : ""}`} key={zone.label}>
              <div className="zone-items">
                {Array.from({ length: Math.min(zone.count, 6) }).map((_, k) => (
                  <ProductArt key={k} kind={zone.kind} size={40} />
                ))}
              </div>
              {detected && <span className="zone-tag">{`${zone.label}\n×${zone.count}`}</span>}
            </div>
          ))}
        </>
      ) : (
        <div className={`receipt-paper ${detected ? "read" : ""}`}>
          <b>ABC WHOLESALE</b>
          <small>Resibo · Supplier</small>
          <hr />
          {receipt.map((r) => (
            <div className="receipt-line" key={r.name}>
              <span>
                {r.qty} × {r.name}
              </span>
              <span>₱{r.qty * r.unit}</span>
            </div>
          ))}
          <hr />
          <div className="receipt-line total">
            <span>TOTAL</span>
            <span>₱{receipt.reduce((s, r) => s + r.qty * r.unit, 0)}</span>
          </div>
        </div>
      )}
      {!detected && <div className="scan-line" aria-hidden="true" />}
      {!detected && (
        <div className="scan-hint">
          <Mascot size={48} pose="scanning" />
          <span>{mode === "shelf" ? "Ini-scan ni Sari ang mga paninda..." : "Binabasa ni Sari ang resibo..."}</span>
        </div>
      )}
    </div>
  );
}

import type { ReactNode } from "react";
import { agingLabel, agingLevel, lastPaymentOf, type Debtor } from "../data/selectors";
import type { AppState, Customer, Intent, Product, Transaction } from "../data/types";
import { dayLabel, peso, qtyLabel, shortDate, timeLabel } from "../services/format";
import { TYPE_LABEL, itemsText } from "../services/parser";
import Avatar from "./Avatar";
import Icon, { type IconName } from "./Icon";
import Mascot from "./Mascot";
import ProductArt from "./ProductArt";
import { Rich } from "./ui";

const TX_STYLE: Record<Transaction["type"], { icon: IconName; cls: string }> = {
  sale: { icon: "check", cls: "tx-sale" },
  utang_add: { icon: "ledger", cls: "tx-utang" },
  utang_payment: { icon: "download", cls: "tx-pay" },
  restock: { icon: "box", cls: "tx-restock" },
};

export function TransactionCard({ tx, state, onClick, showDate = false }: { tx: Transaction; state: AppState; onClick?: () => void; showDate?: boolean }) {
  const who = state.customers.find((c) => c.id === tx.customerId)?.name;
  const list = itemsText(tx.items, state);
  const title =
    tx.type === "sale" ? list || "Benta" : tx.type === "utang_add" ? `Utang ni ${who ?? "—"}` : tx.type === "utang_payment" ? `Bayad ni ${who ?? "—"}` : "Restock";
  const sub = tx.type === "sale" ? TYPE_LABEL.sale : tx.type === "restock" ? list || tx.notes || "" : list || TYPE_LABEL[tx.type];
  const sign = tx.type === "sale" || tx.type === "utang_payment" ? "+" : tx.type === "restock" ? "−" : "";
  const style = TX_STYLE[tx.type];
  const Tag = onClick ? "button" : "div";
  return (
    <Tag className="row tall tx-row" onClick={onClick} type={onClick ? "button" : undefined}>
      <span className={`tx-icon ${style.cls}`}>
        <Icon name={style.icon} size={20} stroke={2.4} />
      </span>
      <span className="row-copy">
        <b>{title}</b>
        <small>
          {sub} · {showDate ? `${dayLabel(tx.timestamp, Date.now())}, ` : ""}{timeLabel(tx.timestamp)}
        </small>
      </span>
      <strong className={`tx-amount ${style.cls}`}>
        {tx.amount > 0 || tx.type !== "restock" ? `${sign}${peso(tx.amount)}` : "—"}
      </strong>
    </Tag>
  );
}

export function ProductCard({ product, onClick, trailing }: { product: Product; onClick?: () => void; trailing?: ReactNode }) {
  const low = product.qty <= product.threshold;
  return (
    <button className="row tall" onClick={onClick} type="button">
      <span className="art-plain">
        <ProductArt kind={product.kind} size={36} />
      </span>
      <span className="row-copy">
        <b>{product.name}</b>
        <small>{qtyLabel(product.qty, product)}</small>
      </span>
      {trailing ?? (
        <span className={`status-ring ${low ? "low" : "ok"}`} role="img" aria-label={low ? "Low stock" : "Sapat"}>
          {low ? "!" : <Icon name="check" size={14} stroke={3} />}
        </span>
      )}
      <Icon name="chevron" size={16} />
    </button>
  );
}

export function CustomerCard({ debtor, state, onClick }: { debtor: Debtor | { customer: Customer; balance: number; days: number | null }; state: AppState; onClick: () => void }) {
  const { customer, balance, days } = debtor;
  const paid = lastPaymentOf(state.transactions, customer.id);
  return (
    <button className="row tall" onClick={onClick} type="button">
      <Avatar aging={balance > 0 ? agingLevel(days) : undefined} look={customer.look} size={44} />
      <span className="row-copy">
        <b>{customer.name}</b>
        <small>{paid ? `Huling bayad: ${shortDate(paid)}` : balance > 0 ? "Wala pang bayad" : "Wala pang utang"}</small>
      </span>
      <strong className="amount">{peso(balance)}</strong>
      <Icon name="chevron" size={16} />
    </button>
  );
}

export function aging(days: number | null, state: AppState, customerId: string): string {
  return agingLabel(days, lastPaymentOf(state.transactions, customerId) !== undefined);
}

export function InsightBubble({ text, tip, pose = "face", children }: { text: string; tip?: string; pose?: "face" | "insights" | "confused"; children?: ReactNode }) {
  return (
    <div className="bren-block">
      <div className="bren-message">
        <Mascot pose={pose} size={pose === "face" ? 38 : 56} />
        <div className="bren-bubble">
          {text.split("\n").map((line, i) => (
            <p key={i}>
              <Rich text={line} />
            </p>
          ))}
          {children}
        </div>
      </div>
      {tip && (
        <div className="tip">
          <span className="tip-icon">
            <Icon name="bulb" size={18} />
          </span>
          <div>
            <b>Tip ni Sari:</b>
            <p>{tip}</p>
          </div>
        </div>
      )}
    </div>
  );
}

export function DashboardSummaryCard({
  label,
  value,
  note,
  tone,
  onClick,
}: {
  label: string;
  value: string;
  note: string;
  tone: "good" | "bad" | "muted";
  onClick: () => void;
}) {
  return (
    <button className="summary-card" onClick={onClick} type="button">
      <span className={`summary-label ${tone === "good" ? "sales" : ""}`}>{label}</span>
      <strong>{value}</strong>
      <small className={tone === "good" ? "sales" : tone === "bad" ? "debt" : "muted"}>{note}</small>
    </button>
  );
}

/** The "Naintindihan ko" card: shows a parsed transaction before it is saved. */
export function IntentSummary({ intent, state }: { intent: Intent; state: AppState }) {
  const who = intent.customerName ?? state.customers.find((c) => c.id === intent.customerId)?.name;
  const list = itemsText(intent.items, state);
  return (
    <div className="intent">
      <span className={`type-badge badge-${intent.type}`}>{TYPE_LABEL[intent.type]}</span>
      {who && <p>Si {who}{intent.customerName ? " (bagong suki)" : ""}</p>}
      <p>
        {intent.type === "utang_payment" ? "Bayad" : intent.type === "utang_add" ? "Utang" : intent.type === "sale" ? "Benta" : "Gastos"}:{" "}
        <b>{peso(intent.amount)}</b>
      </p>
      {list && <p>Items: {list}</p>}
      {intent.type === "utang_payment" && <p>Matitira: {peso(intent.balanceAfter ?? 0)}</p>}
    </div>
  );
}

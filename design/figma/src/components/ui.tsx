import type { ReactNode } from "react";
import type { Nav, ScreenName } from "../nav";
import Icon, { type IconName } from "./Icon";

export function PillButton({
  children,
  onClick,
  className = "",
  disabled = false,
  variant = "primary",
}: {
  children: ReactNode;
  onClick?: () => void;
  className?: string;
  disabled?: boolean;
  variant?: "primary" | "secondary" | "ghost";
}) {
  return (
    <button
      aria-disabled={disabled}
      className={`pill-button ${variant} ${disabled ? "disabled" : ""} ${className}`}
      onClick={disabled ? undefined : onClick}
      type="button"
    >
      {children}
    </button>
  );
}

export function Chip({ active, onClick, children }: { active: boolean; onClick: () => void; children: ReactNode }) {
  return (
    <button aria-selected={active} className={`chip ${active ? "active" : ""}`} onClick={onClick} role="tab" type="button">
      {children}
    </button>
  );
}

export function TopBar({ title, onBack, dark = false, right }: { title: ReactNode; onBack?: () => void; dark?: boolean; right?: ReactNode }) {
  return (
    <header className={`topbar ${dark ? "topbar-dark" : ""}`}>
      {onBack && (
        <button aria-label="Bumalik" className="icon-button" onClick={onBack} type="button">
          <Icon name="back" size={22} stroke={2.4} />
        </button>
      )}
      <h1 className="topbar-title">{title}</h1>
      {right && <div className="topbar-right">{right}</div>}
    </header>
  );
}

const TABS: { screen: ScreenName; icon: IconName; label: string }[] = [
  { screen: "home", icon: "home", label: "Home" },
  { screen: "transactions", icon: "list", label: "Talaan" },
  { screen: "inventory", icon: "box", label: "Paninda" },
  { screen: "customers", icon: "ledger", label: "Utang" },
  { screen: "chat", icon: "chat", label: "Sari" },
];

export const TAB_SCREENS = TABS.map((t) => t.screen);

export function BottomNav({ current, nav }: { current: ScreenName; nav: Nav }) {
  return (
    <div className="nav-dock">
      <nav className="bottom-nav glass" aria-label="Pangunahing navigation">
        {TABS.map((item) => (
          <button
            aria-current={current === item.screen ? "page" : undefined}
            className={`nav-item ${current === item.screen ? "active" : ""}`}
            key={item.screen}
            onClick={() => nav.tab(item.screen)}
            type="button"
          >
            <Icon name={item.icon} size={22} />
            <span>{item.label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

/** Round translucent icon button (header controls). */
export function GlassButton({ icon, label, onClick, badge, dot }: { icon: IconName; label: string; onClick: () => void; badge?: number; dot?: boolean }) {
  return (
    <button aria-label={label} className="glass-button glass" onClick={onClick} type="button">
      <Icon name={icon} size={22} />
      {badge !== undefined && <b className="badge">{badge}</b>}
      {dot && <i className="dot" />}
    </button>
  );
}

export function Toast({ message }: { message: string | null }) {
  if (!message) return null;
  return (
    <div className="toast" role="status">
      <Icon name="check" size={18} stroke={2.6} />
      <span>{message}</span>
    </div>
  );
}

export function Segmented<T extends string>({
  value,
  options,
  onChange,
}: {
  value: T;
  options: { value: T; label: string }[];
  onChange: (v: T) => void;
}) {
  return (
    <div className="segmented" role="tablist">
      {options.map((o) => (
        <button
          aria-selected={value === o.value}
          className={value === o.value ? "active" : ""}
          key={o.value}
          onClick={() => onChange(o.value)}
          role="tab"
          type="button"
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

export function Stepper({ value, onChange, min = 0, label }: { value: number; onChange: (v: number) => void; min?: number; label: string }) {
  return (
    <span className="stepper">
      <button aria-label={`Bawasan ang ${label}`} onClick={() => onChange(Math.max(min, value - 1))} type="button">
        <Icon name="minus" size={16} stroke={2.6} />
      </button>
      <b>{value}</b>
      <button aria-label={`Dagdagan ang ${label}`} onClick={() => onChange(value + 1)} type="button">
        <Icon name="plus" size={16} stroke={2.6} />
      </button>
    </span>
  );
}

/** Renders **bold** segments. */
export function Rich({ text }: { text: string }) {
  return (
    <>
      {text.split("**").map((part, i) => (i % 2 ? <b key={i}>{part}</b> : <span key={i}>{part}</span>))}
    </>
  );
}

import { DashboardSummaryCard } from "../components/cards";
import Icon, { type IconName } from "../components/Icon";
import Mascot, { welcomeBackground } from "../components/Mascot";
import ProductArt from "../components/ProductArt";
import WeeklyChart from "../components/WeeklyChart";
import { GlassButton, Rich } from "../components/ui";
import { weeklyBuckets, weeklyGrowth } from "../data/finance";
import type { Store } from "../data/store";
import { debtors, lowStock, salesOn, startOfDay, streakDays, totalUtang, trendPercent } from "../data/selectors";
import type { Nav, ScreenName } from "../nav";
import { greeting, qtyLabel } from "../services/format";
import { shortSummary } from "../services/insights";

const dateEyebrow = (now: number) =>
  new Date(now).toLocaleDateString("fil-PH", { weekday: "long", month: "long", day: "numeric" }).toUpperCase();

export default function Home({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const now = Date.now();
  const sales = salesOn(state, startOfDay(now));
  const trend = trendPercent(state, now);
  const owing = debtors(state, now);
  const low = lowStock(state);
  const streak = streakDays(state, now);
  const buckets = weeklyBuckets(state, now, 8);
  const growth = weeklyGrowth(buckets);

  const tiles: { icon: IconName; label: string; go: () => void }[] = [
    { icon: "mic", label: "Sabihin", go: () => nav.go("voice") },
    { icon: "camera", label: "Kunan", go: () => nav.go("scan") },
    { icon: "receipt", label: "Resibo", go: () => nav.go("scan", "receipt") },
    { icon: "chat", label: "Tanungin", go: () => nav.tab("chat") },
    { icon: "ledger", label: "Utang", go: () => nav.tab("customers" as ScreenName) },
  ];

  return (
    <main className="screen has-nav home-screen">
      <section className="home-hero" style={welcomeBackground ? { backgroundImage: `url(${welcomeBackground})` } : undefined}>
        <header className="home-top">
          <GlassButton
            badge={streak}
            icon="flame"
            label={`${streak} araw na sunod-sunod`}
            onClick={() => nav.notify(`${streak} araw kang sunod-sunod na nagre-record! 🔥`)}
          />
          <GlassButton icon="settings" label="Settings" onClick={() => nav.go("settings")} />
        </header>

        <p className="date-eyebrow">{dateEyebrow(now)}</p>
        <h2 className="hero-greeting">
          {greeting(now)}, <b>Aling Maria</b>!
        </h2>

        <div className="hero-sari">
          <Mascot pose="idle" size={118} />
          <button className="hero-card" onClick={() => nav.tab("chat")} type="button">
            <b>Sari</b>
            <p>
              <Rich text={shortSummary(state, now)} />
            </p>
          </button>
        </div>
      </section>

      <section className="section">
        <h3 className="section-title">Mabilis na Gawain</h3>
        <div className="tiles">
          {tiles.map((t) => (
            <button className="tile" key={t.label} onClick={t.go} type="button">
              <span className="tile-icon">
                <Icon name={t.icon} size={26} />
              </span>
              <span>{t.label}</span>
            </button>
          ))}
        </div>
      </section>

      <section className="summary-grid">
        <DashboardSummaryCard
          label="Benta Ngayon"
          note={trend === null ? "Unang araw ng benta" : `${trend >= 0 ? "+" : ""}${trend}% vs. kahapon`}
          onClick={() => nav.tab("transactions")}
          tone={trend !== null && trend < 0 ? "bad" : "good"}
          value={`₱${Math.round(sales).toLocaleString("en-PH")}`}
        />
        <DashboardSummaryCard
          label="Utang Total"
          note={`${owing.length} customers`}
          onClick={() => nav.tab("customers")}
          tone="bad"
          value={`₱${totalUtang(state, now).toLocaleString("en-PH")}`}
        />
      </section>

      <section className="section">
        <button className="card growth-card" onClick={() => nav.go("capital")} type="button">
          <div className="growth-head">
            <b>Paglago ng benta</b>
            {growth !== null ? (
              <span className={`tag ${growth < 0 ? "tag-down" : "tag-up"}`}>{growth >= 0 ? "+" : ""}{growth}% vs. nakaraang linggo</span>
            ) : (
              <span className="tag">Puhunan at Kita</span>
            )}
          </div>
          <WeeklyChart buckets={buckets} mini />
          <small className="growth-foot">Tingnan ang puhunan at kita <Icon name="chevron" size={12} stroke={2.6} /></small>
        </button>
      </section>

      <section className="section">
        <div className="section-head">
          <h3 className="section-title low-stock-title">
            <Icon name="alert" size={20} stroke={2.4} /> Low Stock
          </h3>
          <button className="link-button" onClick={() => nav.tab("inventory")} type="button">
            Tingnan lahat <Icon name="chevron" size={14} stroke={2.4} />
          </button>
        </div>
        <div className="card list">
          {low.length === 0 ? (
            <div className="empty-row">
              <Icon name="check" size={18} stroke={2.6} /> Sapat ang lahat ng paninda mo!
            </div>
          ) : (
            low.slice(0, 3).map((p) => (
              <button className="row" key={p.id} onClick={() => nav.go("product", p.id)} type="button">
                <span className="art-tile">
                  <ProductArt kind={p.kind} size={30} />
                </span>
                <span className="row-copy">
                  <b>{p.name}</b>
                  <small>({qtyLabel(p.qty, p)})</small>
                </span>
                <span className="low-badge">Low</span>
                <Icon name="chevron" size={16} />
              </button>
            ))
          )}
        </div>
      </section>
    </main>
  );
}

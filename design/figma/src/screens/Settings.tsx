import { useState } from "react";
import Icon from "../components/Icon";
import Mascot from "../components/Mascot";
import { TopBar } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";

export default function Settings({ store, nav }: { store: Store; nav: Nav }) {
  const [airplane, setAirplane] = useState(true);

  const exportData = () => {
    const blob = new Blob([JSON.stringify(store.state, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `sari-backup-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    nav.notify("Na-save ang backup sa phone mo.");
  };

  const reset = () => {
    if (window.confirm("Sigurado ka ba? Mabubura ang lahat ng record mo at babalik sa demo data.")) {
      store.resetDemo();
      nav.notify("Na-reset ang demo data.");
    }
  };

  return (
    <main className="screen flow-screen">
      <TopBar onBack={nav.back} title="Settings" />
      <div className="page">
        <button aria-checked={airplane} className="airplane-row" onClick={() => setAirplane((a) => !a)} role="switch" type="button">
          <Icon name="plane" size={22} />
          <span>Airplane Mode</span>
          <span className={`toggle ${airplane ? "on" : ""}`}>
            <i />
          </span>
        </button>

        <div className="offline-card">
          <div className="offline-panel">
            <h2>Gumagana pa rin kahit walang internet!</h2>
            <ul>
              {["Voice commands", "Camera scanning", "AI responses", "Full functionality"].map((f) => (
                <li key={f}>
                  <Icon name="check" size={16} stroke={3} /> {f}
                </li>
              ))}
            </ul>
          </div>
          <Mascot pose="offline" size={170} />
          <div className="offline-badge">
            <b>100% Offline</b>
            <small>No Internet Needed</small>
          </div>
        </div>

        <h3 className="group-title">Data</h3>
        <div className="card list">
          <button className="row tall" onClick={exportData} type="button">
            <Icon name="download" size={22} />
            <span className="row-copy"><b>I-export ang data (JSON)</b><small>Naka-save lang sa phone mo</small></span>
            <Icon name="chevron" size={16} />
          </button>
          <button className="row tall" onClick={reset} type="button">
            <Icon name="refresh" size={22} />
            <span className="row-copy"><b>I-reset ang demo data</b><small>Babalik sa sample na tindahan</small></span>
            <Icon name="chevron" size={16} />
          </button>
        </div>

        <h3 className="group-title">Tutorial</h3>
        <div className="card list">
          <button className="row tall" onClick={() => nav.go("onboarding")} type="button">
            <Icon name="play" size={22} />
            <span className="row-copy"><b>Ipakita ulit ang tutorial</b><small>3 hakbang lang</small></span>
            <Icon name="chevron" size={16} />
          </button>
        </div>

        <p className="about">Sari · v1.0<br />Walang login · Walang ads · Libre habambuhay</p>
      </div>
    </main>
  );
}

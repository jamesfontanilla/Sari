import { useEffect, useRef, useState } from "react";
import { IntentSummary, InsightBubble } from "../components/cards";
import Icon from "../components/Icon";
import Mascot from "../components/Mascot";
import { Rich, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";
import { routeChat } from "../services/insights";
import { confirmationText } from "../services/parser";

const SUGGESTIONS = [
  "Kumikita ba ako ngayon?",
  "Anong pinaka-mabenta this week?",
  "Magkano utang lahat?",
  "Sino matagal na hindi nagbabayad?",
  "Ano kailangan i-restock?",
];

export default function Chat({ store, nav }: { store: Store; nav: Nav }) {
  const { state } = store;
  const [draft, setDraft] = useState("");
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ block: "end" });
  }, [state.chat.length, state.chat[state.chat.length - 1]?.status]);

  const send = (raw: string) => {
    const text = raw.trim();
    if (!text) return;
    const now = Date.now();
    const reply = routeChat(text, state, now);
    store.addChat([
      { id: `u-${now}`, from: "user", text, timestamp: now },
      { id: `s-${now}`, from: "sari", text: reply.text, tip: reply.tip, pending: reply.pending, timestamp: now + 1 },
    ]);
    setDraft("");
  };

  const confirm = (id: string, save: boolean) => {
    const msg = state.chat.find((m) => m.id === id);
    if (!msg?.pending) return;
    const now = Date.now();
    if (save) {
      store.commit(msg.pending);
      store.resolveChat(id, "saved");
      store.addChat([{ id: `s-${now}`, from: "sari", text: confirmationText(msg.pending, state), timestamp: now }]);
    } else {
      store.resolveChat(id, "cancelled");
    }
  };

  return (
    <main className="screen has-nav chat-screen">
      <TopBar
        title={
          <span className="chat-title">
            <Mascot size={32} /> Sari
          </span>
        }
      />
      <div className="chat">
        {state.chat.map((m) =>
          m.from === "user" ? (
            <div className="user-bubble" key={m.id}>
              {m.text}
            </div>
          ) : (
            <InsightBubble key={m.id} pose={m.text.includes("hindi ko na-gets") ? "confused" : "face"} text={m.text} tip={m.tip}>
              {m.pending && (
                <div className="confirm">
                  <IntentSummary intent={m.pending} state={state} />
                  {m.status === "saved" && <p className="resolved ok"><Icon name="check" size={16} stroke={3} /> Na-save</p>}
                  {m.status === "cancelled" && <p className="resolved">Hindi na-save</p>}
                  {!m.status && (
                    <div className="confirm-actions">
                      <button className="yes" onClick={() => confirm(m.id, true)} type="button">I-save</button>
                      <button className="no" onClick={() => confirm(m.id, false)} type="button">Huwag</button>
                    </div>
                  )}
                </div>
              )}
            </InsightBubble>
          ),
        )}
        <div className="chat-end" ref={endRef} />
      </div>
      <div className="suggestions" aria-label="Mga mungkahing tanong">
        {SUGGESTIONS.map((s) => (
          <button key={s} onClick={() => send(s)} type="button">
            <Rich text={s} />
          </button>
        ))}
      </div>
      <form
        className="composer"
        onSubmit={(e) => {
          e.preventDefault();
          if (draft.trim()) send(draft);
          else nav.go("voice");
        }}
      >
        <input aria-label="Magtanong kay Sari" onChange={(e) => setDraft(e.target.value)} placeholder="Magsulat o magsabi..." value={draft} />
        <button aria-label={draft ? "Ipadala" : "Gamitin ang boses"} className="composer-mic" type="submit">
          <Icon name={draft ? "send" : "mic"} size={20} stroke={2.2} />
        </button>
      </form>
    </main>
  );
}

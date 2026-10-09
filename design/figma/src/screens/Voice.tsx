import { useEffect, useRef, useState } from "react";
import { IntentSummary } from "../components/cards";
import Icon from "../components/Icon";
import Mascot from "../components/Mascot";
import { PillButton, TopBar } from "../components/ui";
import VoiceInputButton, { type VoiceState } from "../components/VoiceInputButton";
import type { Store } from "../data/store";
import type { Intent } from "../data/types";
import type { Nav } from "../nav";
import { SAMPLE_COMMANDS, confirmationText, parseCommand } from "../services/parser";

export default function Voice({ store, nav }: { store: Store; nav: Nav }) {
  const [state, setState] = useState<VoiceState>("listening");
  const [transcript, setTranscript] = useState("");
  const [draft, setDraft] = useState("");
  const [intent, setIntent] = useState<Intent | null>(null);
  const [error, setError] = useState<string | null>(null);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => () => window.clearTimeout(timer.current), []);

  const submit = (text: string) => {
    const phrase = text.trim();
    if (!phrase) return;
    setTranscript(phrase);
    setState("thinking");
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => {
      const result = parseCommand(phrase, store.state);
      if ("intent" in result) {
        setIntent(result.intent);
        setError(null);
        setState("understood");
      } else {
        setIntent(null);
        setError(result.error === "unknown" ? null : result.error);
        setState("confused");
      }
    }, 900);
  };

  const retry = () => {
    window.clearTimeout(timer.current);
    setState("listening");
    setTranscript("");
    setDraft("");
    setIntent(null);
    setError(null);
  };

  const save = () => {
    if (!intent) return;
    store.commit(intent);
    nav.back();
    nav.notify(confirmationText(intent, store.state));
  };

  const heading =
    state === "listening" ? "Nakikinig si Sari..." : state === "thinking" ? "Iniintindi ni Sari..." : state === "understood" ? "Naintindihan ko!" : "Hmm, hindi ko ma-gets";

  return (
    <main className="screen flow-screen voice-screen">
      <TopBar onBack={nav.back} title="Voice Command" />
      <div className="voice-body">
        <VoiceInputButton onPress={() => (state === "listening" ? submit(SAMPLE_COMMANDS[0]) : retry())} state={state} />
        <h2 className="listening-label">{heading}</h2>

        {transcript && <div className="transcript">“{transcript}”</div>}

        {state === "listening" && (
          <>
            <p className="hint">Subukan sabihin:</p>
            <div className="sample-list">
              {SAMPLE_COMMANDS.map((c) => (
                <button className="sample" key={c} onClick={() => submit(c)} type="button">
                  {c}
                </button>
              ))}
            </div>
            <form
              className="composer plain"
              onSubmit={(e) => {
                e.preventDefault();
                submit(draft);
              }}
            >
              <input aria-label="I-type ang sinabi mo" onChange={(e) => setDraft(e.target.value)} placeholder="O i-type ang sinabi mo…" value={draft} />
              <button aria-label="Ipadala" className="composer-mic" type="submit">
                <Icon name="send" size={20} stroke={2.2} />
              </button>
            </form>
          </>
        )}

        {state === "thinking" && (
          <div className="understood card pending">
            <Mascot pose="thinking" size={72} />
            <span className="dots" aria-label="Pinoproseso">
              <i /><i /><i />
            </span>
          </div>
        )}

        {state === "understood" && intent && (
          <>
            <div className="understood card">
              <div className="understood-head">
                <Mascot size={26} />
                <span>Naintindihan ko:</span>
                <span className="check-ring">
                  <Icon name="check" size={14} stroke={3} />
                </span>
              </div>
              <IntentSummary intent={intent} state={store.state} />
            </div>
            <PillButton onClick={save}>Tapos na</PillButton>
            <PillButton className="gap-top" onClick={retry} variant="ghost">
              Ulitin
            </PillButton>
          </>
        )}

        {state === "confused" && (
          <>
            <div className="understood card confused">
              <Mascot pose="confused" size={96} />
              <p>{error ? `${error} ` : ""}Sorry, hindi ko na-gets yun. Puwede mo ulitin?</p>
            </div>
            <PillButton onClick={retry}>Ulitin</PillButton>
          </>
        )}
      </div>
    </main>
  );
}

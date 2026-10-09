import { useState } from "react";
import Icon from "../components/Icon";
import Mascot, { type Pose } from "../components/Mascot";
import { PillButton } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";

const STEPS: { pose: Pose; title: string; body: string; example: string }[] = [
  {
    pose: "listening",
    title: "Sabihin lang",
    body: "Magsalita ka lang, ako na ang magsusulat.",
    example: "“Si Juan, utang 150 — sardinas at bigas”",
  },
  {
    pose: "scanning",
    title: "Kunan ang shelf",
    body: "Itapat ang camera sa paninda o resibo. Ako na ang bibilang.",
    example: "Sardines ×5 · Noodles ×8 · Tansan ×12",
  },
  {
    pose: "insights",
    title: "Tanungin mo ako",
    body: "Kumikita ba ako? Sino may utang? Sagot ko agad.",
    example: "Gumagana kahit walang internet ✈️",
  },
];

export default function Onboarding({ store, nav }: { store: Store; nav: Nav }) {
  const [step, setStep] = useState(0);
  const s = STEPS[step];
  const last = step === STEPS.length - 1;

  const finish = () => {
    store.completeOnboarding();
    nav.tab("home");
  };

  return (
    <main className="screen onboarding-screen">
      <div className="onboarding-top">
        <button className="skip" onClick={finish} type="button">
          Laktawan
        </button>
      </div>
      <div className="onboarding-body" key={step}>
        <Mascot pose={s.pose} size={240} />
        <h1>{s.title}</h1>
        <p>{s.body}</p>
        <div className="example">{s.example}</div>
      </div>
      <div className="onboarding-foot">
        <div className="dots-row" aria-label={`Hakbang ${step + 1} ng ${STEPS.length}`}>
          {STEPS.map((_, i) => (
            <i className={i === step ? "on" : ""} key={i} />
          ))}
        </div>
        <PillButton onClick={() => (last ? finish() : setStep(step + 1))}>
          {last ? "Tara na!" : "Susunod"}
          {!last && <Icon name="chevron" size={18} stroke={2.6} />}
        </PillButton>
      </div>
    </main>
  );
}

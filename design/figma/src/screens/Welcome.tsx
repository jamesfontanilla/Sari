import { useEffect, useRef, useState } from "react";
import introMov from "../assets/sari/intro-sari.mov";
import introWebm from "../assets/sari/intro-sari.webm";
import introEnd from "../assets/sari/intro-sari-end.webp";
import { PillButton } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";

const MESSAGES = [
  "Hi, ako si Sari, gabay mo sa pagtitinda!",
  "Sabihin mo lang, ako na ang magsusulat.",
  "Kunan mo ang paninda, ako na ang bibilang!",
  "Tanungin mo ako kung kumikita ka ngayon.",
  "Gumagana ako kahit walang internet!",
];
const HOLD_MS = 5500; // how long each message stays
const FADE_MS = 700; // gap while the bubble is faded out

/** Picks a transparent-video source the browser can play: HEVC+alpha for Safari, VP9+alpha WebM elsewhere. */
function pickSource(): string | null {
  const probe = document.createElement("video");
  const isSafari = /^((?!chrome|android|crios|fxios|edg).)*safari/i.test(navigator.userAgent);
  if (isSafari) return probe.canPlayType('video/mp4; codecs="hvc1"') ? introMov : null;
  return probe.canPlayType('video/webm; codecs="vp9"') ? introWebm : null;
}

/** Animated intro: Sari's green-screen animation over the landscape, freezes on the final pose, then "Simulan" appears. */
export default function Welcome({ store, nav }: { store: Store; nav: Nav }) {
  const [reduced] = useState(() => window.matchMedia?.("(prefers-reduced-motion: reduce)").matches ?? false);
  const [src] = useState(() => (reduced ? null : pickSource()));
  const [done, setDone] = useState(src === null);
  const [showStart, setShowStart] = useState(src === null);
  const videoRef = useRef<HTMLVideoElement>(null);

  const freeze = () => {
    videoRef.current?.pause();
    setDone(true);
  };

  useEffect(() => {
    if (done) return;
    const startTimer = window.setTimeout(() => setShowStart(true), 1500); // Simulan appears 1.5s into the animation
    const safety = window.setTimeout(freeze, 12_000); // safety net if playback stalls
    return () => {
      window.clearTimeout(startTimer);
      window.clearTimeout(safety);
    };
  }, [done]);

  // Once the intro has frozen, rotate the speech-bubble messages forever: fade in, hold, fade out, next.
  const [msg, setMsg] = useState(0);
  const [faded, setFaded] = useState(false);
  useEffect(() => {
    if (!done || reduced) return;
    let timer: number;
    const hold = () => {
      timer = window.setTimeout(() => {
        setFaded(true);
        timer = window.setTimeout(() => {
          setMsg((m) => (m + 1) % MESSAGES.length);
          setFaded(false);
          hold();
        }, FADE_MS);
      }, HOLD_MS);
    };
    hold();
    return () => window.clearTimeout(timer);
  }, [done, reduced]);

  const start = () => (store.state.onboarded ? nav.tab("home") : nav.go("onboarding"));

  return (
    <main
      className={`screen welcome-screen ${done ? "intro-done" : "intro-playing"}`}
      onClick={done ? undefined : freeze}
      role="presentation"
    >
      <div className="welcome-head">
        <h1 className="welcome-title">Sari</h1>
      </div>
      <div className="welcome-hero">
        <div aria-live="off" className={`speech-bubble intro-reveal ${faded ? "bubble-faded" : ""}`}>{MESSAGES[msg]}</div>
        {/* Preloaded but invisible while the video plays, so the swap at the end has no blank frame. */}
        <img alt="Sari" className={`intro-sari ${done || !src ? "" : "intro-ghost"}`} src={introEnd} />
        {!done && src && (
          <video
            aria-label="Si Sari, kumakaway"
            autoPlay
            className="intro-sari"
            muted
            onEnded={freeze}
            onError={freeze}
            playsInline
            preload="auto"
            ref={videoRef}
            src={src}
          />
        )}
      </div>
      <div className={`intro-cta ${showStart || done ? "show" : ""}`}>
        <PillButton onClick={start}>Simulan</PillButton>
      </div>
    </main>
  );
}

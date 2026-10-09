import Icon from "./Icon";

export type VoiceState = "listening" | "thinking" | "understood" | "confused";

export default function VoiceInputButton({ state, onPress }: { state: VoiceState; onPress: () => void }) {
  return (
    <div className="mic-stage">
      <span className="bars" aria-hidden="true">
        <i /><i /><i /><i />
      </span>
      <button
        aria-label="Pindutin para magsalita"
        className={`mic-circle ${state === "listening" ? "listening" : ""}`}
        onClick={onPress}
        type="button"
      >
        <Icon name="mic" size={64} stroke={2.2} />
      </button>
      <span className="bars" aria-hidden="true">
        <i /><i /><i /><i />
      </span>
    </div>
  );
}

export type Pose =
  | "face"
  | "welcome"
  | "idle"
  | "listening"
  | "thinking"
  | "success"
  | "scanning"
  | "insights"
  | "empty"
  | "confused"
  | "offline";

const poses = import.meta.glob<string>("../assets/sari/*.png", { eager: true, import: "default" });
const backgrounds = import.meta.glob<string>("../assets/sari/bg-welcome.{webp,jpg,jpeg,png}", { eager: true, import: "default" });

/** Optional landing-page landscape art (see spec/brands.md §5). Undefined when the file is absent. */
export const welcomeBackground: string | undefined = Object.values(backgrounds)[0];

export default function Mascot({ size = 48, pose = "face" }: { size?: number; pose?: Pose }) {
  return (
    <img
      alt="Sari"
      className={`mascot ${pose === "face" ? "mascot-face" : ""}`}
      draggable={false}
      height={size}
      src={poses[`../assets/sari/${pose}.png`]}
      style={{ width: size, height: size }}
      width={size}
    />
  );
}

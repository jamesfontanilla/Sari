import type { ReactNode } from "react";

export type IconName =
  | "home" | "list" | "box" | "ledger" | "chat" | "mic" | "camera" | "back" | "settings" | "chevron"
  | "check" | "plane" | "bulb" | "send" | "alert" | "plus" | "minus" | "download" | "refresh"
  | "receipt" | "play" | "close" | "bell" | "users" | "flame" | "chart";

/** Filled shape in currentColor (holes use even-odd). */
const S = ({ d }: { d: string }) => <path d={d} fill="currentColor" fillRule="evenodd" stroke="none" />;

/** Solid icons: feature and navigation glyphs. */
const solid: Partial<Record<IconName, ReactNode>> = {
  home: <S d="M12 2.8 2.6 10.9a.8.8 0 0 0 .5 1.4H5V20a1.5 1.5 0 0 0 1.5 1.5h3V15h5v6.5h3A1.5 1.5 0 0 0 19 20v-7.7h1.9a.8.8 0 0 0 .5-1.4Z" />,
  list: <S d="M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z M6.8 7.2h1.6v1.6H6.8Z M10.3 7.2h6.9v1.6h-6.9Z M6.8 11.2h1.6v1.6H6.8Z M10.3 11.2h6.9v1.6h-6.9Z M6.8 15.2h1.6v1.6H6.8Z M10.3 15.2h6.9v1.6h-6.9Z" />,
  box: (
    <>
      <S d="M3.5 8h17l-1.3 11.5a2 2 0 0 1-2 1.8H6.8a2 2 0 0 1-2-1.8Z" />
      <path d="M8.5 8V6.5a3.5 3.5 0 0 1 7 0V8" strokeWidth="2" />
    </>
  ),
  ledger: <S d="M6 2.5h12a2 2 0 0 1 2 2v15a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-15a2 2 0 0 1 2-2Z M8 7.5h8v1.8H8Z M8 11.5h8v1.8H8Z M8 15.5h5v1.8H8Z" />,
  chat: <S d="M5 3.5h14A2.5 2.5 0 0 1 21.5 6v9a2.5 2.5 0 0 1-2.5 2.5H10l-4.5 4v-4H5A2.5 2.5 0 0 1 2.5 15V6A2.5 2.5 0 0 1 5 3.5Z" />,
  mic: (
    <>
      <rect x="8.5" y="2" width="7" height="13" rx="3.5" fill="currentColor" stroke="none" />
      <path d="M5 11a7 7 0 0 0 14 0M12 18v3.5M8.5 21.5h7" strokeWidth="2" />
    </>
  ),
  camera: <S d="M3 8.5A2.5 2.5 0 0 1 5.5 6H8l1.3-2h5.4L16 6h2.5A2.5 2.5 0 0 1 21 8.5v9a2.5 2.5 0 0 1-2.5 2.5h-13A2.5 2.5 0 0 1 3 17.5Z M12 9.4a3.6 3.6 0 1 0 0 7.2 3.6 3.6 0 0 0 0-7.2Z" />,
  receipt: <S d="M6 2.5h12a1 1 0 0 1 1 1v18l-2.5-1.8-2 1.8-2-1.8-2 1.8-2-1.8L5 21.5v-18a1 1 0 0 1 1-1Z M8.5 7.5h7v1.8h-7Z M8.5 11.5h7v1.8h-7Z" />,
  bell: <S d="M12 2.8a6.2 6.2 0 0 0-6.2 6.2v4l-1.6 3.2a.8.8 0 0 0 .7 1.2h14.2a.8.8 0 0 0 .7-1.2L18.2 13V9A6.2 6.2 0 0 0 12 2.8Z M9.6 19.2a2.4 2.4 0 0 0 4.8 0Z" />,
  users: <S d="M9 4.4a3.6 3.6 0 1 0 0 7.2 3.6 3.6 0 0 0 0-7.2Z M2.5 20.5a6.5 6.5 0 0 1 13 0Z M16.8 5.7a2.9 2.9 0 1 0 0 5.8 2.9 2.9 0 0 0 0-5.8Z M16.5 13.3a5.5 5.5 0 0 1 5 7.2h-4.6a8 8 0 0 0-2.1-5.6 5.4 5.4 0 0 1 1.7-1.6Z" />,
  settings: <S d="M19 12a7 7 0 0 0-.1-1l2-1.5-2-3.4-2.4 1A8 8 0 0 0 15 6l-.3-2.5h-4L10.4 6A8 8 0 0 0 8.8 7L6.5 6.1l-2 3.4 2 1.5a7 7 0 0 0 0 2l-2 1.5 2 3.4 2.3-1a8 8 0 0 0 1.6 1l.3 2.6h4L15 18a8 8 0 0 0 1.6-1.1l2.3 1 2-3.4-2-1.5a7 7 0 0 0 .1-1Z M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z" />,
  flame: <S d="M12 21.5c-3.9 0-7-2.8-7-6.6 0-3.1 2-5.3 3.6-7 .5 1.6 1.4 2.6 2.4 3 0-3.3 1.6-6 4-7.4-.3 2.6.7 4.5 2.2 6 1.1 1.2 1.8 2.8 1.8 5 0 4.1-3.1 7-7 7Z" />,
  bulb: (
    <>
      <S d="M12 2.5a6.5 6.5 0 0 0-3.8 11.8c.5.4.8 1 .8 1.7v.5h6V16c0-.7.3-1.3.8-1.7A6.5 6.5 0 0 0 12 2.5Z" />
      <path d="M9.5 19h5M10.5 21.5h3" strokeWidth="2" />
    </>
  ),
  alert: <S d="M12 2.5a9.5 9.5 0 1 0 0 19 9.5 9.5 0 0 0 0-19Z M11 7h2v6.2h-2Z M11 15.2h2v2h-2Z" />,
  plane: <S d="M10.5 21.5 12 15l-6 2.5V16l6-4V6a1.5 1.5 0 0 1 3 0v6l6 4v1.5L15 15l1.5 6.5-3-1.5-3 1.5Z" />,
  send: <S d="M3.4 3.6 21.6 12 3.4 20.4l2.6-8.4Z" />,
  play: <S d="M7.5 4.5 20 12 7.5 19.5Z" />,
  chart: <S d="M4 13.5a1 1 0 0 1 1-1h3a1 1 0 0 1 1 1V20a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1Z M10.5 4a1 1 0 0 1 1-1h3a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1h-3a1 1 0 0 1-1-1Z M17 9a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v11a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1Z" />,
  download: <S d="M10.8 3h2.4v8.1l2.7-2.7 1.7 1.7L12 15.7 6.4 10.1l1.7-1.7 2.7 2.7Z M4 17.5h16V21H4Z" />,
  refresh: <S d="M12 3.5A8.5 8.5 0 1 0 20.5 12h-2.2A6.3 6.3 0 1 1 12 5.7c1.3 0 2.5.4 3.5 1.1L13 9.3h7.2V2.1l-2.6 2.6A8.4 8.4 0 0 0 12 3.5Z" />,
};

/** Simple UI glyphs stay as 2px stroked lines. */
const lines: Partial<Record<IconName, ReactNode>> = {
  back: <path d="m15 18-6-6 6-6" />,
  chevron: <path d="m9 18 6-6-6-6" />,
  check: <path d="m5 12.5 4.5 4.5L19 7" />,
  plus: <path d="M12 5v14M5 12h14" />,
  minus: <path d="M5 12h14" />,
  close: <path d="M6 6l12 12M18 6 6 18" />,
};

export default function Icon({ name, size = 22, stroke = 2 }: { name: IconName; size?: number; stroke?: number }) {
  const filled = name in solid;
  return (
    <svg aria-hidden="true" className="icon" fill="none" height={size} viewBox="0 0 24 24" width={size}>
      <g stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth={filled ? 2 : stroke}>
        {solid[name] ?? lines[name]}
      </g>
    </svg>
  );
}

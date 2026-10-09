import type { AgingLevel } from "../data/selectors";
import type { AvatarLook } from "../data/types";

const DOT: Record<AgingLevel, string> = { ok: "#2f9e57", warn: "#e0a21b", late: "#d93a40" };

export default function Avatar({ look, size = 44, aging }: { look: AvatarLook; size?: number; aging?: AgingLevel }) {
  return (
    <span className="avatar-wrap" style={{ width: size, height: size }}>
      <svg aria-hidden="true" height={size} viewBox="0 0 40 40" width={size}>
        <circle cx="20" cy="20" r="20" fill={look.bg} />
        {look.long && <path d="M9 22c0-10 4-14 11-14s11 4 11 14v8H9Z" fill={look.hair} />}
        <path d="M6 40c1-7 6-11 14-11s13 4 14 11Z" fill={look.shirt} />
        <circle cx="20" cy="20" r="9" fill="#f0bf95" />
        <path d="M11 19c0-7 4-10 9-10s9 3 9 10c-3-4-9-5-13-3-2 1-4 2-5 3Z" fill={look.hair} />
        <circle cx="17" cy="21" r="1.1" fill="#2b1a10" />
        <circle cx="23" cy="21" r="1.1" fill="#2b1a10" />
        <path d="M17.5 24.5c1.5 1.2 3.5 1.2 5 0" stroke="#8a4a2a" strokeWidth="1.2" fill="none" strokeLinecap="round" />
      </svg>
      {aging && <i className="aging-dot" style={{ background: DOT[aging] }} />}
    </span>
  );
}

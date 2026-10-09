import type { ReactNode } from "react";
import type { ProductKind } from "../data/types";

const art: Record<ProductKind, ReactNode> = {
  rice: (
    <>
      <path d="M11 9h18l3 24a3 3 0 0 1-3 3H11a3 3 0 0 1-3-3l3-24Z" fill="#f4dfa8" stroke="#a87a2c" strokeWidth="1.8" />
      <path d="M12 9c2-3 14-3 16 0" fill="none" stroke="#a87a2c" strokeWidth="1.8" />
      <rect x="12" y="17" width="16" height="10" rx="2" fill="#e8a33a" />
      <text x="20" y="24.5" fill="#fff" fontSize="6" fontWeight="800" textAnchor="middle" fontFamily="Inter, sans-serif">RICE</text>
    </>
  ),
  can: (
    <>
      <rect x="8" y="12" width="24" height="20" rx="4" fill="#e3402f" stroke="#9e2a1d" strokeWidth="1.8" />
      <ellipse cx="20" cy="12" rx="12" ry="3.5" fill="#d9d9d9" stroke="#9e2a1d" strokeWidth="1.6" />
      <rect x="8" y="18" width="24" height="8" fill="#ffd64d" />
      <path d="M13 22c3-3 8-3 11 0-3 3-8 3-11 0Zm11 0 3-2v4Z" fill="#3a7bc8" />
    </>
  ),
  bottle: (
    <>
      <path d="M16 4h8v5l3 4v20a3 3 0 0 1-3 3h-8a3 3 0 0 1-3-3V13l3-4V4Z" fill="#bfe3ff" stroke="#3a7bc8" strokeWidth="1.8" />
      <rect x="16" y="2.5" width="8" height="3.5" rx="1" fill="#2f6fd0" />
      <rect x="13" y="18" width="14" height="8" fill="#3a7bc8" />
    </>
  ),
  noodles: (
    <>
      <path d="M6 12h28l-2 20H8L6 12Z" fill="#ffcf3a" stroke="#c4861a" strokeWidth="1.8" />
      <path d="M11 21c2-3 4 3 6 0s4 3 6 0 4 3 6 0" fill="none" stroke="#c0392b" strokeWidth="2" strokeLinecap="round" />
      <rect x="9" y="13.5" width="22" height="4" rx="1" fill="#e3402f" />
    </>
  ),
  soda: (
    <>
      <rect x="11" y="8" width="18" height="27" rx="4" fill="#5a3fb8" stroke="#3a2780" strokeWidth="1.8" />
      <ellipse cx="20" cy="8" rx="9" ry="2.5" fill="#cfcfe0" stroke="#3a2780" strokeWidth="1.4" />
      <path d="M11 20c6 4 12-4 18 0" fill="none" stroke="#fff" strokeWidth="2.2" />
    </>
  ),
  coffee: (
    <>
      <path d="M10 10h20v23a3 3 0 0 1-3 3H13a3 3 0 0 1-3-3V10Z" fill="#8a5a3b" stroke="#5b3720" strokeWidth="1.8" />
      <rect x="9" y="6" width="22" height="5" rx="1.5" fill="#e3a23b" stroke="#5b3720" strokeWidth="1.6" />
      <ellipse cx="20" cy="22" rx="5" ry="6" fill="#e9c08a" />
      <path d="M20 17c-2 3-2 7 0 10" stroke="#8a5a3b" strokeWidth="1.4" fill="none" />
    </>
  ),
};

export default function ProductArt({ kind, size = 36 }: { kind: ProductKind; size?: number }) {
  return (
    <svg aria-hidden="true" className="product-art" height={size} viewBox="0 0 40 40" width={size}>
      {art[kind]}
    </svg>
  );
}

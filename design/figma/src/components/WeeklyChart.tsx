import type { WeekBucket } from "../data/finance";
import { peso } from "../services/format";

const label = (ts: number) => new Date(ts).toLocaleDateString("fil-PH", { month: "short", day: "numeric" });

/** 8-week bars of sales with a line for profit on the items sold. `mini` drops labels and the line. */
export default function WeeklyChart({ buckets, mini = false }: { buckets: WeekBucket[]; mini?: boolean }) {
  const W = 320;
  const barsH = mini ? 56 : 132;
  const labelH = mini ? 0 : 20;
  const n = buckets.length;
  const slot = W / n;
  const barW = mini ? 20 : 24;
  const max = Math.max(1, ...buckets.map((b) => b.sales));
  const y = (v: number) => barsH - Math.max(v > 0 ? 4 : 2, (Math.max(v, 0) / max) * (barsH - 8));
  const points = buckets.map((b, i) => `${i * slot + slot / 2},${y(b.profit)}`).join(" ");
  const summary = buckets.map((b) => `${label(b.start)}: ${peso(b.sales)}`).join(", ");

  return (
    <svg aria-label={`Benta kada linggo. ${summary}`} className="weekly-chart" role="img" viewBox={`0 0 ${W} ${barsH + labelH}`}>
      {buckets.map((b, i) => {
        const x = i * slot + (slot - barW) / 2;
        const top = y(b.sales);
        const latest = i === n - 1;
        return (
          <g key={b.start}>
            <rect fill={latest ? "var(--orange)" : "#ffcfb0"} height={barsH - top} rx={6} width={barW} x={x} y={top} />
            {!mini && (
              <text className="chart-label" fill={latest ? "var(--orange-dark)" : "#8a7d72"} fontWeight={latest ? 800 : 600} textAnchor="middle" x={i * slot + slot / 2} y={barsH + 14}>
                {label(b.start)}
              </text>
            )}
          </g>
        );
      })}
      {!mini && (
        <>
          <polyline fill="none" points={points} stroke="var(--teal)" strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} />
          {buckets.map((b, i) => (
            <circle cx={i * slot + slot / 2} cy={y(b.profit)} fill="white" key={b.start} r={3.5} stroke="var(--teal)" strokeWidth={2} />
          ))}
        </>
      )}
    </svg>
  );
}

import type { AppState, AvatarLook, Customer, Product, Transaction, TxItem } from "./types";

export const STATE_VERSION = 1;
const DAY = 86_400_000;

export const LOOKS: AvatarLook[] = [
  { bg: "#ffe0cc", hair: "#3a2416", shirt: "#3f7cc4" },
  { bg: "#ffd9e0", hair: "#5a2d1a", shirt: "#e0574f", long: true },
  { bg: "#e3f0d9", hair: "#2a1d14", shirt: "#4c9a5e" },
  { bg: "#e6e1f7", hair: "#1f1612", shirt: "#7a5cc9", long: true },
  { bg: "#fff0c2", hair: "#4a3020", shirt: "#e59a2b" },
  { bg: "#d9f2ee", hair: "#2b1d14", shirt: "#0f766e" },
];

const products: Omit<Product, "lastRestocked">[] = [
  { id: "sardinas", name: "Sardinas", kind: "can", category: "De lata", unit: "cans", qty: 1, threshold: 3, buyPrice: 20, sellPrice: 25, aliases: ["sardinas", "sardines", "sardinas"] },
  { id: "bigas", name: "Bigas", kind: "rice", category: "Bigas at tuyo", unit: "packs", qty: 2, threshold: 3, buyPrice: 48, sellPrice: 55, aliases: ["bigas", "rice"] },
  { id: "tansan", name: "Tansan", kind: "bottle", category: "Inumin", unit: "bottles", qty: 3, threshold: 3, buyPrice: 11, sellPrice: 15, aliases: ["tansan", "tubig", "water"] },
  { id: "noodles", name: "Noodles", kind: "noodles", category: "Bigas at tuyo", unit: "packs", qty: 8, threshold: 3, buyPrice: 12, sellPrice: 15, aliases: ["instant noodles", "pancit canton", "noodles", "canton", "lucky me"] },
  { id: "softdrinks", name: "Softdrinks", kind: "soda", category: "Inumin", unit: "bottles", qty: 10, threshold: 3, buyPrice: 16, sellPrice: 20, aliases: ["softdrinks", "softdrink", "coke", "sprite", "royal", "soda"] },
  { id: "kape", name: "Kape", kind: "coffee", category: "Inumin", unit: "packs", qty: 5, threshold: 3, buyPrice: 7, sellPrice: 10, aliases: ["kape", "coffee", "3in1"] },
];

const price = (id: string) => products.find((p) => p.id === id)!.sellPrice;
const cost = (id: string) => products.find((p) => p.id === id)!.buyPrice;
const sold = (id: string, qty: number): TxItem => ({ productId: id, qty, unitPrice: price(id) });
const sum = (items: TxItem[]) => items.reduce((s, i) => s + i.qty * i.unitPrice, 0);

const startOfDay = (ts: number) => {
  const d = new Date(ts);
  d.setHours(0, 0, 0, 0);
  return d.getTime();
};

export function makeSeed(now: number = Date.now()): AppState {
  const today = startOfDay(now);
  const elapsed = Math.max(now - today, 60 * 60 * 1000);
  let n = 0;
  const id = () => `t-seed-${++n}`;
  const txs: Transaction[] = [];

  const sale = (timestamp: number, items: TxItem[]) =>
    txs.push({ id: id(), type: "sale", amount: sum(items), timestamp, items });

  // Today: 9 sales totalling ₱650, sardinas is the top seller (8 pcs).
  const todaySales: TxItem[][] = [
    [sold("sardinas", 3)],
    [sold("bigas", 2)],
    [sold("noodles", 4)],
    [sold("sardinas", 2)],
    [sold("softdrinks", 5)],
    [sold("kape", 4)],
    [sold("tansan", 2)],
    [sold("bigas", 2)],
    [sold("sardinas", 3)],
  ];
  todaySales.forEach((items, i) => sale(today + (elapsed * (i + 1)) / (todaySales.length + 1), items));

  // Yesterday: ₱580.
  const y = today - DAY;
  [
    [sold("sardinas", 4), sold("bigas", 3)],
    [sold("noodles", 6), sold("softdrinks", 6)],
    [sold("kape", 6), sold("tansan", 3)],
  ].forEach((items, i) => sale(y + (10 + i * 3) * 3_600_000, items));

  // Earlier days (2–13 days ago): small, steady sales.
  for (let d = 2; d <= 13; d++) {
    const base = today - d * DAY;
    sale(base + 9 * 3_600_000, [sold("sardinas", 2), sold("bigas", 1)]);
    sale(base + 15 * 3_600_000, [sold("noodles", 2), sold("softdrinks", 1)]);
  }

  // Older days (14–55 days ago): a growing trend so the weekly graph shows growth.
  for (let d = 14; d <= 55; d++) {
    const items =
      d <= 27 ? [sold("sardinas", 2), sold("noodles", 2), sold("bigas", 1)]
      : d <= 41 ? [sold("sardinas", 1), sold("noodles", 2), sold("softdrinks", 1)]
      : [sold("sardinas", 1), sold("noodles", 1)];
    sale(today - d * DAY + 11 * 3_600_000, items);
  }

  // Restock 3 days ago.
  txs.push({
    id: id(),
    type: "restock",
    amount: 24 * cost("noodles"),
    timestamp: today - 3 * DAY + 8 * 3_600_000,
    items: [{ productId: "noodles", qty: 24, unitPrice: cost("noodles") }],
    notes: "Restock",
  });

  // Customers and utang.
  const names = ["Juan", "Maria", "Pedro", "Ana", "Lito"];
  const customers: Customer[] = names.map((name, i) => ({
    id: `c-${name.toLowerCase()}`,
    name,
    look: LOOKS[i % LOOKS.length],
    createdAt: today - 30 * DAY,
  }));

  const utang = (cid: string, days: number, items: TxItem[], amount = sum(items)) =>
    txs.push({ id: id(), type: "utang_add", amount, timestamp: today - days * DAY + 11 * 3_600_000, customerId: cid, items });

  utang("c-juan", 6, [sold("sardinas", 2), sold("bigas", 3)], 250);
  utang("c-juan", 4, [sold("noodles", 4), sold("softdrinks", 4)], 200);
  utang("c-maria", 12, [sold("bigas", 5)], 500);
  txs.push({ id: id(), type: "utang_payment", amount: 200, timestamp: today - 8 * DAY + 16 * 3_600_000, customerId: "c-maria", items: [] });
  utang("c-pedro", 11, [sold("sardinas", 4), sold("noodles", 4)], 200);
  utang("c-ana", 15, [sold("kape", 5), sold("softdrinks", 5)], 150);
  utang("c-lito", 22, [sold("bigas", 2), sold("tansan", 2)], 150);

  txs.sort((a, b) => a.timestamp - b.timestamp);

  return {
    version: STATE_VERSION,
    products: products.map((p) => ({ ...p, lastRestocked: today - 3 * DAY })),
    customers,
    transactions: txs,
    chat: [
      { id: "m1", from: "user", text: "Kumikita ba ako ngayon?", timestamp: now - 60_000 },
      {
        id: "m2",
        from: "sari",
        text: "Oo, Aling Maria! 👋\nKita mo ngayon ay **₱650**. Mas mataas ito ng 12% kumpara kahapon. Ang pinaka-mabenta mo ngayong araw ay sardinas, na may 8 piraso.",
        tip: "Mag-restock ka na ng sardinas bago maubos. Malakas ang benta nito sa umaga.",
        timestamp: now - 50_000,
      },
    ],
    onboarded: false,
    capital: [{ id: "cap-1", amount: 2500, timestamp: today - 56 * DAY + 9 * 3_600_000, note: "Unang supply" }],
    dailyRevenue: {},
  };
}

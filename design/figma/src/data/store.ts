import { useCallback, useEffect, useMemo, useReducer } from "react";
import { LOOKS, STATE_VERSION, makeSeed } from "./seed";
import type { AppState, CapitalEntry, ChatMessage, Customer, Intent, Product, Transaction } from "./types";

const KEY = "sari-state-v1";

function load(): AppState {
  try {
    const raw = window.localStorage.getItem(KEY);
    if (raw) {
      const parsed = JSON.parse(raw) as AppState;
      if (parsed.version === STATE_VERSION && Array.isArray(parsed.products)) {
        // Older saves predate the capital feature.
        return { ...parsed, capital: parsed.capital ?? [], dailyRevenue: parsed.dailyRevenue ?? {} };
      }
    }
  } catch {
    // Storage unavailable or corrupt: fall back to the seed.
  }
  return makeSeed();
}

const slug = (s: string) => s.toLowerCase().replace(/[^a-z0-9ñ]+/g, "-").replace(/^-|-$/g, "");

function lookFor(name: string) {
  let h = 0;
  for (const ch of name) h = (h * 31 + ch.charCodeAt(0)) >>> 0;
  return LOOKS[h % LOOKS.length];
}

/** Applies a parsed transaction: records it, adjusts stock, creates customers on first mention. */
export function applyIntent(state: AppState, intent: Intent, now: number): AppState {
  let customers = state.customers;
  let customerId = intent.customerId;

  if (!customerId && intent.customerName) {
    customerId = `c-${slug(intent.customerName)}`;
    if (!customers.some((c) => c.id === customerId)) {
      const created: Customer = { id: customerId, name: intent.customerName, look: lookFor(intent.customerName), createdAt: now };
      customers = [...customers, created];
    }
  }

  const tx: Transaction = {
    id: `t-${now}-${state.transactions.length}`,
    type: intent.type,
    amount: intent.amount,
    timestamp: now,
    customerId,
    items: intent.items,
    notes: intent.notes,
  };

  const products = state.products.map((p) => {
    const item = intent.items.find((i) => i.productId === p.id);
    if (!item) return p;
    if (intent.type === "sale" || intent.type === "utang_add") return { ...p, qty: Math.max(p.qty - item.qty, 0) };
    if (intent.type === "restock") {
      return { ...p, qty: p.qty + item.qty, buyPrice: item.unitPrice > 0 ? item.unitPrice : p.buyPrice, lastRestocked: now };
    }
    return p;
  });

  return { ...state, customers, products, transactions: [...state.transactions, tx] };
}

type Action =
  | { type: "commit"; intent: Intent; now: number }
  | { type: "updateProduct"; id: string; patch: Partial<Product> }
  | { type: "chat"; msgs: ChatMessage[] }
  | { type: "resolveChat"; id: string; status: "saved" | "cancelled" }
  | { type: "addCustomer"; name: string; now: number }
  | { type: "addCapital"; entry: CapitalEntry }
  | { type: "removeCapital"; id: string }
  | { type: "setDayRevenue"; day: number; amount: number | null }
  | { type: "onboarded" }
  | { type: "reset"; now: number };

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "commit":
      return applyIntent(state, action.intent, action.now);
    case "updateProduct":
      return { ...state, products: state.products.map((p) => (p.id === action.id ? { ...p, ...action.patch } : p)) };
    case "chat":
      return { ...state, chat: [...state.chat, ...action.msgs] };
    case "resolveChat":
      return { ...state, chat: state.chat.map((m) => (m.id === action.id ? { ...m, status: action.status } : m)) };
    case "addCustomer": {
      const id = `c-${slug(action.name)}`;
      if (state.customers.some((c) => c.id === id)) return state;
      const created: Customer = { id, name: action.name, look: lookFor(action.name), createdAt: action.now };
      return { ...state, customers: [...state.customers, created] };
    }
    case "addCapital":
      return { ...state, capital: [...state.capital, action.entry] };
    case "removeCapital":
      return { ...state, capital: state.capital.filter((e) => e.id !== action.id) };
    case "setDayRevenue": {
      const next = { ...state.dailyRevenue };
      if (action.amount === null) delete next[String(action.day)];
      else next[String(action.day)] = action.amount;
      return { ...state, dailyRevenue: next };
    }
    case "onboarded":
      return { ...state, onboarded: true };
    case "reset":
      return { ...makeSeed(action.now), onboarded: true };
  }
}

export function useStore() {
  const [state, dispatch] = useReducer(reducer, undefined, load);

  useEffect(() => {
    try {
      window.localStorage.setItem(KEY, JSON.stringify(state));
    } catch {
      // Ignore quota or privacy-mode errors; the app keeps working in memory.
    }
  }, [state]);

  const commit = useCallback((intent: Intent) => dispatch({ type: "commit", intent, now: Date.now() }), []);
  const updateProduct = useCallback((id: string, patch: Partial<Product>) => dispatch({ type: "updateProduct", id, patch }), []);
  const addChat = useCallback((msgs: ChatMessage[]) => dispatch({ type: "chat", msgs }), []);
  const resolveChat = useCallback((id: string, status: "saved" | "cancelled") => dispatch({ type: "resolveChat", id, status }), []);
  const addCustomer = useCallback((name: string) => dispatch({ type: "addCustomer", name, now: Date.now() }), []);
  const addCapital = useCallback((amount: number, note: string) => {
    const now = Date.now();
    dispatch({ type: "addCapital", entry: { id: `cap-${now}`, amount, timestamp: now, note: note.trim() || "Puhunan" } });
  }, []);
  const removeCapital = useCallback((id: string) => dispatch({ type: "removeCapital", id }), []);
  const setDayRevenue = useCallback((day: number, amount: number | null) => dispatch({ type: "setDayRevenue", day, amount }), []);
  const completeOnboarding = useCallback(() => dispatch({ type: "onboarded" }), []);
  const resetDemo = useCallback(() => dispatch({ type: "reset", now: Date.now() }), []);

  return useMemo(
    () => ({ state, commit, updateProduct, addChat, resolveChat, addCustomer, addCapital, removeCapital, setDayRevenue, completeOnboarding, resetDemo }),
    [state, commit, updateProduct, addChat, resolveChat, addCustomer, addCapital, removeCapital, setDayRevenue, completeOnboarding, resetDemo],
  );
}

export type Store = ReturnType<typeof useStore>;

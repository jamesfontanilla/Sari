import { useCallback, useEffect, useState } from "react";
import { BottomNav, TAB_SCREENS, Toast } from "./components/ui";
import { useStore } from "./data/store";
import type { Nav, Route, ScreenName } from "./nav";
import Capital from "./screens/Capital";
import Chat from "./screens/Chat";
import CustomerDetail from "./screens/CustomerDetail";
import Customers from "./screens/Customers";
import Home from "./screens/Home";
import Inventory from "./screens/Inventory";
import Onboarding from "./screens/Onboarding";
import ProductDetail from "./screens/ProductDetail";
import Scan from "./screens/Scan";
import Settings from "./screens/Settings";
import Transactions from "./screens/Transactions";
import Voice from "./screens/Voice";
import Welcome from "./screens/Welcome";

export default function App() {
  const store = useStore();
  const [stack, setStack] = useState<Route[]>(() => [{ name: "welcome" }]);
  const [toast, setToast] = useState<string | null>(null);
  const route = stack[stack.length - 1];

  useEffect(() => {
    if (!toast) return;
    const timer = window.setTimeout(() => setToast(null), 3400);
    return () => window.clearTimeout(timer);
  }, [toast]);

  const go = useCallback((name: ScreenName, id?: string) => {
    setStack((s) => [...s, { name, id }]);
    window.scrollTo({ top: 0 });
  }, []);
  const back = useCallback(() => setStack((s) => (s.length > 1 ? s.slice(0, -1) : [{ name: "home" }])), []);
  const tab = useCallback((name: ScreenName) => {
    setStack([{ name }]);
    window.scrollTo({ top: 0 });
  }, []);

  const nav: Nav = { route, go, back, tab, notify: setToast };

  return (
    <div className="app-shell">
      {route.name === "welcome" && <Welcome nav={nav} store={store} />}
      {route.name === "onboarding" && <Onboarding nav={nav} store={store} />}
      {route.name === "home" && <Home nav={nav} store={store} />}
      {route.name === "transactions" && <Transactions nav={nav} store={store} />}
      {route.name === "inventory" && <Inventory nav={nav} store={store} />}
      {route.name === "customers" && <Customers nav={nav} store={store} />}
      {route.name === "chat" && <Chat nav={nav} store={store} />}
      {route.name === "voice" && <Voice nav={nav} store={store} />}
      {route.name === "scan" && <Scan nav={nav} store={store} />}
      {route.name === "product" && <ProductDetail key={route.id} nav={nav} store={store} />}
      {route.name === "customer" && <CustomerDetail key={route.id} nav={nav} store={store} />}
      {route.name === "settings" && <Settings nav={nav} store={store} />}
      {route.name === "capital" && <Capital nav={nav} store={store} />}
      {TAB_SCREENS.includes(route.name) && <BottomNav current={route.name} nav={nav} />}
      <Toast message={toast} />
    </div>
  );
}

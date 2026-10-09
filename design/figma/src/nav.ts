export type ScreenName =
  | "welcome"
  | "onboarding"
  | "home"
  | "transactions"
  | "inventory"
  | "customers"
  | "chat"
  | "voice"
  | "scan"
  | "product"
  | "customer"
  | "settings"
  | "capital";

export type Route = { name: ScreenName; id?: string };

export type Nav = {
  route: Route;
  go: (name: ScreenName, id?: string) => void;
  back: () => void;
  tab: (name: ScreenName) => void;
  notify: (message: string) => void;
};

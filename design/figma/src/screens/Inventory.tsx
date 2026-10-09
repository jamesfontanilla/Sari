import { useState } from "react";
import { ProductCard } from "../components/cards";
import Icon from "../components/Icon";
import { Chip, PillButton, TopBar } from "../components/ui";
import type { Store } from "../data/store";
import type { Nav } from "../nav";

type Filter = "all" | "low" | "categories";

export default function Inventory({ store, nav }: { store: Store; nav: Nav }) {
  const { products } = store.state;
  const [filter, setFilter] = useState<Filter>("all");
  const shown = filter === "low" ? products.filter((p) => p.qty <= p.threshold) : products;
  const groups =
    filter === "categories"
      ? Array.from(new Set(products.map((p) => p.category))).map((title) => ({ title, items: products.filter((p) => p.category === title) }))
      : [{ title: "", items: shown }];

  return (
    <main className="screen has-nav">
      <TopBar title="Paninda" />
      <div className="page">
        <div className="chips" role="tablist">
          <Chip active={filter === "all"} onClick={() => setFilter("all")}>Lahat</Chip>
          <Chip active={filter === "low"} onClick={() => setFilter("low")}>Low Stock</Chip>
          <Chip active={filter === "categories"} onClick={() => setFilter("categories")}>Kategorya</Chip>
        </div>
        {groups.map((g) => (
          <section key={g.title || "all"}>
            {g.title && <h3 className="group-title">{g.title}</h3>}
            <div className="card list">
              {g.items.length === 0 ? (
                <div className="empty-row">
                  <Icon name="check" size={18} stroke={2.6} /> Walang low stock ngayon!
                </div>
              ) : (
                g.items.map((p) => <ProductCard key={p.id} onClick={() => nav.go("product", p.id)} product={p} />)
              )}
            </div>
          </section>
        ))}
        <PillButton className="inline-cta" onClick={() => nav.go("scan")}>
          <Icon name="camera" size={20} /> I-scan ang shelf
        </PillButton>
      </div>
    </main>
  );
}

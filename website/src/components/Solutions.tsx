import { Catalog, money } from '../api';
export function Solutions({ catalog, error, onRetry, onSelectProduct }: { catalog: Catalog | null; error: string; onRetry: () => void; onSelectProduct: (id: string) => void }) {
  return <section id="product" className="scroll-mt-24 bg-secondary/30 py-20"><div className="mx-auto max-w-7xl px-6 lg:px-10">
    <p className="text-xs font-semibold uppercase tracking-widest text-primary">Thiết bị & vật tư</p><h2 className="mt-3 font-display text-4xl font-semibold">Chọn khởi đầu xanh của bạn</h2>
    <p className="mt-4 max-w-2xl text-muted-foreground">Mua thiết bị hoặc gói refill theo số chu kỳ phù hợp. Toàn bộ vật tư của gói được giao cùng một lần, không tự động gia hạn.</p>
    {error && <div role="alert" className="mt-6 rounded-2xl border border-border bg-card p-5">{error} <button onClick={onRetry} className="text-primary underline">Thử lại</button></div>}
    {!catalog && !error && <p className="mt-6" role="status">Đang tải sản phẩm…</p>}
    {catalog && !catalog.items.length && <p className="mt-6">Sản phẩm sẽ sớm mở bán.</p>}
    <div className="mt-10 grid gap-6 md:grid-cols-2 lg:grid-cols-3">{catalog?.items.map(p => <article key={p.id} className="flex flex-col overflow-hidden rounded-3xl border border-border bg-card shadow-soft">
      <img src={p.kind === 'refill' ? '/assets/product-refill.jpg' : '/assets/product-core.jpg'} alt={p.name} className="aspect-[4/3] w-full object-cover" />
      <div className="flex flex-1 flex-col p-6"><p className="text-xs font-semibold text-primary">{p.kind === 'refill' ? `${p.cycleCount} chu kỳ · giao một lần` : 'Thiết bị phần cứng'}</p><h3 className="mt-2 font-display text-2xl">{p.name}</h3><p className="mt-3 flex-1 text-sm text-muted-foreground">{p.contents}</p>
      <p className="mt-6 text-xl font-semibold text-primary">{money(p.priceVnd)}</p><button className="store-button mt-4" onClick={() => onSelectProduct(p.id)}>Chọn mua</button></div>
    </article>)}</div>
  </div></section>;
}

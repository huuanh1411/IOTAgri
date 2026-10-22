import { useEffect, useState } from 'react';
import { api, Product, Order, Page } from '../api';
import { useAuth } from '../context/AuthContext';
import { StoreDialog } from './StoreDialog';
import { OrderCard } from './UserOrdersModal';
const blank = (): Product => ({ id: crypto.randomUUID(), sku: '', name: '', kind: 'refill', cycleCount: 1, contents: '', priceVnd: 299000, isActive: false });
export function AdminModal({ onClose, onOpenAuthModal, onCatalogChanged }: { onClose: () => void; onOpenAuthModal: () => void; onCatalogChanged: () => void }) {
  const { isAdmin } = useAuth();
  const [products, setProducts] = useState<Product[]>([]), [orders, setOrders] = useState<Page<Order> | null>(null), [page, setPage] = useState(1);
  const [form, setForm] = useState<Product>(blank), [error, setError] = useState(''), [busy, setBusy] = useState(false), [notice, setNotice] = useState('');
  const load = async () => { try { const [p, o] = await Promise.all([api<Product[]>('/api/admin/store/products'), api<Page<Order>>(`/api/admin/store/orders?page=${page}`)]); setProducts(p); setOrders(o); } catch(e) { setError((e as Error).message); } };
  useEffect(() => { if (isAdmin) void load(); }, [isAdmin, page]);
  return <StoreDialog title="Quản lý cửa hàng" onClose={onClose}>
    {!isAdmin ? <p>Bạn cần quyền quản trị. <button className="text-primary underline" onClick={onOpenAuthModal}>Đăng nhập</button></p> : <div className="space-y-6">
      <section><h3 className="font-semibold">Thiết bị & gói refill</h3><div className="my-3 flex flex-wrap gap-2">{products.map(p => <button key={p.id} onClick={() => { setForm(p); setNotice(''); }} className="rounded-full border border-border px-3 py-2 text-xs">{p.name}{!p.isActive ? ' · Ẩn' : ''}</button>)}<button onClick={() => { setForm(blank()); setNotice(''); }} className="text-sm text-primary underline">+ Thêm gói/sản phẩm</button></div>
      <form className="space-y-3 rounded-xl bg-secondary/30 p-4" onSubmit={async e => { e.preventDefault(); setBusy(true); setError(''); setNotice(''); try { await api(`/api/admin/store/products/${form.id}`, { method: 'PUT', body: JSON.stringify(form) }); await load(); onCatalogChanged(); setNotice('Đã lưu sản phẩm.'); } catch(e) { setError((e as Error).message); } finally { setBusy(false); } }}>
        <label className="store-label">Mã SKU<input className="store-input" maxLength={80} required value={form.sku} onChange={e => setForm({ ...form, sku: e.target.value })} /></label>
        <label className="store-label">Tên gói/sản phẩm<input className="store-input" maxLength={200} required value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} /></label>
        <label className="store-label">Loại<select className="store-input" value={form.kind} onChange={e => setForm({ ...form, kind: e.target.value as Product['kind'], cycleCount: e.target.value === 'hardware' ? 0 : 1 })}><option value="hardware">Thiết bị</option><option value="refill">Refill</option></select></label>
        {form.kind === 'refill' && <label className="store-label">Số chu kỳ trong gói<input className="store-input" type="number" min={1} max={100} required value={form.cycleCount} onChange={e => setForm({ ...form, cycleCount: Number(e.target.value) })} /></label>}
        <label className="store-label">Toàn bộ vật tư/sản phẩm giao cho khách<textarea className="store-input" maxLength={4000} required value={form.contents} onChange={e => setForm({ ...form, contents: e.target.value })} /></label>
        <label className="store-label">Giá toàn gói (VND)<input className="store-input" type="number" min={form.isActive ? 1000 : 0} max={50000000} step={1} required value={form.priceVnd} onChange={e => setForm({ ...form, priceVnd: Number(e.target.value) })} /></label>
        <label className="flex items-center gap-2 text-sm"><input type="checkbox" checked={form.isActive} onChange={e => setForm({ ...form, isActive: e.target.checked })} />Mở bán</label>
        <p className="text-xs text-muted-foreground">Giao toàn bộ một lần. Thay đổi gói không làm đổi đơn hàng đã tạo.</p><button disabled={busy} className="store-button">Lưu sản phẩm</button>{notice && <p role="status" className="text-sm text-primary">{notice}</p>}
      </form></section>
      <section><h3 className="mb-3 font-semibold">Đơn hàng</h3><button className="mb-3 text-sm text-primary underline" onClick={() => void load()}>Tải lại</button>
        {orders?.items.map(o => <article className="mb-4 rounded-xl border border-border p-4" key={o.id}><OrderCard order={o} />
          {o.paymentStatus === 'paid' && o.fulfillmentStatus !== 'delivered' && <form className="mt-3 flex flex-wrap gap-2" onSubmit={async e => { e.preventDefault(); const tracking = new FormData(e.currentTarget).get('trackingNumber'); setBusy(true); setError(''); try { await api(`/api/admin/store/orders/${o.id}/fulfillment`, { method: 'PUT', body: JSON.stringify({ status: o.fulfillmentStatus === 'unfulfilled' ? 'shipping' : 'delivered', trackingNumber: tracking || o.trackingNumber }) }); await load(); } catch(e) { setError((e as Error).message); } finally { setBusy(false); } }}>
            {o.fulfillmentStatus === 'unfulfilled' && <input name="trackingNumber" aria-label="Mã vận đơn" maxLength={200} placeholder="Mã vận đơn" className="store-input" />}<button disabled={busy} className="store-button">{o.fulfillmentStatus === 'unfulfilled' ? 'Xác nhận đang giao' : 'Xác nhận đã giao'}</button>
          </form>}
        </article>)}
        {orders && !orders.totalCount && <p className="text-sm">Chưa có đơn hàng.</p>}
        {orders && orders.totalCount > 20 && <div className="flex justify-between"><button disabled={page === 1} onClick={() => setPage(p => p-1)}>Trang trước</button><span>{page}</span><button disabled={page * 20 >= orders.totalCount} onClick={() => setPage(p => p+1)}>Trang sau</button></div>}
      </section>
    </div>}
    {error && <p role="alert" className="mt-4 text-sm text-red-700">{error}</p>}
  </StoreDialog>;
}

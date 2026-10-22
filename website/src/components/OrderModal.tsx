import { useEffect, useRef, useState } from 'react';
import { api, Catalog, money, Order, pay } from '../api';
import { useAuth } from '../context/AuthContext';
import { StoreDialog } from './StoreDialog';
export function OrderModal({ catalog, defaultProduct, onClose, onOpenAuthModal }: { catalog: Catalog | null; defaultProduct?: string; onClose: () => void; onOpenAuthModal: () => void }) {
  const { user } = useAuth();
  const [quantities, setQuantities] = useState<Record<string, number>>(() => defaultProduct ? { [defaultProduct]: 1 } : {});
  const [name, setName] = useState(user?.name || ''), [phone, setPhone] = useState(user?.phoneNumber || ''), [address, setAddress] = useState('');
  const [error, setError] = useState(''), [busy, setBusy] = useState(false), [order, setOrder] = useState<Order | null>(null);
  const key = useRef(crypto.randomUUID()), submitting = useRef(false);
  useEffect(() => { if (user) { setName(n => n || user.name); setPhone(p => p || user.phoneNumber || ''); } }, [user]);
  const selected = catalog?.items.filter(p => quantities[p.id] > 0) || [];
  const total = selected.reduce((sum, p) => sum + p.priceVnd * quantities[p.id], catalog?.shippingFeeVnd || 0);
  return <StoreDialog title={order ? 'Đơn hàng đã được tạo' : 'Chọn sản phẩm & thanh toán'} onClose={onClose}>
    <p className="mb-4 text-sm text-muted-foreground">Giao toàn bộ thiết bị và vật tư trong một lần. Gói refill không tự động gia hạn.</p>
    {order ? <div className="space-y-4"><p>Mã đơn: <strong>{order.id}</strong></p><p>Tổng thanh toán: <strong>{money(order.totalVnd)}</strong></p><p className="text-sm">Đơn đang chờ thanh toán. Bạn cũng có thể mở lại từ “Đơn hàng của tôi”.</p>
      <button disabled={busy} className="store-button w-full" onClick={async () => { setBusy(true); setError(''); try { await pay(order.id); } catch(e) { setError((e as Error).message); } finally { setBusy(false); } }}>{busy ? 'Đang kết nối MoMo…' : 'Tiếp tục thanh toán MoMo'}</button>
    </div> : <form className="space-y-4" onSubmit={async e => {
      e.preventDefault(); if (submitting.current) return;
      if (!user) { onOpenAuthModal(); return; }
      submitting.current = true; setBusy(true); setError('');
      try {
        const created = await api<Order>('/api/store/orders', { method: 'POST', body: JSON.stringify({ checkoutKey: key.current, customerName: name, phone, address, expectedTotalVnd: total, items: selected.map(p => ({ productId: p.id, quantity: quantities[p.id] })) }) });
        setOrder(created);
        await pay(created.id);
      } catch(e) { setError((e as Error).message); } finally { submitting.current = false; setBusy(false); }
    }}>
      {!catalog && <p role="status">Chưa tải được danh mục. Đóng cửa sổ và thử tải lại sản phẩm.</p>}
      {catalog?.items.map(p => <label key={p.id} className="flex items-center justify-between gap-4 rounded-xl border border-border p-3">
        <span className="text-sm"><strong>{p.name}</strong><span className="mt-1 block text-muted-foreground">{money(p.priceVnd)}{p.kind === 'refill' ? ` · ${p.cycleCount} chu kỳ/gói` : ''}</span></span>
        <input aria-label={`Số lượng ${p.name}`} type="number" min="0" max="20" className="w-20 rounded-lg border border-border bg-background p-2" value={quantities[p.id] || 0} onChange={e => { setQuantities({ ...quantities, [p.id]: Math.min(20, Math.max(0, Number(e.target.value) || 0)) }); }} />
      </label>)}
      <label className="store-label">Người nhận<input className="store-input" required maxLength={200} autoComplete="name" value={name} onChange={e => setName(e.target.value)} /></label>
      <label className="store-label">Số điện thoại<input className="store-input" required type="tel" maxLength={30} autoComplete="tel" value={phone} onChange={e => setPhone(e.target.value)} /></label>
      <label className="store-label">Địa chỉ nhận hàng<textarea className="store-input" required maxLength={1000} autoComplete="street-address" value={address} onChange={e => setAddress(e.target.value)} /></label>
      <div className="rounded-xl bg-secondary/50 p-4"><p className="text-sm">Phí giao hàng: {money(catalog?.shippingFeeVnd || 0)}</p><p className="mt-2 font-semibold">Tổng: {money(total)}</p></div>
      {catalog && !catalog.paymentAvailable && <p role="status" className="text-sm text-amber-800">Thanh toán MoMo chưa mở. Bạn có thể xem các sản phẩm và quay lại sau.</p>}
      {!user && <p className="text-sm">Vui lòng <button type="button" onClick={onOpenAuthModal} className="text-primary underline">đăng nhập tài khoản Aerogreen</button> trước khi đặt hàng.</p>}
      <button disabled={busy || !selected.length || !catalog?.paymentAvailable} className="store-button w-full">{busy ? 'Đang xử lý…' : user ? 'Đặt hàng & thanh toán MoMo' : 'Đăng nhập để tiếp tục'}</button>
    </form>}
    {error && <p role="alert" className="mt-4 text-sm text-red-700">{error}</p>}
  </StoreDialog>;
}

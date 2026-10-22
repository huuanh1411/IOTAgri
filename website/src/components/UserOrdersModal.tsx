import { useEffect, useState } from 'react';
import { api, Order, Page, money, pay } from '../api';
import { StoreDialog } from './StoreDialog';
const paymentText: Record<string,string> = { pending: 'Chờ xác nhận thanh toán', paid: 'Đã thanh toán', failed: 'Thanh toán thất bại' };
const shippingText: Record<string,string> = { unfulfilled: 'Chưa giao', shipping: 'Đang giao', delivered: 'Đã giao' };
export function OrderCard({ order }: { order: Order }) {
  return <><p className="break-all text-xs text-muted-foreground">Mã đơn {order.id}</p><p className="mt-1 text-sm">{new Date(order.createdAt).toLocaleString('vi-VN')}</p>
    {order.items.map((i, n) => <div key={n} className="mt-3 text-sm"><strong>{i.name} × {i.quantity}</strong><p className="text-muted-foreground">{i.contents}{i.cycleCount ? ` · ${i.cycleCount} chu kỳ/gói` : ''}</p></div>)}
    <p className="mt-3 font-semibold">{money(order.totalVnd)}</p><p className="mt-1 text-sm">{paymentText[order.paymentStatus] || order.paymentStatus} · {shippingText[order.fulfillmentStatus] || order.fulfillmentStatus}</p>
    <p className="mt-2 text-sm text-muted-foreground">{order.customerName} · {order.phone}<br />{order.address}</p>{order.trackingNumber && <p className="mt-2 text-sm">Mã vận đơn: {order.trackingNumber}</p>}
  </>;
}
export function UserOrdersModal({ onClose }: { onClose: () => void }) {
  const [data, setData] = useState<Page<Order> | null>(null), [page, setPage] = useState(1);
  const [error, setError] = useState(''), [busy, setBusy] = useState(false);
  const returnedOrder = new URLSearchParams(window.location.search).get('storeOrderId');
  const [returned, setReturned] = useState<Order | null>(null);
  const load = async () => {
    try { const next = await api<Page<Order>>(`/api/store/orders?page=${page}`); setData(next);
      if (returnedOrder) setReturned(await api<Order>(`/api/store/orders/${encodeURIComponent(returnedOrder)}`));
      setError('');
    } catch(e) { setError((e as Error).message); }
  };
  useEffect(() => { void load(); }, [page]);
  useEffect(() => {
    if (!returnedOrder || returned?.paymentStatus === 'paid' || returned?.paymentStatus === 'failed') return;
    const timer = setInterval(() => { void load(); }, 5000); return () => clearInterval(timer);
  }, [returnedOrder, returned?.paymentStatus, page]);
  return <StoreDialog title="Đơn hàng của tôi" onClose={onClose}>
    {returnedOrder && <div className="mb-4 rounded-xl bg-secondary p-4 text-sm">Kết quả được lấy từ hệ thống thanh toán. {returned?.paymentStatus === 'paid' ? 'Đơn đã thanh toán thành công.' : returned?.paymentStatus === 'failed' ? 'Giao dịch chưa thành công.' : 'Đang chờ MoMo xác nhận. Không cần thanh toán lại nếu ví đã bị trừ tiền.'}</div>}
    <button className="mb-4 text-sm text-primary underline" onClick={() => void load()}>Cập nhật trạng thái</button>
    {error && <p role="alert" className="mb-4 text-sm text-red-700">{error}</p>}
    {!data && !error && <p role="status">Đang tải đơn hàng…</p>}
    {returned && !data?.items.some(o => o.id === returned.id) && <article className="mb-4 rounded-xl border border-border p-4"><OrderCard order={returned} /></article>}
    {data?.items.map(o => <article key={o.id} className="mb-4 rounded-xl border border-border p-4"><OrderCard order={o} />
      {o.paymentStatus === 'pending' && <button disabled={busy} className="store-button mt-4" onClick={async () => { setBusy(true); setError(''); try { await pay(o.id); } catch(e) { setError((e as Error).message); } finally { setBusy(false); } }}>Tiếp tục thanh toán MoMo</button>}
    </article>)}
    {data && !data.totalCount && <p>Bạn chưa có đơn hàng.</p>}
    {data && data.totalCount > 20 && <div className="flex items-center justify-between"><button disabled={page === 1} onClick={() => setPage(p => p-1)}>Trang trước</button><span>Trang {page}</span><button disabled={page * 20 >= data.totalCount} onClick={() => setPage(p => p+1)}>Trang sau</button></div>}
  </StoreDialog>;
}

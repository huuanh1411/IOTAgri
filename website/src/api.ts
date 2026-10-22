const base = ((import.meta as unknown as { env: Record<string, string> }).env.VITE_API_BASE_URL || '').replace(/\/$/, '');
const ACCESS = 'aerogreen_store_access', REFRESH = 'aerogreen_store_refresh';
let refreshing: Promise<boolean> | null = null;
export const tokens = {
  access: () => sessionStorage.getItem(ACCESS), refresh: () => sessionStorage.getItem(REFRESH),
  save: (data: { accessToken: string; refreshToken: string }) => { sessionStorage.setItem(ACCESS, data.accessToken); sessionStorage.setItem(REFRESH, data.refreshToken); },
  clear: () => { sessionStorage.removeItem(ACCESS); sessionStorage.removeItem(REFRESH); }
};
async function renew() {
  if (!tokens.refresh()) return false;
  try {
    const res = await fetch(base + '/api/auth/refresh', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refreshToken: tokens.refresh() }) });
    if (!res.ok) { tokens.clear(); return false; }
    tokens.save(await res.json()); return true;
  } catch { return false; }
}
export async function api<T>(path: string, init: RequestInit = {}, auth = true): Promise<T> {
  const send = () => fetch(base + path, { ...init, headers: { 'Content-Type': 'application/json', ...(auth && tokens.access() ? { Authorization: `Bearer ${tokens.access()}` } : {}), ...init.headers } });
  let res = await send();
  if (res.status === 401 && auth) { refreshing ??= renew().finally(() => { refreshing = null; }); if (await refreshing) res = await send(); }
  const data = res.status === 204 ? null : await res.json().catch(() => null);
  if (!res.ok) {
    const errors = data?.errors ? Object.values(data.errors).flat().join(' ') : '';
    throw new Error(data?.error || data?.detail || errors || (res.status === 401 ? 'Vui lòng đăng nhập lại.' : 'Không thể xử lý yêu cầu. Vui lòng thử lại.'));
  }
  return data as T;
}
export interface Product { id: string; sku: string; name: string; kind: 'hardware' | 'refill'; cycleCount: number; contents: string; priceVnd: number; isActive: boolean }
export interface Catalog { items: Product[]; paymentAvailable: boolean; fulfillment: string; shippingFeeVnd: number }
export interface Order { id: string; customerName: string; phone: string; address: string; totalVnd: number; paymentStatus: string; fulfillmentStatus: string; trackingNumber?: string; createdAt: string; items: { name: string; quantity: number; cycleCount: number; contents: string; unitPriceVnd: number }[] }
export interface Page<T> { items: T[]; page: number; pageSize: number; totalCount: number }
export const money = (value: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
export async function pay(id: string) {
  const { payUrl } = await api<{ payUrl: string }>(`/api/store/orders/${id}/payment`, { method: 'POST' });
  const url = new URL(payUrl);
  if (url.protocol !== 'https:' || !['payment.momo.vn', 'test-payment.momo.vn'].includes(url.hostname)) throw new Error('Liên kết thanh toán không hợp lệ.');
  window.location.assign(url.href);
}

import { useCallback, useEffect, useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { api, Catalog } from './api';
import { Header } from './components/Header';
import { Hero } from './components/Hero';
import { Solutions } from './components/Solutions';
import { ProductDetail } from './components/ProductDetail';
import { Team } from './components/Team';
import { Footer } from './components/Footer';
import { OrderModal } from './components/OrderModal';
import { AdminModal } from './components/AdminModal';
import { AuthModal } from './components/AuthModal';
import { UserOrdersModal } from './components/UserOrdersModal';
function MainContent() {
  const { user, loading } = useAuth();
  const [catalog, setCatalog] = useState<Catalog | null>(null), [catalogError, setCatalogError] = useState('');
  const [buy, setBuy] = useState(false), [admin, setAdmin] = useState(false), [auth, setAuth] = useState(false), [orders, setOrders] = useState(false);
  const [selected, setSelected] = useState<string>();
  const loadCatalog = useCallback(async () => { setCatalogError(''); try { setCatalog(await api<Catalog>('/api/store/products', {}, false)); } catch { setCatalogError('Chưa tải được sản phẩm. Vui lòng thử lại.'); } }, []);
  useEffect(() => { void loadCatalog(); }, [loadCatalog]);
  useEffect(() => { if (!loading && new URLSearchParams(window.location.search).has('storeOrderId')) { if (user) setOrders(true); else setAuth(true); } }, [user, loading]);
  const openBuy = (id?: string) => { setSelected(id); setBuy(true); };
  const closeOrders = () => { setOrders(false); const url = new URL(window.location.href); if (url.searchParams.has('storeOrderId')) { url.search = ''; window.history.replaceState(null, '', url.pathname + url.hash); } };
  return <div className="min-h-screen bg-background text-foreground selection:bg-primary/20 selection:text-primary">
    <Header onOpenOrderModal={() => openBuy()} onOpenAuthModal={() => setAuth(true)} onOpenUserOrdersModal={() => setOrders(true)} onOpenAdminModal={() => setAdmin(true)} />
    <main><Hero onOpenOrderModal={() => openBuy()} /><Solutions catalog={catalog} error={catalogError} onRetry={() => void loadCatalog()} onSelectProduct={openBuy} /><ProductDetail /><Team /></main>
    <Footer onOpenAdminModal={() => setAdmin(true)} onOpenOrderModal={() => openBuy()} />
    {buy && <OrderModal catalog={catalog} defaultProduct={selected} onClose={() => setBuy(false)} onOpenAuthModal={() => setAuth(true)} />}
    {orders && user && <UserOrdersModal onClose={closeOrders} />}
    {admin && <AdminModal onClose={() => setAdmin(false)} onOpenAuthModal={() => setAuth(true)} onCatalogChanged={() => void loadCatalog()} />}
    <AuthModal isOpen={auth} onClose={() => setAuth(false)} />
  </div>;
}
export default function App() { return <AuthProvider><MainContent /></AuthProvider>; }

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { api, tokens } from '../api';
export interface User { id: string; name: string; email: string; role: 'admin' | 'user'; phoneNumber?: string; avatar_url?: string }
interface Profile { id: string; fullName: string; email: string; phoneNumber?: string; roles: string[] }
interface Result { success: boolean; error?: string }
interface Auth { user: User | null; loading: boolean; isAdmin: boolean; login: (email: string, password: string) => Promise<Result>; register: (name: string, email: string, password: string) => Promise<Result>; logout: () => void }
const Context = createContext<Auth | null>(null);
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null), [loading, setLoading] = useState(true);
  const profile = async () => {
    const p = await api<Profile>('/api/auth/profile');
    setUser({ id: p.id, name: p.fullName, email: p.email, phoneNumber: p.phoneNumber, role: p.roles.includes('Admin') ? 'admin' : 'user' });
  };
  useEffect(() => { if (!tokens.access()) { setLoading(false); return; }
    profile().catch(() => { tokens.clear(); setUser(null); }).finally(() => setLoading(false));
  }, []);
  const login = async (email: string, password: string): Promise<Result> => {
    try { tokens.save(await api('/api/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) }, false)); await profile(); return { success: true }; }
    catch (e) { tokens.clear(); return { success: false, error: (e as Error).message }; }
  };
  const register = async (fullName: string, email: string, password: string): Promise<Result> => {
    try { await api('/api/auth/register', { method: 'POST', body: JSON.stringify({ fullName, email, password }) }, false); return await login(email, password); }
    catch (e) { return { success: false, error: (e as Error).message }; }
  };
  const logout = () => {
    const refreshToken = tokens.refresh();
    if (refreshToken) void api('/api/auth/logout', { method: 'POST', body: JSON.stringify({ refreshToken }) }).catch(() => {});
    tokens.clear(); setUser(null);
  };
  return <Context.Provider value={{ user, loading, isAdmin: user?.role === 'admin', login, register, logout }}>{children}</Context.Provider>;
}
export function useAuth() { const auth = useContext(Context); if (!auth) throw new Error('AuthProvider is required'); return auth; }

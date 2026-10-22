import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { StoreDialog } from './StoreDialog';
export function AuthModal({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) {
  const { login, register } = useAuth();
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [name, setName] = useState(''), [email, setEmail] = useState(''), [password, setPassword] = useState('');
  const [error, setError] = useState(''), [busy, setBusy] = useState(false);
  if (!isOpen) return null;
  return <StoreDialog title={mode === 'login' ? 'Đăng nhập Aerogreen' : 'Tạo tài khoản Aerogreen'} onClose={onClose}>
    <p className="mb-4 text-sm text-muted-foreground">Dùng chung tài khoản với ứng dụng Aerogreen.</p>
    <form className="space-y-4" onSubmit={async e => { e.preventDefault(); setBusy(true); setError('');
      const result = mode === 'login' ? await login(email, password) : await register(name, email, password);
      setBusy(false); if (result.success) { setPassword(''); onClose(); } else setError(result.error || 'Không thể đăng nhập.'); }}>
      {mode === 'register' && <label className="store-label">Họ tên<input className="store-input" required maxLength={200} value={name} onChange={e => setName(e.target.value)} autoComplete="name" /></label>}
      <label className="store-label">Email<input className="store-input" type="email" required value={email} onChange={e => setEmail(e.target.value)} autoComplete="email" /></label>
      <label className="store-label">Mật khẩu<input className="store-input" type="password" required minLength={mode === 'register' ? 8 : 1} value={password} onChange={e => setPassword(e.target.value)} autoComplete={mode === 'register' ? 'new-password' : 'current-password'} /></label>
      {mode === 'register' && <p className="text-xs text-muted-foreground">Ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>}
      {error && <p role="alert" className="text-sm text-red-700">{error}</p>}
      <button disabled={busy} className="store-button w-full">{busy ? 'Đang xử lý…' : mode === 'login' ? 'Đăng nhập' : 'Đăng ký'}</button>
    </form><button className="mt-4 text-sm text-primary underline" onClick={() => { setMode(mode === 'login' ? 'register' : 'login'); setError(''); }}>{mode === 'login' ? 'Chưa có tài khoản? Đăng ký' : 'Đã có tài khoản? Đăng nhập'}</button>
  </StoreDialog>;
}

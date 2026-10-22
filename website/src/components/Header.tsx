import React, { useState, useRef, useEffect } from 'react';
import { Leaf, User as UserIcon, LogOut, Package, ShieldCheck, ChevronDown } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

interface HeaderProps {
  onOpenOrderModal: () => void;
  onOpenAuthModal: () => void;
  onOpenUserOrdersModal: () => void;
  onOpenAdminModal: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  onOpenOrderModal,
  onOpenAuthModal,
  onOpenUserOrdersModal,
  onOpenAdminModal,
}) => {
  const { user, isAdmin, logout } = useAuth();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown on outside click
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .filter(Boolean)
      .slice(-2)
      .join('')
      .toUpperCase();
  };

  return (
    <header className="absolute inset-x-0 top-0 z-20">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-6 lg:px-10">
        <a
          href="#top"
          className="flex items-center gap-2 font-display text-lg font-semibold tracking-tight"
        >
          <span className="grid h-9 w-9 place-items-center rounded-full bg-primary text-primary-foreground shadow-soft">
            <Leaf className="h-4 w-4" strokeWidth={2.2} />
          </span>
          Aerogreen
        </a>

        <nav className="hidden items-center gap-8 text-sm text-muted-foreground md:flex">
          <a href="#product" className="transition hover:text-foreground">
            Sản phẩm
          </a>
          <a href="#solutions" className="transition hover:text-foreground">
            Giải pháp
          </a>
          <a href="#team" className="transition hover:text-foreground">
            Đội ngũ
          </a>
          <a href="#contact" className="transition hover:text-foreground">
            Liên hệ
          </a>
        </nav>

        <div className="flex items-center gap-3">
          {user ? (
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="flex items-center gap-2 rounded-full border border-border bg-card/80 py-1.5 pl-2 pr-3 text-xs font-medium text-foreground shadow-sm backdrop-blur transition hover:bg-secondary cursor-pointer"
              >
                {user.avatar_url ? (
                  <img
                    src={user.avatar_url}
                    alt={user.name}
                    className="h-7 w-7 rounded-full object-cover"
                  />
                ) : (
                  <span className="grid h-7 w-7 place-items-center rounded-full bg-primary text-[11px] font-bold text-primary-foreground">
                    {getInitials(user.name)}
                  </span>
                )}
                <span className="max-w-[100px] truncate">{user.name}</span>
                <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
              </button>

              {/* User Dropdown */}
              {dropdownOpen && (
                <div className="absolute right-0 mt-2 w-56 rounded-2xl border border-border bg-card p-2 shadow-xl animate-in fade-in zoom-in-95 z-30">
                  <div className="border-b border-border px-3 py-2">
                    <p className="text-xs font-semibold text-foreground truncate">{user.name}</p>
                    <p className="text-[11px] text-muted-foreground truncate">{user.email}</p>
                    <span
                      className={`mt-1.5 inline-block rounded-full px-2 py-0.5 text-[10px] font-medium ${
                        isAdmin
                          ? 'bg-amber-500/10 text-amber-600'
                          : 'bg-primary/10 text-primary'
                      }`}
                    >
                      {isAdmin ? 'Quản trị viên' : 'Khách hàng'}
                    </span>
                  </div>

                  <div className="py-1 text-xs">
                    <button
                      onClick={() => {
                        setDropdownOpen(false);
                        onOpenUserOrdersModal();
                      }}
                      className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-foreground transition hover:bg-secondary cursor-pointer"
                    >
                      <Package className="h-4 w-4 text-muted-foreground" />
                      <span>Đơn hàng của tôi</span>
                    </button>

                    {isAdmin && (
                      <button
                        onClick={() => {
                          setDropdownOpen(false);
                          onOpenAdminModal();
                        }}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-primary font-medium transition hover:bg-primary/10 cursor-pointer"
                      >
                        <ShieldCheck className="h-4 w-4" />
                        <span>Bảng Quản Trị XTeam</span>
                      </button>
                    )}

                    <button
                      onClick={() => {
                        setDropdownOpen(false);
                        logout();
                      }}
                      className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-destructive transition hover:bg-destructive/10 cursor-pointer"
                    >
                      <LogOut className="h-4 w-4" />
                      <span>Đăng xuất</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <button
              onClick={onOpenAuthModal}
              className="inline-flex items-center gap-1.5 rounded-full border border-border bg-card/80 px-4 py-2 text-xs font-medium text-foreground backdrop-blur transition hover:bg-secondary cursor-pointer"
            >
              <UserIcon className="h-3.5 w-3.5 text-muted-foreground" />
              <span>Đăng nhập</span>
            </button>
          )}

          <button
            onClick={onOpenOrderModal}
            className="hidden rounded-full bg-foreground px-5 py-2 text-sm font-medium text-background transition hover:opacity-90 md:inline-block cursor-pointer"
          >
            Chọn mua ngay
          </button>
        </div>
      </div>
    </header>
  );
};

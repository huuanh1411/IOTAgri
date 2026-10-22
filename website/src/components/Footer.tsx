import React from 'react';
import { Leaf, Twitter, Instagram, Linkedin, Github, ShieldCheck } from 'lucide-react';

const socialLinks = [
  { icon: Twitter, href: '#', label: 'Twitter' },
  { icon: Instagram, href: '#', label: 'Instagram' },
  { icon: Linkedin, href: '#', label: 'LinkedIn' },
  { icon: Github, href: '#', label: 'GitHub' },
];

interface FooterProps {
  onOpenAdminModal: () => void;
  onOpenOrderModal: () => void;
}

export const Footer: React.FC<FooterProps> = ({ onOpenAdminModal, onOpenOrderModal }) => {
  return (
    <footer id="contact" className="scroll-mt-24 border-t border-border bg-secondary/50">
      <div className="mx-auto grid max-w-7xl gap-10 px-6 py-14 lg:grid-cols-3 lg:px-10">
        <div>
          <a href="#top" className="flex items-center gap-2 font-display text-lg font-semibold">
            <span className="grid h-9 w-9 place-items-center rounded-full bg-primary text-primary-foreground">
              <Leaf className="h-4 w-4" />
            </span>
            Aerogreen
          </a>
          <p className="mt-4 max-w-xs text-sm text-muted-foreground">
            Khơi nguồn từ đổi mới. Đoàn kết bởi tầm nhìn. Sản phẩm của XTeam.
          </p>
          <div className="mt-4">
            <button
              onClick={onOpenOrderModal}
              className="rounded-full bg-primary px-5 py-2 text-xs font-medium text-primary-foreground shadow-glow transition hover:bg-primary/90"
            >
              Chọn thiết bị & refill
            </button>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-6 text-sm">
          <div>
            <h4 className="font-display text-sm font-semibold text-foreground">Sản phẩm</h4>
            <ul className="mt-3 space-y-2 text-muted-foreground">
              <li>
                <a href="#product" className="transition hover:text-foreground">
                  Thiết bị & refill
                </a>
              </li>
              <li>
                <a href="#solutions" className="transition hover:text-foreground">
                  Tính năng
                </a>
              </li>
            </ul>
          </div>
          <div>
            <h4 className="font-display text-sm font-semibold text-foreground">Công ty</h4>
            <ul className="mt-3 space-y-2 text-muted-foreground">
              <li>
                <a href="#team" className="transition hover:text-foreground">
                  Đội ngũ
                </a>
              </li>
              <li>
                <a href="#contact" className="transition hover:text-foreground">
                  Liên hệ
                </a>
              </li>
              <li className="pt-2">
                <button
                  onClick={onOpenAdminModal}
                  className="inline-flex items-center gap-1.5 text-xs text-primary font-medium hover:underline"
                >
                  <ShieldCheck className="h-3.5 w-3.5" />
                  Bảng Quản Trị XTeam
                </button>
              </li>
            </ul>
          </div>
        </div>

        <div className="lg:text-right">
          <h4 className="font-display text-sm font-semibold text-foreground">Theo dõi XTeam</h4>
          <div className="mt-4 flex gap-3 lg:justify-end">
            {socialLinks.map((item) => {
              const Icon = item.icon;
              return (
                <a
                  key={item.label}
                  href={item.href}
                  aria-label={item.label}
                  className="grid h-10 w-10 place-items-center rounded-full border border-border bg-card text-muted-foreground transition hover:bg-primary hover:text-primary-foreground"
                >
                  <Icon className="h-4 w-4" />
                </a>
              );
            })}
          </div>
        </div>
      </div>

      <div className="border-t border-border">
        <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-3 px-6 py-6 text-xs text-muted-foreground sm:flex-row lg:px-10">
          <p>© 2026 XTeam. Bảo lưu mọi quyền.</p>
          <p>Được tạo ra với tâm huyết cho những thành phố xanh hơn.</p>
        </div>
      </div>
    </footer>
  );
};

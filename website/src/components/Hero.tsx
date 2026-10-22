import React from 'react';
import { ArrowDown, Leaf } from 'lucide-react';

export const Hero: React.FC<{ onOpenOrderModal: () => void }> = ({ onOpenOrderModal }) => {
  return (
    <section id="top" className="relative overflow-hidden pt-28 pb-20 md:pt-36 md:pb-28">
      {/* Background ambient blobs */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -top-32 -left-32 h-[28rem] w-[28rem] rounded-full bg-primary-soft blur-3xl opacity-60"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -bottom-40 right-[-10%] h-[32rem] w-[32rem] rounded-full bg-accent blur-3xl opacity-50"
      />

      <div className="relative mx-auto grid max-w-7xl gap-12 px-6 lg:grid-cols-12 lg:gap-10 lg:px-10">
        <div className="flex flex-col justify-center lg:col-span-6">
          <span className="inline-flex w-fit items-center gap-2 rounded-full border border-border bg-card/60 px-3 py-1 text-xs font-medium text-muted-foreground backdrop-blur">
            <span className="h-1.5 w-1.5 rounded-full bg-primary" />
            XTeam · Công Nghệ Xanh, Tái Hiện Tưởng Tượng
          </span>

          <h1 className="mt-6 font-display text-5xl font-semibold leading-[1.05] tracking-tight text-foreground sm:text-6xl lg:text-7xl">
            Aerogreen:
            <br />
            <span className="text-primary">Trồng Rau Đô Thị</span> Nhàn Tênh.
          </h1>

          <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted-foreground">
            Khơi nguồn từ đổi mới. Đoàn kết bởi tầm nhìn. Một khu vườn khí canh tự chăm sóc,
            biến mọi góc nhỏ trong căn hộ thành vụ mùa xanh tươi.
          </p>

          <div className="mt-10 flex flex-wrap items-center gap-4">
            <button
              onClick={onOpenOrderModal}
              className="group inline-flex items-center gap-2 rounded-full bg-primary px-7 py-3.5 text-sm font-medium text-primary-foreground shadow-glow transition hover:-translate-y-0.5 hover:bg-primary/90"
            >
              Chọn mua ngay
              <ArrowDown className="h-4 w-4 transition group-hover:translate-y-0.5" />
            </button>
            <a
              href="#team"
              className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-6 py-3.5 text-sm font-medium text-foreground transition hover:bg-secondary"
            >
              Gặp gỡ đội ngũ
            </a>
          </div>

          <dl className="mt-14 grid max-w-sm grid-cols-2 gap-6 border-t border-border pt-8">
            <div>
              <dt className="font-display text-2xl font-semibold text-foreground">95%</dt>
              <dd className="mt-1 text-xs text-muted-foreground">Tiết kiệm nước</dd>
            </div>
            <div>
              <dt className="font-display text-2xl font-semibold text-foreground">24/7</dt>
              <dd className="mt-1 text-xs text-muted-foreground">Tự động chăm sóc</dd>
            </div>
          </dl>
        </div>

        <div className="relative lg:col-span-6">
          <div className="relative overflow-hidden rounded-3xl shadow-glow ring-1 ring-black/5">
            <img
              src="/assets/hero-planter.jpg"
              alt="Hệ thống Aerogreen thông minh trên ban công căn hộ đầy nắng"
              width={1920}
              height={1080}
              className="aspect-[4/5] h-full w-full object-cover"
            />
            {/* Product introduction */}
            <div className="absolute bottom-5 left-5 right-5 flex items-center gap-3 rounded-2xl bg-card/90 p-4 shadow-soft backdrop-blur">
              <span className="grid h-10 w-10 shrink-0 place-items-center rounded-full bg-primary-soft text-primary">
                <Leaf className="h-5 w-5" />
              </span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-foreground">
                  Thiết bị Aerogreen & gói refill
                </p>
                <p className="text-xs text-muted-foreground">
                  Cây con và dinh dưỡng cho những mùa rau mới
                </p>
              </div>
              <span className="ml-auto inline-flex items-center gap-1.5 rounded-full bg-primary/10 px-2.5 py-1 text-xs font-medium text-primary">
                <span className="h-1.5 w-1.5 rounded-full bg-primary animate-pulse" />
                Aerogreen
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

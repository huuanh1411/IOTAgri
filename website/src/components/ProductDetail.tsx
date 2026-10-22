import React from 'react';
import { Cpu, Sprout, Smartphone } from 'lucide-react';

const features = [
  {
    icon: Cpu,
    title: 'Tích hợp IoT thông minh',
    desc: 'Tưới nước và cung cấp dung dịch dinh dưỡng tự động, được hiệu chỉnh liên tục bởi cảm biến tích hợp.',
  },
  {
    icon: Sprout,
    title: 'Thiết kế tiết kiệm không gian',
    desc: 'Kiến trúc khí canh theo chiều dọc, phù hợp cho căn hộ, ban công và nhà bếp nhỏ trong đô thị.',
  },
  {
    icon: Smartphone,
    title: 'Điều khiển qua ứng dụng',
    desc: 'Theo dõi sự phát triển, ánh sáng và độ ẩm trong thời gian thực — khu vườn của bạn trong lòng bàn tay.',
  },
];

export const ProductDetail: React.FC = () => {
  return (
    <section id="solutions" className="scroll-mt-24 py-24 md:py-32">
      <div className="mx-auto grid max-w-7xl items-center gap-14 px-6 lg:grid-cols-2 lg:gap-20 lg:px-10">
        <div className="relative order-last lg:order-first">
          <div className="overflow-hidden rounded-3xl shadow-soft ring-1 ring-black/5">
            <img
              src="/assets/product-detail.jpg"
              alt="Cận cảnh hệ thống Aerogreen thông minh"
              width={1024}
              height={1024}
              loading="lazy"
              className="aspect-square w-full object-cover"
            />
          </div>
          <div
            aria-hidden="true"
            className="absolute -bottom-6 -left-6 -z-10 hidden h-32 w-32 rounded-3xl bg-primary-soft md:block"
          />
        </div>

        <div>
          <span className="text-xs font-semibold uppercase tracking-[0.2em] text-primary">
            Về Aerogreen
          </span>
          <h2 className="mt-4 font-display text-4xl font-semibold leading-tight tracking-tight sm:text-5xl">
            Một khu vườn tự lớn —
            <br />
            để bạn không phải lo lắng.
          </h2>
          <p className="mt-5 max-w-xl text-base leading-relaxed text-muted-foreground">
            Aerogreen kết hợp công nghệ khí canh chính xác với bộ não IoT êm ái. Hệ thống tự động cảm biến,
            tưới nước và cung cấp dinh dưỡng cho cây trồng, trong khi ứng dụng nhẹ nhàng giúp bạn nắm bắt mọi thứ.
            Thiết kế cho căn hộ. Xây dựng cho cuộc sống.
          </p>

          <ul className="mt-10 space-y-6">
            {features.map((item) => {
              const Icon = item.icon;
              return (
                <li
                  key={item.title}
                  className="flex gap-5 rounded-2xl border border-border bg-card p-5 shadow-soft"
                >
                  <span className="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-primary-soft text-primary">
                    <Icon className="h-5 w-5" strokeWidth={2} />
                  </span>
                  <div className="min-w-0">
                    <h3 className="font-display text-lg font-semibold text-foreground">
                      {item.title}
                    </h3>
                    <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
                      {item.desc}
                    </p>
                  </div>
                </li>
              );
            })}
          </ul>
        </div>
      </div>
    </section>
  );
};

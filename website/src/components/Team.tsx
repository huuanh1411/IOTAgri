import React from 'react';

interface TeamMember {
  name: string;
  role: string;
}

const teamMembers: TeamMember[] = [
  { name: 'Vũ Duy Nguyên', role: 'Trưởng Dự Án & Kỹ Sư Phần Cứng' },
  { name: 'Dương Hữu Anh', role: 'Phát Triển Sản Phẩm & Kỹ Sư IoT' },
  { name: 'Huỳnh Hữu Lương Nhật Khánh', role: 'Phát Triển Sản Phẩm & QA' },
  { name: 'Hồ Thành Đạt', role: 'Phát Triển Sản Phẩm & Xây Dựng Mẫu' },
  { name: 'Phan Nguyễn Anh Thy', role: 'Chuyên Gia Digital Marketing' },
  { name: 'Phạm Bảo Toàn', role: 'Kinh Doanh Quốc Tế & Tài Chính' },
];

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((word) => word[0])
    .filter(Boolean)
    .slice(-2)
    .join('');
}

export const Team: React.FC = () => {
  return (
    <section id="team" className="scroll-mt-24 border-t border-border bg-secondary/30 py-24 md:py-32">
      <div className="mx-auto max-w-7xl px-6 lg:px-10">
        <div className="mx-auto max-w-2xl text-center">
          <span className="text-xs font-semibold uppercase tracking-[0.2em] text-primary">
            Gặp gỡ XTeam
          </span>
          <h2 className="mt-4 font-display text-4xl font-semibold tracking-tight sm:text-5xl">
            Những bộ óc đằng sau Aerogreen
          </h2>
          <p className="mt-5 text-base text-muted-foreground">
            Kỹ sư, người xây dựng và người kể chuyện — đoàn kết bởi một tầm nhìn: đưa thiên nhiên trở lại cuộc sống hiện đại.
          </p>
        </div>

        <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {teamMembers.map((member, index) => (
            <article
              key={member.name}
              className="group relative overflow-hidden rounded-3xl border border-border bg-card p-7 shadow-soft transition hover:-translate-y-1 hover:shadow-glow"
            >
              <div className="flex items-center gap-4">
                <div
                  aria-hidden="true"
                  className="grid h-16 w-16 shrink-0 place-items-center rounded-full font-display text-lg font-semibold text-primary-foreground"
                  style={{
                    background:
                      index % 2 === 0
                        ? 'linear-gradient(135deg, var(--primary), oklch(0.65 0.09 145))'
                        : 'linear-gradient(135deg, var(--earth), oklch(0.6 0.06 90))',
                  }}
                >
                  {getInitials(member.name)}
                </div>
                <div className="min-w-0">
                  <h3 className="font-display text-lg font-semibold leading-tight text-foreground">
                    {member.name}
                  </h3>
                  <p className="mt-1 text-sm text-muted-foreground">{member.role}</p>
                </div>
              </div>
              <div
                aria-hidden="true"
                className="pointer-events-none absolute -right-10 -bottom-10 h-32 w-32 rounded-full bg-primary-soft opacity-0 blur-2xl transition group-hover:opacity-70"
              />
            </article>
          ))}
        </div>
      </div>
    </section>
  );
};

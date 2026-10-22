import { ReactNode, useEffect, useRef } from 'react';
import { X } from 'lucide-react';
export function StoreDialog({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  const dialog = useRef<HTMLDialogElement>(null);
  useEffect(() => { dialog.current?.showModal(); }, []);
  return <dialog ref={dialog} onCancel={onClose} aria-label={title} className="w-[calc(100%_-_2rem)] max-w-2xl max-h-[90vh] overflow-y-auto rounded-3xl border border-border bg-card p-6 text-foreground shadow-2xl backdrop:bg-black/50">
    <div className="mb-5 flex items-center justify-between gap-4"><h2 className="font-display text-2xl font-semibold">{title}</h2><button aria-label="Đóng" onClick={onClose} className="rounded-full p-2 hover:bg-secondary"><X /></button></div>{children}
  </dialog>;
}

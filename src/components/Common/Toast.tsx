"use client";

import { useEffect } from "react";

interface ToastProps {
  message: string;
  type?: "success" | "error" | "info" | "warning";
  onClose: () => void;
  duration?: number;
}

const ICONS = {
  success: "✓",
  error: "✕",
  warning: "⚠",
  info: "ℹ",
};

const STYLES = {
  success: "bg-emerald-50 text-emerald-800 border-emerald-200",
  error:   "bg-red-50 text-red-800 border-red-200",
  warning: "bg-amber-50 text-amber-800 border-amber-200",
  info:    "bg-blue-50 text-blue-800 border-blue-200",
};

export default function Toast({
  message,
  type = "info",
  onClose,
  duration = 3000,
}: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(onClose, duration);
    return () => clearTimeout(timer);
  }, [onClose, duration]);

  return (
    <div
      role="alert"
      className={`fixed bottom-5 right-5 z-50 flex items-start gap-3
        px-4 py-3 rounded-lg border shadow-lg max-w-sm fade-in
        ${STYLES[type]}`}
    >
      <span className="font-bold text-sm shrink-0 mt-0.5">{ICONS[type]}</span>
      <p className="text-sm flex-1 leading-snug">{message}</p>
      <button
        onClick={onClose}
        aria-label="닫기"
        className="opacity-50 hover:opacity-100 transition-opacity text-sm shrink-0"
      >
        ✕
      </button>
    </div>
  );
}

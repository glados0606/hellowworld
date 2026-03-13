"use client";

import { useState, useRef, useEffect } from "react";
import type { SoapSectionType } from "@/lib/types";
import { SOAP_META } from "@/lib/types";

interface SoapSectionProps {
  type: SoapSectionType;
  items: string[];
  onUpdate: (type: SoapSectionType, items: string[]) => void;
}

export default function SoapSection({ type, items, onUpdate }: SoapSectionProps) {
  const [editingIndex, setEditingIndex] = useState<number | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const meta = SOAP_META[type];

  // 빈 섹션 — 흐리게만 표시 (숨기지 않음)
  const isEmpty = items.length === 0;

  useEffect(() => {
    if (editingIndex !== null) {
      inputRef.current?.focus();
      inputRef.current?.select();
    }
  }, [editingIndex]);

  const handleEdit = (index: number, newValue: string) => {
    const updated = [...items];
    updated[index] = newValue;
    onUpdate(type, updated);
  };

  const handleDeleteItem = (index: number) => {
    const updated = items.filter((_, i) => i !== index);
    onUpdate(type, updated);
    setEditingIndex(null);
  };

  const handleKeyDown = (
    e: React.KeyboardEvent<HTMLInputElement>,
    index: number
  ) => {
    if (e.key === "Enter" || e.key === "Escape") {
      setEditingIndex(null);
    }
    if (e.key === "Delete" && e.metaKey) {
      handleDeleteItem(index);
    }
  };

  return (
    <div
      className={`${meta.colorClass} rounded-lg p-4 fade-in transition-opacity ${
        isEmpty ? "opacity-40" : ""
      }`}
    >
      {/* 섹션 헤더 */}
      <div className="flex items-center gap-2 mb-3">
        <span
          className={`${meta.badgeClass} text-xs font-bold
            w-6 h-6 rounded flex items-center justify-center shrink-0`}
          aria-label={meta.label}
        >
          {meta.shortLabel}
        </span>
        <div className="flex-1 min-w-0">
          <span className={`text-sm font-semibold ${meta.textColorClass}`}>
            {meta.label}
          </span>
          <span className="text-xs text-gray-500 ml-2 hidden sm:inline">
            {meta.description}
          </span>
        </div>
        <span className="text-xs text-gray-400 shrink-0">
          {isEmpty ? "없음" : `${items.length}항목`}
        </span>
      </div>

      {/* Unclassified 경고 */}
      {type === "unclassified" && !isEmpty && (
        <p className="text-xs text-gray-500 mb-2 flex items-center gap-1">
          <span>⚠</span>
          분류되지 않은 항목입니다. 해당 섹션으로 직접 이동해주세요.
        </p>
      )}

      {/* 항목 없음 */}
      {isEmpty && (
        <p className="text-xs text-gray-400 italic px-2">해당 내용 없음</p>
      )}

      {/* 항목 리스트 */}
      {!isEmpty && (
        <ul className="space-y-1">
          {items.map((item, index) => (
            <li key={index} className="group">
              {editingIndex === index ? (
                <div className="flex items-center gap-1">
                  <input
                    ref={inputRef}
                    type="text"
                    value={item}
                    onChange={(e) => handleEdit(index, e.target.value)}
                    onBlur={() => setEditingIndex(null)}
                    onKeyDown={(e) => handleKeyDown(e, index)}
                    className="flex-1 px-2 py-1 text-sm bg-white border border-violet-300
                               rounded focus:outline-none focus:ring-1 focus:ring-violet-400"
                    aria-label={`${meta.label} 항목 ${index + 1} 편집`}
                  />
                  <button
                    onMouseDown={() => handleDeleteItem(index)}
                    className="text-xs text-red-400 hover:text-red-600 px-1 py-1 rounded
                               hover:bg-red-50 shrink-0 transition-colors"
                    title="항목 삭제"
                    aria-label="항목 삭제"
                  >
                    ✕
                  </button>
                </div>
              ) : (
                <div
                  className="flex items-start gap-2 px-2 py-1.5 rounded
                             hover:bg-white/60 cursor-pointer transition-colors group"
                  onClick={() => setEditingIndex(index)}
                  role="button"
                  tabIndex={0}
                  onKeyDown={(e) => e.key === "Enter" && setEditingIndex(index)}
                  aria-label={`항목 편집: ${item}`}
                >
                  <span className="text-gray-400 text-xs mt-0.5 select-none shrink-0">
                    •
                  </span>
                  <span className="text-sm text-gray-700 flex-1 leading-snug">
                    {item}
                  </span>
                  <span className="text-xs text-gray-400 opacity-0 group-hover:opacity-100
                                   transition-opacity shrink-0">
                    편집
                  </span>
                </div>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

"use client";

import { useState } from "react";
import { sampleNotes, type SampleNote } from "@/data/samples";

interface SampleSelectorProps {
  onSelect: (text: string) => void;
  disabled?: boolean;
}

const DEPT_COLORS: Record<string, string> = {
  내과:       "bg-blue-100 text-blue-700",
  "정형외과·내과": "bg-orange-100 text-orange-700",
  소아청소년과: "bg-green-100 text-green-700",
  응급의학과:  "bg-red-100 text-red-700",
};

export default function SampleSelector({ onSelect, disabled }: SampleSelectorProps) {
  const [selected, setSelected] = useState<string | null>(null);

  const handleSelect = (sample: SampleNote) => {
    setSelected(sample.id);
    onSelect(sample.text);
  };

  return (
    <div className="space-y-1.5">
      <p className="text-xs text-gray-500 font-medium">샘플 진료 기록 불러오기</p>
      <div className="flex flex-wrap gap-2">
        {sampleNotes.map((sample) => {
          const isSelected = selected === sample.id;
          const deptStyle = DEPT_COLORS[sample.department] ?? "bg-gray-100 text-gray-600";
          return (
            <button
              key={sample.id}
              onClick={() => handleSelect(sample)}
              disabled={disabled}
              title={sample.description}
              aria-label={`샘플: ${sample.title} (${sample.department})`}
              aria-pressed={isSelected}
              className={`
                group flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs
                border transition-all duration-150
                disabled:opacity-50 disabled:cursor-not-allowed
                ${
                  isSelected
                    ? "border-violet-400 bg-violet-50 text-violet-700 shadow-sm"
                    : "border-gray-200 text-gray-600 bg-white hover:border-violet-300 hover:text-violet-600 hover:bg-violet-50"
                }
              `}
            >
              {/* 진료과 배지 */}
              <span className={`px-1.5 py-0.5 rounded text-xs font-medium ${deptStyle}`}>
                {sample.department}
              </span>
              {/* 제목 */}
              <span className="font-medium">{sample.title}</span>
              {/* 선택됨 표시 */}
              {isSelected && (
                <span className="text-violet-400 text-xs" aria-hidden="true">✓</span>
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}

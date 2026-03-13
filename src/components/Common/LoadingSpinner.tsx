"use client";

/** SOAP 섹션 색상 그대로 스켈레톤으로 표시 — 결과 위치 예고 효과 */
const SECTION_SKELETONS = [
  { cls: "soap-section-s", label: "Subjective", lines: [100, 80, 65] },
  { cls: "soap-section-o", label: "Objective",  lines: [100, 70] },
  { cls: "soap-section-a", label: "Assessment", lines: [60] },
  { cls: "soap-section-p", label: "Plan",        lines: [100, 85, 55] },
];

export default function LoadingSkeleton() {
  return (
    <div className="space-y-4 fade-in" role="status" aria-label="AI 분석 중">
      {/* 상태 메시지 */}
      <div className="flex items-center gap-2 text-sm text-violet-600">
        <svg
          className="animate-spin h-4 w-4 shrink-0"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle
            className="opacity-25"
            cx="12" cy="12" r="10"
            stroke="currentColor" strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
        <span>AI가 진료 기록을 분석하고 있습니다...</span>
      </div>

      {/* 각 SOAP 섹션 스켈레톤 */}
      {SECTION_SKELETONS.map(({ cls, label, lines }) => (
        <div key={label} className={`${cls} rounded-lg p-4`}>
          {/* 헤더 스켈레톤 */}
          <div className="flex items-center gap-2 mb-3">
            <div className="skeleton w-6 h-6 rounded" />
            <div className="skeleton h-4 w-24" />
          </div>
          {/* 항목 스켈레톤 */}
          <div className="space-y-2">
            {lines.map((w, i) => (
              <div key={i} className={`skeleton h-3.5`} style={{ width: `${w}%` }} />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

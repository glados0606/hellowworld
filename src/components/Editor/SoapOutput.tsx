"use client";

import type { SoapResult, SoapSectionType } from "@/lib/types";
import { SOAP_ORDER } from "@/lib/types";
import SoapSection from "./SoapSection";
import LoadingSkeleton from "../Common/LoadingSpinner";

interface SoapOutputProps {
  result: SoapResult | null;
  loading: boolean;
  error: string | null;
  processingTime: number | null;
  onUpdate: (type: SoapSectionType, items: string[]) => void;
  onCopy: () => void;
  onRetry?: () => void;
}

function totalItems(r: SoapResult) {
  return (
    r.subjective.length +
    r.objective.length +
    r.assessment.length +
    r.plan.length +
    r.unclassified.length
  );
}

export default function SoapOutput({
  result,
  loading,
  error,
  processingTime,
  onUpdate,
  onCopy,
  onRetry,
}: SoapOutputProps) {
  // ── 로딩 상태 ──────────────────────────────────────────────────
  if (loading) {
    return <LoadingSkeleton />;
  }

  // ── 에러 상태 ──────────────────────────────────────────────────
  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center fade-in">
        <div className="w-14 h-14 bg-red-50 rounded-2xl flex items-center justify-center mb-4">
          <span className="text-2xl" aria-hidden="true">⚠️</span>
        </div>
        <h3 className="text-sm font-semibold text-red-700 mb-1">구조화 실패</h3>
        <p className="text-xs text-gray-500 max-w-xs mb-4 leading-relaxed">{error}</p>
        {onRetry && (
          <button
            onClick={onRetry}
            className="text-xs text-violet-600 hover:text-violet-800 font-medium
                       px-3 py-1.5 rounded border border-violet-200 hover:border-violet-400
                       hover:bg-violet-50 transition-all"
          >
            다시 시도
          </button>
        )}
        <p className="text-xs text-gray-400 mt-3">
          원본 텍스트는 그대로 보존되어 있습니다.
        </p>
      </div>
    );
  }

  // ── 초기(결과 없음) 상태 ───────────────────────────────────────
  if (!result) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-center">
        <div className="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center mb-4">
          <span className="text-3xl" aria-hidden="true">📋</span>
        </div>
        <h3 className="text-sm font-semibold text-gray-600 mb-2">
          SOAP 구조화 결과가 여기에 표시됩니다
        </h3>
        <p className="text-xs text-gray-400 max-w-xs leading-relaxed">
          왼쪽에 진료 기록을 입력한 후<br />
          <strong className="text-violet-600">구조화</strong> 버튼을 클릭하세요
        </p>
        {/* SOAP 섹션 컬러 힌트 */}
        <div className="flex gap-2 mt-6 flex-wrap justify-center">
          {[
            { label: "S", color: "bg-purple-500", desc: "Subjective" },
            { label: "O", color: "bg-blue-500",   desc: "Objective" },
            { label: "A", color: "bg-amber-500",  desc: "Assessment" },
            { label: "P", color: "bg-emerald-500",desc: "Plan" },
          ].map(({ label, color, desc }) => (
            <div key={label} className="flex items-center gap-1.5 text-xs text-gray-500">
              <span className={`${color} text-white w-5 h-5 rounded text-xs font-bold flex items-center justify-center`}>
                {label}
              </span>
              {desc}
            </div>
          ))}
        </div>
      </div>
    );
  }

  // ── 결과 상태 ──────────────────────────────────────────────────
  const total = totalItems(result);
  const hasUnclassified = result.unclassified.length > 0;

  return (
    <div className="space-y-3 fade-in">
      {/* 결과 헤더 */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-sm font-semibold text-gray-700">구조화 결과</span>
          {processingTime !== null && (
            <span className="text-xs text-gray-400 tabular-nums">
              {(processingTime / 1000).toFixed(1)}초 · {total}항목
            </span>
          )}
          {hasUnclassified && (
            <span className="text-xs text-amber-600 bg-amber-50 border border-amber-200
                             px-2 py-0.5 rounded-full">
              ⚠ 미분류 {result.unclassified.length}건
            </span>
          )}
        </div>
        <button
          onClick={onCopy}
          title="결과 복사"
          className="text-xs text-violet-600 hover:text-violet-800 font-medium
                     px-2.5 py-1 rounded-md hover:bg-violet-50 border border-transparent
                     hover:border-violet-200 transition-all"
        >
          복사
        </button>
      </div>

      {/* SOAP 섹션 렌더링 */}
      {SOAP_ORDER.map((sectionType) => (
        <SoapSection
          key={sectionType}
          type={sectionType}
          items={result[sectionType]}
          onUpdate={onUpdate}
        />
      ))}

      {/* 편집 안내 */}
      <p className="text-xs text-gray-400 text-center pt-1">
        항목을 클릭하면 직접 수정할 수 있습니다
      </p>
    </div>
  );
}

#!/bin/bash
#===============================================================================
# Phase 3: 핵심 기능 구현 (AI 구조화 엔진)
# 목표 점수: 완성도 12점 중 10점
#===============================================================================

PROJECT_DIR=${1:-"$(pwd)/snapsoap"}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Phase 3: 핵심 기능 구현 ━━━${NC}"
cd "$PROJECT_DIR"

# API Route — /api/structurize
cat > src/app/api/structurize/route.ts << 'APIROUTE'
import { NextRequest, NextResponse } from "next/server";
import { structurizeToSoap } from "@/lib/claude";
import { StructurizeResponse } from "@/lib/types";

export async function POST(request: NextRequest) {
  const startTime = Date.now();

  try {
    const body = await request.json();
    const { text } = body;

    // 입력 유효성 검사
    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "진료 기록 텍스트를 입력해주세요." },
        { status: 400 }
      );
    }

    if (text.length > 10000) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "텍스트가 너무 깁니다. 10,000자 이내로 입력해주세요." },
        { status: 400 }
      );
    }

    // API 키 확인
    if (!process.env.ANTHROPIC_API_KEY) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "API 설정 오류. 관리자에게 문의하세요." },
        { status: 500 }
      );
    }

    // AI 구조화 실행
    const result = await structurizeToSoap(text);
    const processingTime = Date.now() - startTime;

    return NextResponse.json<StructurizeResponse>({
      success: true,
      data: result,
      processingTime,
    });
  } catch (error) {
    console.error("[SnapSOAP] API Error:", error);

    const processingTime = Date.now() - startTime;
    const errorMessage =
      error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.";

    return NextResponse.json<StructurizeResponse>(
      {
        success: false,
        error: `구조화 처리 중 오류가 발생했습니다: ${errorMessage}`,
        processingTime,
      },
      { status: 500 }
    );
  }
}
APIROUTE

echo -e "${GREEN}✓ API Route 생성 완료 (src/app/api/structurize/route.ts)${NC}"

# 루트 레이아웃
cat > src/app/layout.tsx << 'LAYOUT'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "SnapSOAP — AI 임상노트 구조화 에디터",
  description: "자유텍스트 진료 기록을 SOAP 포맷으로 자동 구조화",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body className="min-h-screen bg-gray-50">
        {/* 헤더 */}
        <header className="bg-white border-b border-gray-200 sticky top-0 z-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-14">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-violet-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-sm">S</span>
                </div>
                <div>
                  <h1 className="text-lg font-bold text-gray-900 leading-tight">
                    SnapSOAP
                  </h1>
                  <p className="text-xs text-gray-500 -mt-0.5">
                    AI Clinical Note Structurizer
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 text-xs text-gray-400">
                <span className="px-2 py-1 bg-violet-50 text-violet-600 rounded-md font-medium">
                  Prototype v0.1
                </span>
              </div>
            </div>
          </div>
        </header>

        {/* 메인 */}
        <main>{children}</main>
      </body>
    </html>
  );
}
LAYOUT

echo -e "${GREEN}✓ 루트 레이아웃 생성 완료${NC}"

# 공통 컴포넌트 — Button
cat > src/components/Common/Button.tsx << 'BUTTON'
"use client";

interface ButtonProps {
  onClick: () => void;
  disabled?: boolean;
  loading?: boolean;
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
  className?: string;
}

export default function Button({
  onClick,
  disabled = false,
  loading = false,
  variant = "primary",
  size = "md",
  children,
  className = "",
}: ButtonProps) {
  const baseStyle =
    "inline-flex items-center justify-center font-medium rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2";

  const variants = {
    primary:
      "bg-violet-600 text-white hover:bg-violet-700 focus:ring-violet-500 disabled:bg-violet-300",
    secondary:
      "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-violet-500 disabled:bg-gray-100",
    ghost:
      "text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:ring-gray-500",
  };

  const sizes = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-sm",
    lg: "px-6 py-3 text-base",
  };

  return (
    <button
      onClick={onClick}
      disabled={disabled || loading}
      className={`${baseStyle} ${variants[variant]} ${sizes[size]} ${className}`}
    >
      {loading && (
        <svg
          className="animate-spin -ml-1 mr-2 h-4 w-4"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      )}
      {children}
    </button>
  );
}
BUTTON

# 공통 컴포넌트 — Toast
cat > src/components/Common/Toast.tsx << 'TOAST'
"use client";

import { useEffect } from "react";

interface ToastProps {
  message: string;
  type?: "success" | "error" | "info";
  onClose: () => void;
  duration?: number;
}

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

  const colors = {
    success: "bg-green-50 text-green-800 border-green-200",
    error: "bg-red-50 text-red-800 border-red-200",
    info: "bg-blue-50 text-blue-800 border-blue-200",
  };

  return (
    <div
      className={`fixed bottom-4 right-4 z-50 px-4 py-3 rounded-lg border shadow-lg
      fade-in ${colors[type]} max-w-sm`}
    >
      <div className="flex items-center justify-between gap-3">
        <p className="text-sm">{message}</p>
        <button
          onClick={onClose}
          className="text-current opacity-60 hover:opacity-100"
        >
          ✕
        </button>
      </div>
    </div>
  );
}
TOAST

# 공통 컴포넌트 — LoadingSpinner (스켈레톤)
cat > src/components/Common/LoadingSpinner.tsx << 'SKELETON'
"use client";

export default function LoadingSkeleton() {
  return (
    <div className="space-y-4 fade-in">
      <p className="text-sm text-gray-500 flex items-center gap-2">
        <svg className="animate-spin h-4 w-4 text-violet-600" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
        </svg>
        AI가 진료 기록을 분석하고 있습니다...
      </p>
      {["soap-section-s", "soap-section-o", "soap-section-a", "soap-section-p"].map(
        (cls, i) => (
          <div key={i} className={`${cls} rounded-lg p-4`}>
            <div className="skeleton h-4 w-24 mb-3" />
            <div className="space-y-2">
              <div className="skeleton h-3 w-full" />
              <div className="skeleton h-3 w-4/5" />
              <div className="skeleton h-3 w-3/5" />
            </div>
          </div>
        )
      )}
    </div>
  );
}
SKELETON

echo -e "${GREEN}✓ 공통 컴포넌트 생성 완료 (Button, Toast, LoadingSkeleton)${NC}"

# 에디터 컴포넌트 — TextInput (좌측 패널)
cat > src/components/Editor/TextInput.tsx << 'TEXTINPUT'
"use client";

interface TextInputProps {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
}

export default function TextInput({ value, onChange, disabled }: TextInputProps) {
  const charCount = value.length;
  const maxChars = 10000;

  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center justify-between mb-2">
        <label className="text-sm font-medium text-gray-700">
          자유텍스트 진료 기록
        </label>
        <span
          className={`text-xs ${
            charCount > maxChars * 0.9
              ? "text-red-500"
              : "text-gray-400"
          }`}
        >
          {charCount.toLocaleString()} / {maxChars.toLocaleString()}자
        </span>
      </div>

      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        placeholder={`진료 기록을 자유롭게 입력하세요...

예시:
55세 남성 환자. HTN, DM type 2로 f/u 중.
오늘 특별한 불편감 없이 정기 방문함.
BP 138/88 mmHg, HR 76 bpm...`}
        className="editor-textarea flex-1 w-full p-4 border border-gray-200 rounded-lg
                   bg-white text-gray-900 text-sm leading-relaxed
                   placeholder:text-gray-400 placeholder:leading-relaxed
                   focus:border-violet-400 transition-colors
                   disabled:bg-gray-50 disabled:text-gray-500"
        style={{ minHeight: "400px" }}
      />
    </div>
  );
}
TEXTINPUT

# 에디터 컴포넌트 — SoapSection (개별 SOAP 섹션)
cat > src/components/Editor/SoapSection.tsx << 'SOAPSECTION'
"use client";

import { useState } from "react";
import { SoapSectionType, SOAP_SECTIONS } from "@/lib/types";

interface SoapSectionProps {
  type: SoapSectionType;
  items: string[];
  onUpdate: (type: SoapSectionType, items: string[]) => void;
}

export default function SoapSection({ type, items, onUpdate }: SoapSectionProps) {
  const [editingIndex, setEditingIndex] = useState<number | null>(null);
  const section = SOAP_SECTIONS[type];

  if (items.length === 0) return null;

  const sectionStyles: Record<SoapSectionType, string> = {
    subjective: "soap-section-s",
    objective: "soap-section-o",
    assessment: "soap-section-a",
    plan: "soap-section-p",
    unclassified: "soap-section-unclassified",
  };

  const badgeColors: Record<SoapSectionType, string> = {
    subjective: "bg-violet-600",
    objective: "bg-blue-600",
    assessment: "bg-amber-500",
    plan: "bg-emerald-600",
    unclassified: "bg-gray-500",
  };

  const handleEdit = (index: number, newValue: string) => {
    const newItems = [...items];
    newItems[index] = newValue;
    onUpdate(type, newItems);
  };

  return (
    <div className={`${sectionStyles[type]} rounded-lg p-4 fade-in`}>
      {/* 섹션 헤더 */}
      <div className="flex items-center gap-2 mb-3">
        <span
          className={`${badgeColors[type]} text-white text-xs font-bold 
                      w-6 h-6 rounded flex items-center justify-center`}
        >
          {section.icon}
        </span>
        <h3 className="text-sm font-semibold text-gray-800">
          {section.label}
        </h3>
        <span className="text-xs text-gray-500">
          {section.description}
        </span>
        <span className="ml-auto text-xs text-gray-400">
          {items.length}항목
        </span>
      </div>

      {/* 항목 리스트 */}
      <ul className="space-y-1.5">
        {items.map((item, index) => (
          <li key={index} className="group">
            {editingIndex === index ? (
              <input
                type="text"
                value={item}
                onChange={(e) => handleEdit(index, e.target.value)}
                onBlur={() => setEditingIndex(null)}
                onKeyDown={(e) => e.key === "Enter" && setEditingIndex(null)}
                className="w-full px-2 py-1 text-sm bg-white border border-violet-300 
                           rounded focus:outline-none focus:ring-1 focus:ring-violet-400"
                autoFocus
              />
            ) : (
              <div
                className="flex items-start gap-2 px-2 py-1 rounded 
                           hover:bg-white/50 cursor-pointer transition-colors"
                onClick={() => setEditingIndex(index)}
              >
                <span className="text-gray-400 text-xs mt-0.5 select-none">•</span>
                <span className="text-sm text-gray-700 flex-1">{item}</span>
                <span className="text-xs text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity">
                  편집
                </span>
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}
SOAPSECTION

# 에디터 컴포넌트 — SoapOutput (우측 패널)
cat > src/components/Editor/SoapOutput.tsx << 'SOAPOUTPUT'
"use client";

import { SoapResult, SoapSectionType } from "@/lib/types";
import SoapSection from "./SoapSection";
import LoadingSkeleton from "../Common/LoadingSpinner";

interface SoapOutputProps {
  result: SoapResult | null;
  loading: boolean;
  processingTime?: number;
  onUpdate: (type: SoapSectionType, items: string[]) => void;
  onCopy: () => void;
}

export default function SoapOutput({
  result,
  loading,
  processingTime,
  onUpdate,
  onCopy,
}: SoapOutputProps) {
  if (loading) {
    return <LoadingSkeleton />;
  }

  if (!result) {
    return (
      <div className="flex flex-col items-center justify-center h-full text-center py-16">
        <div className="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center mb-4">
          <span className="text-2xl">📋</span>
        </div>
        <h3 className="text-sm font-medium text-gray-600 mb-1">
          SOAP 구조화 결과가 여기에 표시됩니다
        </h3>
        <p className="text-xs text-gray-400 max-w-xs">
          왼쪽에 진료 기록을 입력한 후 &quot;구조화&quot; 버튼을 클릭하세요
        </p>
      </div>
    );
  }

  const totalItems =
    result.subjective.length +
    result.objective.length +
    result.assessment.length +
    result.plan.length +
    result.unclassified.length;

  return (
    <div className="space-y-3">
      {/* 결과 헤더 */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-sm font-medium text-gray-700">
            구조화 결과
          </span>
          {processingTime && (
            <span className="text-xs text-gray-400">
              {(processingTime / 1000).toFixed(1)}초 · {totalItems}항목
            </span>
          )}
        </div>
        <button
          onClick={onCopy}
          className="text-xs text-violet-600 hover:text-violet-800 
                     font-medium px-2 py-1 rounded hover:bg-violet-50 transition-colors"
        >
          📋 복사
        </button>
      </div>

      {/* SOAP 섹션들 */}
      <SoapSection type="subjective" items={result.subjective} onUpdate={onUpdate} />
      <SoapSection type="objective" items={result.objective} onUpdate={onUpdate} />
      <SoapSection type="assessment" items={result.assessment} onUpdate={onUpdate} />
      <SoapSection type="plan" items={result.plan} onUpdate={onUpdate} />
      <SoapSection type="unclassified" items={result.unclassified} onUpdate={onUpdate} />

      {/* 편집 안내 */}
      <p className="text-xs text-gray-400 text-center pt-2">
        각 항목을 클릭하면 직접 수정할 수 있습니다
      </p>
    </div>
  );
}
SOAPOUTPUT

echo -e "${GREEN}✓ 에디터 컴포넌트 생성 완료 (TextInput, SoapSection, SoapOutput)${NC}"

# 샘플 선택기
cat > src/components/Demo/SampleSelector.tsx << 'SAMPLESELECTOR'
"use client";

import { sampleNotes, SampleNote } from "@/data/samples";

interface SampleSelectorProps {
  onSelect: (text: string) => void;
  disabled?: boolean;
}

export default function SampleSelector({ onSelect, disabled }: SampleSelectorProps) {
  return (
    <div className="flex items-center gap-2 flex-wrap">
      <span className="text-xs text-gray-500">샘플:</span>
      {sampleNotes.map((sample: SampleNote) => (
        <button
          key={sample.id}
          onClick={() => onSelect(sample.text)}
          disabled={disabled}
          className="text-xs px-2.5 py-1 rounded-full border border-gray-200
                     text-gray-600 hover:border-violet-300 hover:text-violet-600
                     hover:bg-violet-50 transition-all disabled:opacity-50
                     disabled:cursor-not-allowed"
        >
          {sample.department} — {sample.title}
        </button>
      ))}
    </div>
  );
}
SAMPLESELECTOR

echo -e "${GREEN}✓ 샘플 선택기 생성 완료${NC}"

# DEVLOG 업데이트
cat >> docs/DEVLOG.md << 'DEVLOG'

### Phase 3 — 핵심 기능 구현
- **시각**: $(date '+%Y-%m-%d %H:%M')
- **작업**: API Route, 에디터 컴포넌트 (TextInput, SoapSection, SoapOutput), 샘플 선택기
- **구현 완료**:
  - POST /api/structurize — 입력 유효성 검사 + Claude API 호출 + JSON 파싱
  - SoapSection — 클릭 편집 가능한 개별 SOAP 섹션 컴포넌트
  - SoapOutput — 로딩/빈 상태/결과 상태 분기 처리
  - SampleSelector — 3종 샘플 데이터 프리셋
- **기술 메모**:
  - 에러 핸들링: API 키 미설정, 입력 초과, 파싱 실패 각각 분기 처리
  - 편집 UX: 인라인 편집 (클릭→input 전환→blur/enter로 확정)
- **다음 단계**: 메인 페이지 조립 (Split-View) + UI 마무리

---
DEVLOG

# 커밋
git add -A
git commit -m "feat: 핵심 기능 구현 — API Route, SOAP 에디터 컴포넌트, 샘플 선택기"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Phase 3 완료: 핵심 기능 구현${NC}"
echo -e "${YELLOW}📊 누적 예상 점수: 약 63 / 100${NC}"
echo -e "   문서화: ~32/40  |  기술: ~8/10  |  완성도: ~8/20  |  아이디어: ~13/20  |  검증: 0/10"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 확인 포인트:${NC}"
echo "  1. src/app/api/structurize/route.ts — 에러 처리가 빠짐없는지"
echo "  2. src/components/Editor/ — 컴포넌트 분리가 적절한지"
echo "  3. 인라인 편집 UX — 클릭→수정→확정 흐름이 자연스러운지"
echo ""
echo -e "${YELLOW}💡 이 시점에서 테스트:${NC}"
echo "  npm install && npm run dev 실행 후"
echo "  아직 메인 페이지가 없으므로, Phase 4에서 조립합니다."

#!/bin/bash
#===============================================================================
# Phase 4: UI/UX 구현 (Split-View 에디터 + 메인 페이지 조립)
# 목표 점수: 사용자 경험 8점 중 7점
#===============================================================================

PROJECT_DIR=${1:-"$(pwd)/snapsoap"}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Phase 4: UI/UX 구현 ━━━${NC}"
cd "$PROJECT_DIR"

# 메인 페이지 — 모든 컴포넌트 조립
cat > src/app/page.tsx << 'PAGE'
"use client";

import { useState, useCallback } from "react";
import TextInput from "@/components/Editor/TextInput";
import SoapOutput from "@/components/Editor/SoapOutput";
import SampleSelector from "@/components/Demo/SampleSelector";
import Button from "@/components/Common/Button";
import Toast from "@/components/Common/Toast";
import { SoapResult, SoapSectionType, StructurizeResponse } from "@/lib/types";

export default function Home() {
  // 상태 관리
  const [inputText, setInputText] = useState("");
  const [soapResult, setSoapResult] = useState<SoapResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [processingTime, setProcessingTime] = useState<number | undefined>();
  const [toast, setToast] = useState<{
    message: string;
    type: "success" | "error" | "info";
  } | null>(null);

  // AI 구조화 실행
  const handleStructurize = useCallback(async () => {
    if (!inputText.trim()) {
      setToast({ message: "진료 기록을 먼저 입력해주세요.", type: "info" });
      return;
    }

    setLoading(true);
    setSoapResult(null);
    setProcessingTime(undefined);

    try {
      const response = await fetch("/api/structurize", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text: inputText }),
      });

      const data: StructurizeResponse = await response.json();

      if (data.success && data.data) {
        setSoapResult(data.data);
        setProcessingTime(data.processingTime);
        setToast({ message: "구조화 완료!", type: "success" });
      } else {
        setToast({
          message: data.error || "구조화에 실패했습니다.",
          type: "error",
        });
      }
    } catch (error) {
      console.error("Structurize error:", error);
      setToast({
        message: "네트워크 오류가 발생했습니다. 다시 시도해주세요.",
        type: "error",
      });
    } finally {
      setLoading(false);
    }
  }, [inputText]);

  // SOAP 결과 수정
  const handleUpdateSection = useCallback(
    (type: SoapSectionType, items: string[]) => {
      if (!soapResult) return;
      setSoapResult({ ...soapResult, [type]: items });
    },
    [soapResult]
  );

  // 결과 복사
  const handleCopy = useCallback(() => {
    if (!soapResult) return;

    const formatSection = (label: string, items: string[]) => {
      if (items.length === 0) return "";
      return `[${label}]\n${items.map((i) => `- ${i}`).join("\n")}\n`;
    };

    const text = [
      formatSection("Subjective", soapResult.subjective),
      formatSection("Objective", soapResult.objective),
      formatSection("Assessment", soapResult.assessment),
      formatSection("Plan", soapResult.plan),
      formatSection("Unclassified", soapResult.unclassified),
    ]
      .filter(Boolean)
      .join("\n");

    navigator.clipboard.writeText(text).then(() => {
      setToast({ message: "클립보드에 복사되었습니다.", type: "success" });
    });
  }, [soapResult]);

  // 샘플 선택
  const handleSelectSample = useCallback((text: string) => {
    setInputText(text);
    setSoapResult(null);
    setProcessingTime(undefined);
  }, []);

  // 초기화
  const handleClear = useCallback(() => {
    setInputText("");
    setSoapResult(null);
    setProcessingTime(undefined);
  }, []);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      {/* 상단 컨트롤 */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-4">
        <SampleSelector onSelect={handleSelectSample} disabled={loading} />
        <div className="flex items-center gap-2">
          <Button
            onClick={handleClear}
            variant="ghost"
            size="sm"
            disabled={loading || (!inputText && !soapResult)}
          >
            초기화
          </Button>
          <Button
            onClick={handleStructurize}
            variant="primary"
            size="md"
            loading={loading}
            disabled={!inputText.trim()}
          >
            {loading ? "분석 중..." : "✨ 구조화"}
          </Button>
        </div>
      </div>

      {/* Split-View 에디터 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4" style={{ minHeight: "calc(100vh - 200px)" }}>
        {/* 좌측: 입력 패널 */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
          <TextInput
            value={inputText}
            onChange={setInputText}
            disabled={loading}
          />
        </div>

        {/* 우측: SOAP 결과 패널 */}
        <div className="bg-white rounded-xl border border-gray-200 p-4 shadow-sm overflow-y-auto">
          <SoapOutput
            result={soapResult}
            loading={loading}
            processingTime={processingTime}
            onUpdate={handleUpdateSection}
            onCopy={handleCopy}
          />
        </div>
      </div>

      {/* 하단 안내 */}
      <div className="mt-4 text-center">
        <p className="text-xs text-gray-400">
          SnapSOAP는 프로토타입이며, 실제 의료 판단에 사용할 수 없습니다.
          모든 결과는 반드시 의료진이 검토해야 합니다.
        </p>
      </div>

      {/* Toast 알림 */}
      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}
PAGE

echo -e "${GREEN}✓ 메인 페이지 생성 완료 (src/app/page.tsx)${NC}"

# DEVLOG 업데이트
cat >> docs/DEVLOG.md << 'DEVLOG'

### Phase 4 — UI/UX 구현
- **시각**: $(date '+%Y-%m-%d %H:%M')
- **작업**: 메인 페이지 조립, Split-View 레이아웃, 상태 관리 통합
- **UX 결정 사항**:
  - Split-View: 좌측 입력 / 우측 결과 (lg 이상에서 2컬럼, 모바일은 세로 스택)
  - 버튼 트리거 방식 채택 (실시간 분석 대신 — API 비용 절감 + 의도적 동작)
  - 결과 복사: SOAP 섹션별 마크다운 형식으로 포맷팅
  - 초기화 버튼으로 입력+결과 동시 리셋
  - Toast 알림: 성공/실패/안내 3종 분기
- **UX 플로우**: 샘플 선택(or 직접 입력) → 구조화 버튼 → 로딩 → 결과 표시 → 편집/복사
- **다음 단계**: 검증 계획서 작성 + 데모 시나리오 준비

---
DEVLOG

# 커밋
git add -A
git commit -m "feat: 메인 페이지 UI 구현 — Split-View 에디터, 상태 관리, 복사/초기화"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Phase 4 완료: UI/UX 구현${NC}"
echo -e "${YELLOW}📊 누적 예상 점수: 약 78 / 100${NC}"
echo -e "   문서화: ~33/40  |  기술: ~8/10  |  완성도: ~16/20  |  아이디어: ~15/20  |  검증: 0/10"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 확인 포인트 (이 Phase가 가장 중요합니다!):${NC}"
echo "  1. npm run dev로 실행하여 전체 플로우 테스트"
echo "  2. 샘플 데이터 3종 각각 구조화 테스트"
echo "  3. 결과 편집 → 복사 플로우 확인"
echo "  4. 모바일 뷰(좁은 화면)에서 레이아웃 확인"
echo "  5. 에러 상태 테스트 (빈 입력으로 구조화 시도 등)"
echo ""
echo -e "${YELLOW}💡 UX 개선 포인트 (시간이 있다면):${NC}"
echo "  - 키보드 단축키: Ctrl+Enter로 구조화 실행"
echo "  - 다크모드 지원"
echo "  - 구조화 결과 항목 드래그 앤 드롭"

#!/bin/bash
#===============================================================================
# Phase 2: 프로젝트 스캐폴딩 + 기술 스택 셋업
# 목표 점수: 기술 구현력 10점 중 8점
#===============================================================================

PROJECT_DIR=${1:-"$(pwd)/snapsoap"}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━ Phase 2: 프로젝트 스캐폴딩 ━━━${NC}"
cd "$PROJECT_DIR"

# package.json 생성
cat > package.json << 'PACKAGE'
{
  "name": "snapsoap",
  "version": "0.1.0",
  "private": true,
  "description": "AI-powered clinical note structurizer — SOAP format auto-classification",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.39.0",
    "next": "14.2.21",
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.48",
    "@types/react-dom": "^18.2.18",
    "autoprefixer": "^10.4.17",
    "eslint": "^8.56.0",
    "eslint-config-next": "14.2.21",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1",
    "typescript": "^5.3.3"
  }
}
PACKAGE

echo -e "${GREEN}✓ package.json 생성${NC}"

# tsconfig.json
cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
TSCONFIG

# next.config.js
cat > next.config.js << 'NEXTCONFIG'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
};

module.exports = nextConfig;
NEXTCONFIG

# tailwind.config.ts
cat > tailwind.config.ts << 'TAILWIND'
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        soap: {
          s: { light: "#EDE9FE", DEFAULT: "#8B5CF6", dark: "#5B21B6" },
          o: { light: "#DBEAFE", DEFAULT: "#3B82F6", dark: "#1E40AF" },
          a: { light: "#FEF3C7", DEFAULT: "#F59E0B", dark: "#B45309" },
          p: { light: "#D1FAE5", DEFAULT: "#10B981", dark: "#047857" },
          unclassified: { light: "#F3F4F6", DEFAULT: "#6B7280", dark: "#374151" },
        },
      },
      fontFamily: {
        sans: [
          "Pretendard",
          "-apple-system",
          "BlinkMacSystemFont",
          "system-ui",
          "sans-serif",
        ],
        mono: ["JetBrains Mono", "Fira Code", "monospace"],
      },
    },
  },
  plugins: [],
};

export default config;
TAILWIND

# postcss.config.js
cat > postcss.config.js << 'POSTCSS'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
POSTCSS

echo -e "${GREEN}✓ 설정 파일 생성 (tsconfig, tailwind, postcss, next.config)${NC}"

# 디렉토리 구조 생성
mkdir -p src/app/api/structurize
mkdir -p src/components/Editor
mkdir -p src/components/Common
mkdir -p src/components/Demo
mkdir -p src/lib
mkdir -p src/data
mkdir -p public

echo -e "${GREEN}✓ 디렉토리 구조 생성${NC}"

# TypeScript 타입 정의
cat > src/lib/types.ts << 'TYPES'
/** SOAP 섹션 타입 */
export type SoapSectionType = "subjective" | "objective" | "assessment" | "plan" | "unclassified";

/** 개별 SOAP 섹션 */
export interface SoapSection {
  type: SoapSectionType;
  label: string;
  content: string[];
  color: string;
  icon: string;
}

/** AI 구조화 응답 전체 */
export interface SoapResult {
  subjective: string[];
  objective: string[];
  assessment: string[];
  plan: string[];
  unclassified: string[];
}

/** API 요청 */
export interface StructurizeRequest {
  text: string;
}

/** API 응답 */
export interface StructurizeResponse {
  success: boolean;
  data?: SoapResult;
  error?: string;
  processingTime?: number;
}

/** SOAP 섹션 메타데이터 */
export const SOAP_SECTIONS: Record<SoapSectionType, { label: string; color: string; icon: string; description: string }> = {
  subjective: {
    label: "Subjective",
    color: "soap-s",
    icon: "S",
    description: "환자의 주관적 호소, 증상, 병력",
  },
  objective: {
    label: "Objective",
    color: "soap-o",
    icon: "O",
    description: "객관적 검사 소견, 활력징후, 검사 결과",
  },
  assessment: {
    label: "Assessment",
    color: "soap-a",
    icon: "A",
    description: "진단명, 감별진단, 임상 판단",
  },
  plan: {
    label: "Plan",
    color: "soap-p",
    icon: "P",
    description: "치료 계획, 처방, 추적관찰",
  },
  unclassified: {
    label: "Unclassified",
    color: "soap-unclassified",
    icon: "?",
    description: "분류되지 않은 항목",
  },
};
TYPES

echo -e "${GREEN}✓ TypeScript 타입 정의 완료 (src/lib/types.ts)${NC}"

# Claude API 프롬프트 설계
cat > src/lib/prompts.ts << 'PROMPTS'
/**
 * SOAP 구조화 시스템 프롬프트
 * 
 * 설계 원칙:
 * 1. 원문 보존 — 내용을 변경하지 않고 재배열만 수행
 * 2. 의학 약어 인식 — HTN, DM, SOB 등 약어를 올바른 섹션에 배치
 * 3. 모호한 문장 처리 — 가장 관련성 높은 섹션에 배치
 * 4. 안전 장치 — 분류 불가 시 unclassified로 분리
 */

export const SOAP_SYSTEM_PROMPT = `당신은 EMR(전자의무기록) 전문 AI 어시스턴트입니다.
의사가 작성한 자유텍스트 진료 기록을 SOAP 형식으로 구조화하는 것이 당신의 역할입니다.

## SOAP 분류 기준

### Subjective (S) — 주관적 정보
- 환자가 호소하는 증상 (두통, 복통, 기침 등)
- 증상의 시작 시점, 기간, 양상
- 과거 병력, 가족력, 사회력
- 현재 복용 중인 약물 (환자 진술 기반)
- 알레르기 정보
- ROS (Review of Systems) 내용

### Objective (O) — 객관적 정보
- 활력징후 (BP, HR, RR, BT, SpO2)
- 신체검진 소견
- 검사 결과 (혈액검사, 영상검사, 심전도 등)
- 키, 체중, BMI
- 관찰된 외관, 의식 수준

### Assessment (A) — 평가
- 진단명 또는 추정 진단
- 감별진단 목록
- 질환의 상태 평가 (호전/악화/유지)
- 임상적 판단이나 해석

### Plan (P) — 계획
- 처방 (약물, 용량, 기간)
- 추가 검사 오더
- 의뢰/전원 계획
- 생활습관 교육/상담 내용
- 다음 방문 일정
- 수술/시술 계획

### Unclassified — 미분류
- 위 카테고리에 명확히 속하지 않는 내용
- 인사말, 메모, 행정적 내용

## 규칙
1. 입력 텍스트의 각 문장을 분석하여 가장 적합한 SOAP 섹션에 배치하세요.
2. 원문의 내용을 절대 변경하지 마세요. 재배열만 수행합니다.
3. 의학 약어는 그대로 보존하세요 (예: "HTN" → "HTN" 그대로).
4. 한 문장이 여러 섹션에 걸치면, 가장 주된 내용의 섹션에 배치하세요.
5. 확실하지 않은 내용은 unclassified에 넣으세요.
6. 한국어와 영어 혼용 기록을 모두 처리할 수 있어야 합니다.

## 출력 형식
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트를 포함하지 마세요.

{
  "subjective": ["문장1", "문장2"],
  "objective": ["문장1", "문장2"],
  "assessment": ["문장1"],
  "plan": ["문장1", "문장2"],
  "unclassified": []
}`;

export const createUserPrompt = (text: string): string => {
  return `아래 진료 기록을 SOAP 형식으로 구조화해주세요.

---
${text}
---

JSON으로만 응답하세요.`;
};
PROMPTS

echo -e "${GREEN}✓ SOAP 프롬프트 설계 완료 (src/lib/prompts.ts)${NC}"

# Claude API 래퍼
cat > src/lib/claude.ts << 'CLAUDE_LIB'
import Anthropic from "@anthropic-ai/sdk";
import { SOAP_SYSTEM_PROMPT, createUserPrompt } from "./prompts";
import { SoapResult } from "./types";

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

/**
 * 자유텍스트를 SOAP 구조로 변환
 */
export async function structurizeToSoap(text: string): Promise<SoapResult> {
  const startTime = Date.now();

  const message = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2048,
    system: SOAP_SYSTEM_PROMPT,
    messages: [
      {
        role: "user",
        content: createUserPrompt(text),
      },
    ],
  });

  const responseText =
    message.content[0].type === "text" ? message.content[0].text : "";

  // JSON 파싱 (코드 블록 제거 포함)
  const cleaned = responseText
    .replace(/```json\s*/g, "")
    .replace(/```\s*/g, "")
    .trim();

  const parsed: SoapResult = JSON.parse(cleaned);

  // 유효성 검증
  const requiredKeys: (keyof SoapResult)[] = [
    "subjective",
    "objective",
    "assessment",
    "plan",
    "unclassified",
  ];

  for (const key of requiredKeys) {
    if (!Array.isArray(parsed[key])) {
      parsed[key] = [];
    }
  }

  const elapsed = Date.now() - startTime;
  console.log(`[SnapSOAP] 구조화 완료: ${elapsed}ms`);

  return parsed;
}
CLAUDE_LIB

echo -e "${GREEN}✓ Claude API 래퍼 완료 (src/lib/claude.ts)${NC}"

# 샘플 데이터
cat > src/data/samples.ts << 'SAMPLES'
export interface SampleNote {
  id: string;
  title: string;
  department: string;
  description: string;
  text: string;
}

export const sampleNotes: SampleNote[] = [
  {
    id: "internal-med-1",
    title: "고혈압 + 당뇨 정기 진료",
    department: "내과",
    description: "만성질환 외래 추적관찰 케이스",
    text: `55세 남성 환자. HTN, DM type 2로 f/u 중.
오늘 특별한 불편감 없이 정기 방문함.
가끔 아침에 두통이 있다고 함. 약은 잘 복용 중.
식이조절은 잘 안 되고 있다고 함.

BP 138/88 mmHg, HR 76 bpm, BT 36.5°C.
체중 78kg (지난달 대비 1kg 증가).
심음 regular, 폐음 clear.

HbA1c 7.2% (이전 7.5%), FBS 132 mg/dL.
LDL 128 mg/dL, Cr 0.9 mg/dL.

HTN — controlled but borderline.
DM type 2 — HbA1c 호전 추세이나 목표 미달.
이상지질혈증 동반.

현재 약 유지 (Amlodipine 5mg, Metformin 1000mg bid).
Atorvastatin 20mg 추가 시작.
식이상담 의뢰.
3개월 후 f/u — HbA1c, lipid panel 재검.
혈압 자가 모니터링 교육.`,
  },
  {
    id: "er-1",
    title: "급성 복통 응급 내원",
    department: "응급의학과",
    description: "응급실 초기 평가 케이스",
    text: `32세 여성. 6시간 전부터 시작된 우하복부 통증으로 ER 내원.
통증은 점점 심해지고 있으며 NRS 7/10.
오심 있으나 구토는 없음. 마지막 식사 8시간 전.
LMP 2주 전, 규칙적.
과거력 특이사항 없음.

V/S: BP 124/78, HR 92, RR 18, BT 37.8°C.
복부 진찰 — RLQ tenderness (+), rebound tenderness (+).
McBurney point 압통 뚜렷. Psoas sign (+).
장음 감소.

WBC 14,200 (Seg 82%), CRP 4.8.
U/A — WNL.
복부 CT — appendix 직경 12mm, 주변 지방 침윤 소견.

Acute appendicitis, likely uncomplicated.

GS consult for appendectomy.
NPO 유지.
수액 NS 1L 투여 중.
Pain control — Ketorolac 30mg IV.
수술 전 CBC, coag, type & screen 오더.`,
  },
  {
    id: "pediatric-1",
    title: "소아 발열 + 인후통",
    department: "소아청소년과",
    description: "소아 감염질환 외래 케이스",
    text: `7세 남아. 이틀 전부터 열이 나고 목이 아프다고 함.
어머니에 의하면 체온 최고 39.2°C까지 올랐으며,
식사 잘 못하고 있음. 기침은 없음.
어린이집에서 같은 반 아이들 중 인후염 유행 중.
약물 알레르기 없음.

BT 38.4°C, HR 110, RR 22, SpO2 99%.
인후 발적 (+), 편도 비대 grade 2, 삼출물 (+).
경부 림프절 양측 촉지됨. 
흉부 청진 clear.

Rapid strep test — positive.
GAS pharyngitis (Group A Streptococcal).

Amoxicillin 50mg/kg/day divided tid x 10 days.
해열제: Acetaminophen 15mg/kg q6h PRN.
수분 섭취 격려, 부드러운 음식.
48시간 후에도 호전 없으면 재방문.
합병증 증상(발진, 관절통, 혈뇨) 설명 및 교육.`,
  },
];
SAMPLES

echo -e "${GREEN}✓ 샘플 데이터 생성 완료 (src/data/samples.ts)${NC}"

# 글로벌 CSS
cat > src/app/globals.css << 'GLOBALS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css');

:root {
  --foreground: #171717;
  --background: #ffffff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground: #ededed;
    --background: #0a0a0a;
  }
}

body {
  color: var(--foreground);
  background: var(--background);
  font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
}

/* SOAP 섹션 색상 (라이트 모드) */
.soap-section-s { border-left: 4px solid #8B5CF6; background-color: #EDE9FE; }
.soap-section-o { border-left: 4px solid #3B82F6; background-color: #DBEAFE; }
.soap-section-a { border-left: 4px solid #F59E0B; background-color: #FEF3C7; }
.soap-section-p { border-left: 4px solid #10B981; background-color: #D1FAE5; }
.soap-section-unclassified { border-left: 4px solid #6B7280; background-color: #F3F4F6; }

/* 텍스트 에디터 스타일 */
.editor-textarea {
  font-family: 'Pretendard', sans-serif;
  line-height: 1.8;
  resize: vertical;
}

.editor-textarea:focus {
  outline: none;
  box-shadow: 0 0 0 2px rgba(139, 92, 246, 0.3);
}

/* 스켈레톤 로딩 */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}

/* 부드러운 전환 */
.fade-in {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
GLOBALS

echo -e "${GREEN}✓ 글로벌 CSS 생성 완료${NC}"

# DEVLOG 업데이트
cat >> docs/DEVLOG.md << 'DEVLOG'

### Phase 2 — 프로젝트 스캐폴딩
- **시각**: $(date '+%Y-%m-%d %H:%M')
- **작업**: Next.js 프로젝트 구조, 타입 정의, 프롬프트 설계, API 래퍼, 샘플 데이터
- **결정 사항**:
  - Tailwind에 SOAP 커스텀 컬러 팔레트 추가 (S=보라, O=파랑, A=노랑, P=초록)
  - Claude Sonnet 모델 사용 (비용 효율 + 충분한 성능)
  - 프롬프트에 한국어/영어 혼용 처리 지원 포함
  - 샘플 3종: 내과 만성질환, 응급 복통, 소아 감염
- **기술 메모**:
  - API Route에서 서버사이드로만 Claude 호출 (키 보호)
  - JSON 응답 파싱 시 코드블록 마크다운 제거 로직 포함
- **다음 단계**: API Route 구현 + 메인 페이지 레이아웃

---
DEVLOG

# 커밋
git add -A
git commit -m "feat: 프로젝트 스캐폴딩 — 타입, 프롬프트, API 래퍼, 샘플 데이터, CSS 시스템"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Phase 2 완료: 프로젝트 스캐폴딩${NC}"
echo -e "${YELLOW}📊 누적 예상 점수: 약 45 / 100${NC}"
echo -e "   문서화: ~30/40  |  기술: ~6/10  |  완성도: 0/20  |  아이디어: ~7/20  |  검증: 0/10"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 확인 포인트:${NC}"
echo "  1. src/lib/prompts.ts — SOAP 분류 프롬프트가 의료 현장에 맞는지"
echo "  2. src/lib/types.ts — 타입 정의가 누락 없이 완전한지"
echo "  3. src/data/samples.ts — 샘플 진료 기록이 현실적인지"
echo "  4. tailwind.config.ts — SOAP 색상 팔레트가 시각적으로 구분되는지"
echo ""
echo -e "${RED}⚠️ 다음 Phase 전에:${NC}"
echo "  - npm install 실행 필요"
echo "  - .env.local에 ANTHROPIC_API_KEY 설정 필요"

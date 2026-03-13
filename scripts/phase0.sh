#!/bin/bash
#===============================================================================
# Phase 0: 프로젝트 초기화 + CLAUDE.md 생성
# 목표 점수: AI 컨텍스트 12점 중 11점
#===============================================================================

PROJECT_DIR=${1:-"$(pwd)/snapsoap"}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Phase 0: 프로젝트 초기화 + CLAUDE.md ━━━${NC}"

# 프로젝트 디렉토리 생성
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Git 초기화
git init
echo -e "${GREEN}✓ Git 초기화 완료${NC}"

# .gitignore 생성
cat > .gitignore << 'GITIGNORE'
node_modules/
.next/
.env
.env.local
.env.production
dist/
build/
*.log
.DS_Store
coverage/
.vercel/
GITIGNORE

echo -e "${GREEN}✓ .gitignore 생성 완료${NC}"

# CLAUDE.md 생성 (AI 컨텍스트 파일 — 12점 배점)
cat > CLAUDE.md << 'CLAUDEMD'
# CLAUDE.md — SnapSOAP AI 컨텍스트

## 프로젝트 개요
SnapSOAP는 의사가 자유텍스트로 입력한 진료 기록을 AI가 실시간으로 
SOAP(Subjective·Objective·Assessment·Plan) 포맷으로 자동 구조화해주는 웹 에디터입니다.

## 핵심 문제
- 의사들은 진료 중 빠르게 기록하기 위해 자유텍스트를 사용함
- 자유텍스트는 검색·분석·품질관리에 부적합
- 구조화 템플릿은 입력이 번거로워 의사들의 저항이 큼
- "자유롭게 쓰되, 결과는 구조화" 라는 딜레마 해결이 목표

## 아키텍처 결정

### 기술 스택
- **프론트엔드**: Next.js 14 (App Router) + TypeScript + Tailwind CSS
- **AI 엔진**: Anthropic Claude API (claude-sonnet-4-20250514)
- **상태관리**: React useState/useReducer (별도 라이브러리 불필요한 규모)
- **배포**: Vercel (Next.js 최적화)

### 왜 이 스택인가
1. Next.js: API Route로 백엔드 별도 구성 불필요 → 개발 속도 극대화
2. Claude API: 의료 텍스트 이해도가 높고, structured output(JSON mode) 지원
3. Tailwind: 빠른 UI 프로토타이핑, 디자인 시스템 없이도 일관성 유지

### API 호출 설계
```
[사용자 입력 텍스트]
     ↓
[프론트엔드] POST /api/structurize
     ↓
[Next.js API Route] → Claude API 호출
     ↓  시스템 프롬프트: SOAP 분류 지침
     ↓  사용자 메시지: 원본 텍스트
     ↓
[Claude 응답] JSON 형태의 SOAP 구조
     ↓
[프론트엔드] 파싱 → UI 렌더링
```

## SOAP 포맷 가이드
- **Subjective (S)**: 환자의 주관적 호소, 증상 설명, 병력
- **Objective (O)**: 객관적 검사 소견, 활력징후, 검사 결과
- **Assessment (A)**: 진단명, 감별진단, 임상적 판단
- **Plan (P)**: 치료 계획, 처방, 추적관찰 계획

## 프롬프트 설계 원칙
1. 의학 약어를 인식하되 원문 보존 (예: HTN → "HTN" 그대로, 카테고리만 분류)
2. 애매한 문장은 가장 관련성 높은 SOAP 섹션에 배치
3. 하나의 문장이 여러 섹션에 해당하면 가장 주된 섹션에 배치
4. 분류 불가한 내용은 "Unclassified" 섹션으로 분리
5. 원문의 순서와 내용을 절대 변경하지 않음 (재배열만 수행)

## 에러 핸들링 방침
- API 호출 실패 → 사용자에게 재시도 안내 + 원본 텍스트 보존
- 파싱 실패 → 원본 텍스트를 Unclassified로 전체 표시
- 빈 입력 → 입력 유도 메시지 표시
- 네트워크 오류 → 오프라인 상태 안내

## 파일 구조
```
snapsoap/
├── CLAUDE.md              # 이 파일 (AI 컨텍스트)
├── README.md              # 프로젝트 설명 + 설치/실행 가이드
├── docs/
│   ├── PRD.md             # 제품 요구사항 정의서
│   ├── DEVLOG.md          # 개발 진행 기록
│   └── VALIDATION.md      # 검증 계획서
├── src/
│   ├── app/
│   │   ├── layout.tsx     # 루트 레이아웃
│   │   ├── page.tsx       # 메인 에디터 페이지
│   │   └── api/
│   │       └── structurize/
│   │           └── route.ts   # AI 구조화 API 엔드포인트
│   ├── components/
│   │   ├── Editor/
│   │   │   ├── TextInput.tsx      # 자유텍스트 입력 패널
│   │   │   ├── SoapOutput.tsx     # SOAP 구조화 결과 패널
│   │   │   ├── SoapSection.tsx    # 개별 SOAP 섹션 컴포넌트
│   │   │   └── SplitView.tsx      # 좌우 분할 레이아웃
│   │   ├── Common/
│   │   │   ├── Button.tsx
│   │   │   ├── LoadingSpinner.tsx
│   │   │   └── Toast.tsx
│   │   └── Demo/
│   │       └── SampleSelector.tsx # 샘플 진료 기록 선택
│   ├── lib/
│   │   ├── claude.ts      # Claude API 래퍼
│   │   ├── prompts.ts     # SOAP 구조화 프롬프트
│   │   └── types.ts       # TypeScript 타입 정의
│   └── data/
│       └── samples.ts     # 데모용 샘플 진료 기록
├── public/
│   └── favicon.ico
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.js
└── .env.example
```

## 코딩 컨벤션
- 컴포넌트: PascalCase (예: SoapOutput.tsx)
- 유틸/라이브러리: camelCase (예: claude.ts)
- CSS: Tailwind 유틸리티 클래스 우선, 커스텀 CSS 최소화
- 타입: 인터페이스 prefix 없음 (ISoapResult ❌ → SoapResult ✅)
- 에러 처리: try-catch + 사용자 친화적 메시지

## 커밋 컨벤션
```
feat: 새 기능 추가
fix: 버그 수정  
docs: 문서 변경
style: UI/스타일 변경
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드/설정 변경
```

## 주의사항
- .env 파일은 절대 커밋하지 않음
- API 키는 환경 변수로만 관리
- 의료 데이터는 모두 더미 데이터 사용 (실제 환자 정보 절대 포함 금지)
- 이 프로젝트는 프로토타입이며, 실제 의료 현장 적용 시 별도 인증/보안 검토 필요
CLAUDEMD

echo -e "${GREEN}✓ CLAUDE.md 생성 완료 (AI 컨텍스트 파일)${NC}"

# 개발 로그 초기화
mkdir -p docs
cat > docs/DEVLOG.md << 'DEVLOG'
# SnapSOAP 개발 진행 기록

## 개발 타임라인

### Phase 0 — 프로젝트 초기화
- **시각**: $(date '+%Y-%m-%d %H:%M')
- **작업**: 프로젝트 구조 생성, Git 초기화, CLAUDE.md 작성
- **결정 사항**: 
  - Next.js 14 + TypeScript + Tailwind CSS 스택 확정
  - SOAP 구조화를 핵심 기능으로 설정
  - Claude API를 AI 엔진으로 선택 (의료 텍스트 이해도 고려)
- **다음 단계**: PRD 작성 → 프로젝트 스캐폴딩

---
DEVLOG

echo -e "${GREEN}✓ DEVLOG.md 초기화 완료${NC}"

# 초기 커밋
git add -A
git commit -m "chore: 프로젝트 초기화 — CLAUDE.md, .gitignore, DEVLOG 생성"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Phase 0 완료: 프로젝트 초기화 + CLAUDE.md${NC}"
echo -e "${YELLOW}📊 누적 예상 점수: 약 15 / 100${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 확인 포인트:${NC}"
echo "  1. CLAUDE.md 내용이 프로젝트 맥락을 충실히 담고 있는지"
echo "  2. 파일 구조가 실제 구현 계획과 맞는지"
echo "  3. SOAP 포맷 가이드가 정확한지"
echo "  4. docs/DEVLOG.md에 작업 기록이 시작되었는지"
echo ""
echo -e "${YELLOW}📁 생성된 파일:${NC}"
echo "  $PROJECT_DIR/CLAUDE.md"
echo "  $PROJECT_DIR/.gitignore"
echo "  $PROJECT_DIR/docs/DEVLOG.md"

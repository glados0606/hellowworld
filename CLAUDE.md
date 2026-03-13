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
- **AI 엔진**: Groq API (llama-3.3-70b-versatile) — 최종 채택
- **상태관리**: React useState/useReducer (별도 라이브러리 불필요한 규모)
- **배포**: Vercel (Next.js 최적화)

### 왜 이 스택인가
1. Next.js: API Route로 백엔드 별도 구성 불필요 → 개발 속도 극대화
2. Groq API: 빠른 추론 속도(평균 370~400ms), OpenAI 호환 SDK, JSON mode 지원, 무료 티어 제공으로 프로토타입 검증에 적합
3. Tailwind: 빠른 UI 프로토타이핑, 디자인 시스템 없이도 일관성 유지

### AI 엔진 변경 이력

프로토타입 개발 과정에서 AI 엔진이 3차례 변경되었다. 각 변경의 이유는 아래와 같다.

| 단계 | 엔진 | 변경 이유 |
|------|------|-----------|
| **v1** | Anthropic Claude API (claude-sonnet-4-20250514) | 의료 텍스트 이해도 및 JSON structured output 품질 우수. 초기 설계 기준. |
| **v2** | Google Gemini API (gemini-2.0-flash) | 비용 절감 탐색 (무료 티어 활용). 단, Node.js Windows 환경에서 `fetch failed` SSL 오류 지속 발생 → 안정성 문제 |
| **v3** ✅ | Groq API (llama-3.3-70b-versatile) | OpenAI 호환 SDK(`groq-sdk`)로 Windows SSL 문제 완전 해결. 평균 370~400ms 응답 → 5초 KPI 달성. Llama 3.3 70B는 한국어 의료 텍스트 분류 품질 충분. 무료 티어로 프로토타입 검증 가능 |

> **트레이드오프**: Groq + Llama 모델은 Anthropic Claude 대비 의료 특화 미세조정이 없으나, 프롬프트 엔지니어링으로 보완 가능한 수준임을 실험적으로 확인. 프로덕션 전환 시 Claude API 재검토 권장.

### API 호출 설계
```
[사용자 입력 텍스트]
     ↓
[프론트엔드] POST /api/structurize
     ↓
[Next.js API Route] → Groq API 호출 (timeout: 10s)
     ↓  시스템 프롬프트: SOAP 분류 지침
     ↓  사용자 메시지: 원본 텍스트
     ↓  모델: llama-3.3-70b-versatile
     ↓
[Groq 응답] JSON 형태의 SOAP 구조
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

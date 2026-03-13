# SnapSOAP

> 자유텍스트 진료 기록을 AI가 SOAP 포맷으로 자동 구조화하는 웹 에디터

[![Built with Next.js](https://img.shields.io/badge/Built%20with-Next.js%2014-black)](https://nextjs.org)
[![Powered by Claude](https://img.shields.io/badge/Powered%20by-Claude%20API-orange)](https://anthropic.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue)](https://typescriptlang.org)

---

## 문제

EMR 현장에서 반복적으로 목격한 장면이 있다.

```
"38.2 기침 3일 인후통 편도비대 편도염 Aug 3일"
```

바쁜 의사는 진료 중 이렇게 기록한다.
빠르고 자연스럽지만, 이 텍스트는 **검색도, 분석도, 청구 근거로도 활용할 수 없다**.

그렇다고 구조화 템플릿을 강제하면? 의사들은 쓰지 않는다.
5분 진료에서 클릭이 늘어나는 건 치명적이다.

**SnapSOAP는 이 딜레마를 해결한다.**
입력 방식은 그대로. 버튼 하나로 SOAP 구조가 완성된다.

---

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **자유텍스트 입력** | 평소처럼 차트를 작성한다. 형식 제약 없음 |
| **AI SOAP 구조화** | 버튼 한 번으로 S/O/A/P 자동 분류 (≤5초) |
| **인라인 편집** | 분류 결과를 클릭해서 직접 수정 |
| **샘플 케이스** | 실제 1차 진료 케이스 4종으로 즉시 체험 |
| **결과 복사** | 마크다운 또는 플레인텍스트로 클립보드 복사 |

---

## 데모

> 구현 완료 후 스크린샷 추가 예정

**입력 예시**:
```
38.2 기침 3일, 어제부터 인후통 심해짐.
편도 양측 발적, 삼출물 없음.
BP 120/80, HR 82. 편도염 의심.
Augmentin 625mg 3일 처방, 3일 후 재진.
```

**출력 예시**:
```
[S] 38.2 기침 3일 / 어제부터 인후통 심해짐
[O] 편도 양측 발적, 삼출물 없음 / BP 120/80, HR 82
[A] 편도염 의심
[P] Augmentin 625mg 3일 처방 / 3일 후 재진
```

---

## 빠른 시작

### 사전 요구사항

- Node.js 18+
- Anthropic API Key ([console.anthropic.com](https://console.anthropic.com)에서 발급)

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/your-username/snapsoap.git
cd snapsoap

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env.local
# .env.local 파일을 열고 ANTHROPIC_API_KEY 값을 입력
```

```bash
# 개발 서버 실행
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

---

## 기술 스택

| 영역 | 기술 | 선택 이유 |
|------|------|-----------|
| 프레임워크 | Next.js 14 (App Router) | API Route로 풀스택 구현, 별도 백엔드 불필요 |
| 언어 | TypeScript | AI 응답 파싱 타입 안전성, 런타임 오류 방지 |
| 스타일 | Tailwind CSS | 빠른 프로토타이핑, 디자인 시스템 불필요 |
| AI 엔진 | Claude Sonnet (Anthropic) | 의료 텍스트 이해도, JSON structured output |
| 배포 | Vercel | Next.js 최적화, 제로 설정 |

---

## 프로젝트 구조

```
snapsoap/
├── CLAUDE.md                    # AI 컨텍스트 파일
├── docs/
│   ├── PRD.md                   # 제품 요구사항 정의서
│   ├── DEVLOG.md                # 개발 진행 기록
│   └── VALIDATION.md            # 검증 계획서
├── src/
│   ├── app/
│   │   ├── layout.tsx           # 루트 레이아웃
│   │   ├── page.tsx             # 메인 에디터 페이지
│   │   └── api/structurize/
│   │       └── route.ts         # AI 구조화 API 엔드포인트
│   ├── components/
│   │   ├── Editor/
│   │   │   ├── TextInput.tsx    # 자유텍스트 입력 패널
│   │   │   ├── SoapOutput.tsx   # SOAP 결과 패널
│   │   │   ├── SoapSection.tsx  # 개별 섹션 컴포넌트
│   │   │   └── SplitView.tsx    # 좌우 분할 레이아웃
│   │   ├── Common/
│   │   │   ├── Button.tsx
│   │   │   ├── LoadingSpinner.tsx
│   │   │   └── Toast.tsx
│   │   └── Demo/
│   │       └── SampleSelector.tsx
│   ├── lib/
│   │   ├── claude.ts            # Claude API 래퍼
│   │   ├── prompts.ts           # SOAP 구조화 프롬프트
│   │   └── types.ts             # TypeScript 타입 정의
│   └── data/
│       └── samples.ts           # 데모용 샘플 진료 기록
└── .env.example
```

---

## 환경 변수

```bash
# .env.local
ANTHROPIC_API_KEY=sk-ant-xxxxx   # 필수
NODE_ENV=development              # development | production
```

API 키는 서버사이드에서만 사용되며, 클라이언트에 노출되지 않는다.

---

## SOAP 포맷 가이드

| 섹션 | 의미 | 예시 |
|------|------|------|
| **S** Subjective | 환자의 주관적 호소, 증상, 발병 기간 | "3일째 기침", "어지럽다고 함" |
| **O** Objective | 활력징후, 신체 검진 소견, 검사 결과 | "BP 130/80", "청진 정상" |
| **A** Assessment | 진단명, 임상적 판단, 감별진단 | "급성 인두염", "HTN 조절 양호" |
| **P** Plan | 처방, 처치, 추적관찰 계획 | "항생제 5일", "2주 후 재진" |

---

## 개발 문서

- [PRD — 제품 요구사항 정의서](./docs/PRD.md)
- [DEVLOG — 개발 진행 기록](./docs/DEVLOG.md)
- [VALIDATION — 검증 계획](./docs/VALIDATION.md)

---

## 주의사항

- 이 프로젝트는 **프로토타입**이며 실제 임상 사용을 위한 제품이 아닙니다
- 모든 샘플 데이터는 더미 데이터입니다. 실제 환자 정보를 입력하지 마세요
- 실제 의료 현장 적용 시 별도 임상 검증 및 보안 검토가 필요합니다

---

## 라이선스

MIT

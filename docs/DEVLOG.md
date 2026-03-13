# SnapSOAP 개발 진행 기록

## 개발 타임라인

### Phase 0 — 프로젝트 초기화
- **시각**: 2026-03-13
- **작업**: 프로젝트 구조 생성, Git 초기화, CLAUDE.md 작성
- **결정 사항**:
  - Next.js 14 + TypeScript + Tailwind CSS 스택 확정
  - SOAP 구조화를 핵심 기능으로 설정
  - Claude API를 AI 엔진으로 선택 (의료 텍스트 이해도 고려)
- **트레이드오프**: Next.js App Router(신규) vs Pages Router(안정) → App Router 채택. 이유: API Route 내장, Server Components로 초기 로드 최적화, Vercel 배포 호환성 최적. 리스크: 상대적으로 짧은 생태계 성숙도, 러닝커브.
- **다음 단계**: PRD 작성 → 프로젝트 스캐폴딩

---

### Phase 1 — PRD + README 작성
- **시각**: 2026-03-13
- **작업**: PRD 작성 (문제 정의, 목표, 기능 명세, 사용자 플로우), README 작성, .env.example 생성
- **결정 사항**:
  - MVP 기능 3개 확정: 자유텍스트 입력(F1), AI 구조화(F2), 결과 패널(F3)
  - 부가 기능 3개 정의: 샘플 데이터(F4), 내보내기(F5), 재구조화(F6)
  - 성공 지표 5개 설정: 분류 정확도 85%, 응답 5초, SUS 70점, TCR 90%, 약어 보존율 100%
  - EMR 현장 경험 반영: 의사랑 관찰 기반 문제 정의, 한국 1차 진료 특화 케이스
- **다음 단계**: 프로젝트 스캐폴딩 + Next.js 셋업

---

### Phase 2 — 프로젝트 스캐폴딩
- **시각**: 2026-03-13
- **작업**: 설정 파일, 타입 정의, SOAP 프롬프트, AI API 래퍼, 샘플 데이터, 글로벌 CSS
- **결정 사항**:
  - Tailwind에 SOAP 커스텀 컬러 (S=보라, O=파랑, A=노랑, P=초록)
  - AI 엔진 (당시) Claude Sonnet (claude-sonnet-4-20250514) → 이후 Groq로 전환
  - API 타임아웃 10초 설계 원칙 수립
  - 샘플 4종: 급성 URI, 고혈압·당뇨 정기, 급성 요통, 당뇨 합병증
- **트레이드오프**: 실시간 구조화(onChange) vs 버튼 트리거 방식 → 버튼 방식 채택. 이유: API 비용 절감(토큰 낭비 방지), 의사의 기록 완성 흐름 유지, 의도적 제어권 부여. 실시간 방식은 UX 직관성이 높지만 API 비용·네트워크 부담이 크다.
- **기술 메모**:
  - types.ts에 SOAP_META, SOAP_ORDER, AppState 포함 — UI 렌더링 전용 타입 분리
  - prompts.ts에 한국 1차 진료 약어 분류 테이블 포함 (BP→O, r/o→A, f/u→P 등)
  - claude.ts: JSON 파싱 전 마크다운 코드블록 제거, 필수 키 보정 로직
  - 샘플 데이터: 실제 의원 문체(비문·축약·혼용) 재현
- **다음 단계**: API Route + 메인 페이지 레이아웃 + 컴포넌트 구현

---

### Phase 3 — 핵심 기능 구현
- **시각**: 2026-03-13
- **작업**: API Route, layout, 공통 컴포넌트, 에디터 컴포넌트, 샘플 선택기
- **구현 완료**:
  - `POST /api/structurize` — 5자 미만/10000자 초과/API 키 누락 각각 분기 처리, SOAP별 항목 수 로깅
  - `layout.tsx` — sticky 헤더, 프로토타입 면책 푸터
  - `Button` — primary/secondary/ghost/danger 4종 variant
  - `Toast` — success/error/warning/info 4종, 자동 닫힘
  - `LoadingSkeleton` — SOAP 색상 그대로 스켈레톤 (위치 예고 효과)
  - `TextInput` — 글자 수 색상 경고(85% amber, 초과 red), IME spellCheck off
  - `SoapSection` — SOAP_META 기반 렌더링, 인라인 편집, 항목 삭제(✕), 빈 섹션 흐리게
  - `SoapOutput` — 로딩/에러/초기/결과 4개 상태 분기, 미분류 경고 배지
  - `SampleSelector` — 진료과 배지 컬러 코딩, 선택 상태(aria-pressed), 툴팁
- **기술 메모**:
  - SoapSection: SOAP_SECTIONS → SOAP_META로 통일 (Phase 2 타입과 일치)
  - SOAP_ORDER 배열로 렌더링 순서 보장
  - 에러 상태에서 onRetry 콜백으로 재시도 지원
- **다음 단계**: 메인 페이지(page.tsx) 조립 — Split-View 레이아웃

---

### Phase 4 — UI/UX 구현 (메인 페이지 조립)
- **시각**: 2026-03-13
- **작업**: 메인 페이지 조립, Split-View 레이아웃, 상태 관리 통합
- **UX 결정 사항**:
  - Split-View: lg 이상 2컬럼, 모바일 세로 스택
  - 버튼 트리거 방식 (실시간 아님 — API 비용 + 의도적 동작)
  - `Ctrl+Enter` / `Cmd+Enter` 키보드 단축키
  - 에러 상태(`error` 문자열) 별도 관리 → SoapOutput에 전달, onRetry로 재시도 가능
  - 복사 형식: `[Section]\n• 항목` 마크다운 구조
  - Toast: success/error/info/warning 4종
- **UX 플로우**: 샘플 선택 → 구조화(or Ctrl+Enter) → 로딩 → 결과 → 편집/복사/재구조화
- **다음 단계**: 검증 계획서 작성

---

### Phase 5 — 검증 계획서 작성
- **시각**: 2026-03-13
- **작업**: `docs/VALIDATION.md` 작성 — 가설 3개, KPI 6개, 테스트 설계 3종
- **검증 설계 요약**:
  - **가설 1 (효율성)**: 수동 대비 문서화 시간 40% 이상 단축
  - **가설 2 (정확도)**: SOAP 분류 정확도 85% 이상
  - **가설 3 (사용성)**: SUS 점수 70점 이상 (Good 등급)
- **KPI 6개**: SOAP 분류 정확도, Task Completion Time, API 응답 시간, SUS 점수, Task Completion Rate, 수정률
- **테스트 설계**:
  - 정확도 검증: 10건 다양한 진료과 케이스, 전문가 2인 독립 평가
  - 사용성 테스트: 5개 태스크 시나리오, Think-aloud 프로토콜, SUS 설문
  - A/B 비교: 수동 SOAP 정리 vs SnapSOAP AI 구조화 시간 측정
- **다음 단계**: 최종 점검 및 커밋 정리

---

### Phase 6 — 최종 점검 및 마무리
- **시각**: 2026-03-13
- **작업**: 필수 파일 전체 점검, DEVLOG 업데이트, 최종 커밋 생성
- **점검 결과**: 필수 파일 23개 전체 확인 ✅
- **주요 변경 이력** (이번 세션):
  - Groq API 마이그레이션 (`groq-sdk`, `llama-3.3-70b-versatile`)
  - SSL 우회 설정 (`NODE_TLS_REJECT_UNAUTHORIZED=0`) — Windows 환경 대응
  - Split-View 레이아웃 구현 완료 (`page.tsx` 재조립)
  - `docs/VALIDATION.md` 신규 작성
- **최종 프로젝트 구조**:
  ```
  snapsoap/
  ├── CLAUDE.md, README.md
  ├── docs/ (PRD.md, DEVLOG.md, VALIDATION.md)
  ├── src/
  │   ├── app/ (page.tsx, layout.tsx, globals.css, api/structurize/)
  │   ├── components/ (Editor/, Common/, Demo/)
  │   ├── lib/ (claude.ts, prompts.ts, types.ts)
  │   └── data/ (samples.ts)
  ├── package.json, tsconfig.json, tailwind.config.ts
  └── .env.example, .gitignore
  ```
- **AI 엔진**: Groq API (llama-3.3-70b-versatile) — 평균 응답 370-400ms
- **상태**: 프로토타입 완성, 검증 준비 완료

---

## 기술 결정 기록 (Architecture Decision Records)

### ADR-001: AI 엔진 선택 및 변경 이력

**배경**: 자유텍스트 → SOAP JSON 변환의 핵심 엔진. 정확도, 응답 속도, 비용, 환경 안정성 네 가지 기준으로 평가.

| 기준 | Anthropic Claude | Google Gemini | Groq (Llama 3.3) |
|------|-----------------|---------------|-------------------|
| 의료 텍스트 이해도 | ★★★★★ | ★★★★ | ★★★★ |
| JSON structured output | ✅ 네이티브 지원 | ✅ 지원 | ✅ 지원 |
| 응답 속도 | ~2~5초 | ~2~4초 | **~0.4초** |
| 무료 티어 | ❌ (크레딧 소진 시 중단) | ✅ | ✅ |
| Windows 환경 안정성 | ✅ | ❌ SSL 오류 | ✅ |
| SDK 성숙도 | ★★★★★ | ★★★★ | ★★★★ |

**결정**: Groq + Llama 3.3 70B 채택.
**근거**: 프로토타입 단계에서 속도(0.4초)와 비용(무료 티어)이 결정적. 의료 특화 정확도는 프롬프트 엔지니어링으로 보완 가능. Windows 개발 환경에서의 안정성이 검증됨.
**향후 재검토 조건**: 프로덕션 전환 시 Anthropic Claude 재평가 권장 (의료 특화 fine-tuning, 책임 소재 명확성).

---

### ADR-002: 상태 관리 전략

**결정**: Redux/Zustand 없이 React `useReducer` 채택.
**근거**: 상태 복잡도가 AppState(text, status, result, error, toast) 5개 필드로 제한됨. 외부 라이브러리 추가 시 번들 크기 증가 및 보일러플레이트 오버헤드. 현재 규모에서 `useReducer`로 충분히 타입 안전하고 예측 가능한 상태 관리 가능.

---

### ADR-003: 데이터 비저장 원칙

**결정**: 서버에 진료 기록 데이터를 일체 저장하지 않음 (stateless API).
**근거**: HIPAA 및 개인정보보호법 리스크 사전 차단. 프로토타입 단계에서 DB 설계 복잡도 제거. 의사들의 실제 데이터를 서버에 전송한다는 심리적 저항 최소화.
**트레이드오프**: 히스토리, 재사용, 분석 기능 불가 → v2 로드맵으로 보류.

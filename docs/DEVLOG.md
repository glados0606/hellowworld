# SnapSOAP 개발 진행 기록

## 개발 타임라인

### Phase 0 — 프로젝트 초기화
- **시각**: 2026-03-13
- **작업**: 프로젝트 구조 생성, Git 초기화, CLAUDE.md 작성
- **결정 사항**:
  - Next.js 14 + TypeScript + Tailwind CSS 스택 확정
  - SOAP 구조화를 핵심 기능으로 설정
  - Claude API를 AI 엔진으로 선택 (의료 텍스트 이해도 고려)
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
- **작업**: 설정 파일, 타입 정의, SOAP 프롬프트, Claude API 래퍼, 샘플 데이터, 글로벌 CSS
- **결정 사항**:
  - Tailwind에 SOAP 커스텀 컬러 (S=보라, O=파랑, A=노랑, P=초록)
  - Claude Sonnet 사용 (claude-sonnet-4-20250514)
  - API 타임아웃 10초, Promise.race 패턴
  - 샘플 4종: 급성 URI, 고혈압·당뇨 정기, 급성 요통, 당뇨 합병증
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

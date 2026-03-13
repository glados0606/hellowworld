#!/bin/bash
#===============================================================================
# Phase 1: PRD + README 작성
# 목표 점수: 프로젝트 정의 16점 중 15점
#===============================================================================

PROJECT_DIR=${1:-"$(pwd)/snapsoap"}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Phase 1: PRD + README 작성 ━━━${NC}"
cd "$PROJECT_DIR"

# PRD 작성 (제품 요구사항 정의서)
cat > docs/PRD.md << 'PRD'
# SnapSOAP — Product Requirements Document (PRD)

## 1. 문제 정의

### 1.1 배경
EMR(Electronic Medical Record) 시스템에서 진료 기록 작성은 의사의 일상 업무 중 
가장 큰 시간적 부담을 차지한다. 미국 내과학회(ACP) 조사에 따르면, 
의사들은 환자 대면 시간의 약 2배를 문서화에 소비하고 있으며, 
이는 번아웃의 주요 원인으로 지목되고 있다.

### 1.2 현재 상황의 문제점

| 방식 | 장점 | 단점 |
|------|------|------|
| 자유텍스트 입력 | 빠름, 자연스러움 | 검색 불가, 분석 불가, 품질 편차 |
| 구조화 템플릿 | 일관성, 검색 가능 | 입력 번거로움, 워크플로우 방해 |
| 음성→텍스트 변환 | 핸즈프리 | 비용, 소음 환경 부적합, 후편집 필요 |

### 1.3 핵심 인사이트
> "의사는 자유롭게 쓰고 싶고, 병원은 구조화된 데이터가 필요하다."

이 딜레마를 AI로 해결한다. 입력은 자유텍스트, 출력은 SOAP 구조.

## 2. 프로젝트 목표

### 2.1 제품 비전
의사가 자유텍스트로 진료 기록을 입력하면, AI가 실시간으로 SOAP 포맷으로 
자동 분류·구조화해주는 경량 웹 에디터.

### 2.2 목표 사용자
- **주 사용자**: 1차 진료 의사 (내과, 가정의학과)
- **부 사용자**: 전공의, PA(Physician Assistant), NP(Nurse Practitioner)
- **이해관계자**: 병원 IT팀, 품질관리팀, EMR 벤더

### 2.3 성공 기준
| 지표 | 목표값 | 측정 방법 |
|------|--------|-----------|
| SOAP 분류 정확도 | ≥ 85% | 전문가 리뷰 (10건 샘플) |
| 구조화 소요 시간 | ≤ 5초 | API 응답 시간 측정 |
| 사용성 점수 (SUS) | ≥ 70점 | SUS 설문 (5명) |
| Task Completion Rate | ≥ 90% | 시나리오 테스트 |

## 3. 기능 명세

### 3.1 MVP 기능 (필수)

#### F1: 자유텍스트 입력
- 좌측 패널에 텍스트 입력 영역 제공
- 최소 높이 300px, 리사이즈 가능
- 글자 수 카운터 표시
- Placeholder로 입력 가이드 제공

#### F2: AI SOAP 구조화
- "구조화" 버튼 클릭 시 AI 분석 실행
- Claude API를 통해 텍스트를 S/O/A/P 섹션으로 분류
- JSON 형태로 파싱 후 우측 패널에 표시
- 분류 불가 항목은 "Unclassified" 섹션으로 분리
- 로딩 상태 표시 (스켈레톤 UI)

#### F3: 결과 편집
- 각 SOAP 섹션의 내용을 직접 수정 가능
- 섹션 간 항목 드래그 앤 드롭 (시간 허용 시)
- 편집 후 결과 복사 기능

### 3.2 부가 기능 (시간 허용 시)

#### F4: 샘플 데이터
- 3~4개의 샘플 진료 기록 프리셋
- 클릭 시 입력 영역에 자동 채움
- 다양한 진료과 케이스 포함

#### F5: 의학 약어 하이라이트
- 자주 사용되는 의학 약어 자동 인식
- 툴팁으로 풀네임 표시

#### F6: 내보내기
- 구조화된 결과를 클립보드에 복사
- 마크다운 또는 플레인텍스트 형식 선택

## 4. 사용자 플로우

```
[메인 페이지 진입]
       ↓
[좌측 패널: 자유텍스트 입력]
  ├── 직접 타이핑
  └── 샘플 데이터 선택 (F4)
       ↓
["구조화" 버튼 클릭]
       ↓
[로딩 상태 (스켈레톤 UI)]
       ↓
[우측 패널: SOAP 결과 표시]
  ├── S: 주관적 호소
  ├── O: 객관적 소견
  ├── A: 평가/진단
  ├── P: 계획
  └── ?: 미분류
       ↓
[결과 편집 / 복사 / 재구조화]
```

## 5. 기술 요구사항

### 5.1 성능
- 초기 페이지 로드: ≤ 2초
- AI 구조화 응답: ≤ 5초 (평균)
- 입력 디바운스: 없음 (버튼 트리거 방식)

### 5.2 호환성
- Chrome 최신 버전 (주 대상)
- 반응형 지원: 데스크탑 우선, 태블릿 지원

### 5.3 보안
- API 키 서버사이드 전용 (클라이언트 노출 금지)
- 입력 데이터 저장하지 않음 (stateless)
- HTTPS 전용

## 6. 비기능 요구사항
- 접근성: 키보드 네비게이션 지원, ARIA 라벨
- 에러 복구: API 실패 시 원본 텍스트 보존
- 국제화: 한국어/영어 진료 기록 모두 처리 가능

## 7. 제외 범위 (Out of Scope)
- 사용자 인증/로그인
- 데이터 영구 저장
- 음성 입력 (STT)
- 실제 EMR 연동
- HIPAA/개인정보보호 인증
- 다중 사용자 동시 편집

## 8. 리스크 및 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| AI 분류 정확도 부족 | 핵심 가치 훼손 | 프롬프트 최적화, 샘플 테스트 반복 |
| API 응답 지연 | UX 저하 | 스트리밍 응답, 스켈레톤 UI |
| 의학 용어 오분류 | 신뢰도 하락 | 프롬프트에 의학 약어 가이드 포함 |
PRD

echo -e "${GREEN}✓ PRD.md 생성 완료${NC}"

# README.md 작성
cat > README.md << 'README'
# 🏥 SnapSOAP

> AI-powered clinical note structurizer — 자유텍스트 진료 기록을 SOAP 포맷으로 자동 구조화

[![Built with Next.js](https://img.shields.io/badge/Built%20with-Next.js%2014-black)](https://nextjs.org)
[![Powered by Claude](https://img.shields.io/badge/Powered%20by-Claude%20API-orange)](https://anthropic.com)

## 문제

의사들은 진료 중 빠른 기록을 위해 자유텍스트를 사용하지만, 
비구조화된 텍스트는 검색·분석·품질관리에 활용할 수 없습니다.
구조화 템플릿은 입력이 번거로워 현장 저항이 큽니다.

**SnapSOAP는 이 딜레마를 해결합니다:** 자유롭게 쓰되, 결과는 구조화.

## 핵심 기능

- **자유텍스트 입력**: 왼쪽 패널에서 평소처럼 진료 기록 작성
- **AI SOAP 구조화**: 버튼 한 번으로 S/O/A/P 자동 분류
- **실시간 편집**: 분류 결과를 직접 수정·조정 가능
- **샘플 데이터**: 다양한 진료과 케이스로 즉시 체험

## 스크린샷

> (구현 후 추가 예정)

## 빠른 시작

### 사전 요구사항
- Node.js 18+
- Anthropic API Key ([발급 방법](https://console.anthropic.com))

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/your-username/snapsoap.git
cd snapsoap

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env.local
# .env.local 파일에 ANTHROPIC_API_KEY 입력

# 개발 서버 실행
npm run dev
```

브라우저에서 `http://localhost:3000` 접속

## 기술 스택

| 영역 | 기술 | 선택 이유 |
|------|------|-----------|
| 프레임워크 | Next.js 14 (App Router) | API Route로 풀스택, 빠른 개발 |
| 언어 | TypeScript | 타입 안전성, AI 응답 파싱 신뢰도 |
| 스타일 | Tailwind CSS | 빠른 프로토타이핑, 일관된 디자인 |
| AI 엔진 | Claude API (Sonnet) | 의료 텍스트 이해도, JSON 출력 지원 |
| 배포 | Vercel | Next.js 최적화, 제로 설정 배포 |

## 프로젝트 구조

```
snapsoap/
├── CLAUDE.md          # AI 컨텍스트 파일
├── docs/
│   ├── PRD.md         # 제품 요구사항
│   ├── DEVLOG.md      # 개발 기록
│   └── VALIDATION.md  # 검증 계획
├── src/
│   ├── app/           # Next.js 앱 라우터
│   ├── components/    # React 컴포넌트
│   ├── lib/           # 유틸리티, API 래퍼
│   └── data/          # 샘플 데이터
└── public/
```

## 개발 기록

자세한 개발 과정은 [DEVLOG.md](./docs/DEVLOG.md)를 참고하세요.

## 검증 계획

사용자 검증 및 가설 검증 계획은 [VALIDATION.md](./docs/VALIDATION.md)를 참고하세요.

## 라이선스

MIT

## 기여

이 프로젝트는 해커톤 제출을 위해 제작되었습니다.
README

echo -e "${GREEN}✓ README.md 생성 완료${NC}"

# .env.example 생성
cat > .env.example << 'ENV'
# Anthropic API Key
# https://console.anthropic.com 에서 발급
ANTHROPIC_API_KEY=sk-ant-xxxxx

# 환경 (development | production)
NODE_ENV=development
ENV

echo -e "${GREEN}✓ .env.example 생성 완료${NC}"

# DEVLOG 업데이트
cat >> docs/DEVLOG.md << 'DEVLOG'

### Phase 1 — PRD + README 작성
- **시각**: $(date '+%Y-%m-%d %H:%M')
- **작업**: PRD 작성 (문제 정의, 목표, 기능 명세, 사용자 플로우), README 작성
- **결정 사항**:
  - MVP 기능 3개 확정: 자유텍스트 입력, AI 구조화, 결과 편집
  - 부가 기능 3개 정의: 샘플 데이터, 약어 하이라이트, 내보내기
  - 성공 지표 4개 설정: 정확도 85%, 응답 5초, SUS 70점, TCR 90%
- **다음 단계**: 프로젝트 스캐폴딩 + Next.js 셋업

---
DEVLOG

# 커밋
git add -A
git commit -m "docs: PRD, README, .env.example 작성 — 문제 정의 및 기능 명세 완료"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Phase 1 완료: PRD + README 작성${NC}"
echo -e "${YELLOW}📊 누적 예상 점수: 약 35 / 100${NC}"
echo -e "   문서화: ~28/40  |  기술: 0/10  |  완성도: 0/20  |  아이디어: ~7/20  |  검증: 0/10"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 확인 포인트:${NC}"
echo "  1. docs/PRD.md — 문제 정의가 실감나는지 (EMR 현장 경험 추가 가능)"
echo "  2. docs/PRD.md — 기능 명세가 구현 가능한 범위인지"
echo "  3. README.md — 프로젝트 소개가 한눈에 이해되는지"
echo "  4. 성공 지표가 현실적인지"
echo ""
echo -e "${YELLOW}💡 커스터마이징 팁:${NC}"
echo "  - PRD의 '문제 정의'에 본인의 EMR 현장 경험을 추가하면 점수 UP"
echo "  - README에 실제 스크린샷은 Phase 4 이후에 추가"

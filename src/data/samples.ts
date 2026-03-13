/**
 * 데모용 샘플 진료 기록
 *
 * 모두 더미 데이터입니다. 실제 환자 정보를 포함하지 않습니다.
 * 한국 1차 진료(내과·가정의학과) 실제 기록 문체를 최대한 재현했습니다.
 * - 축약어, 비문, 한영 혼용 — 실제 의사들이 쓰는 방식 그대로
 */

export interface SampleNote {
  id: string;
  title: string;
  department: string;
  description: string;
  text: string;
}

export const sampleNotes: SampleNote[] = [
  {
    id: "uri-1",
    title: "급성 상기도감염",
    department: "내과",
    description: "의원 가장 빈도 높은 케이스. 발열·기침·인후통 혼합 증상.",
    text: `38.2 기침 3일. 어제부터 인후통 심해짐. 콧물(+), 코막힘(+).
두통 약간 있음. 오심은 없음. 식욕 약간 저하.
어린이집 동생이 같은 증상.
NKA.

BP 118/76, HR 84, BT 38.2°C, SpO2 98%.
인후 발적(+). 편도 비대 없음. 삼출물 없음.
경부 림프절 촉지 안 됨.
흉부 청진 — vesicular, clear.
코 — 점막 발적, 분비물(+).

급성 비인두염. 바이러스성 URI 의심.

Tylenol 500mg 필요 시 복용 (6h 이상 간격).
Nasal decongestant 처방.
수분 섭취 충분히, 충분한 휴식.
3일 내 호전 없거나 39.5 이상 고열 지속 시 재방문.`,
  },
  {
    id: "htn-dm-1",
    title: "고혈압·당뇨 정기 방문",
    department: "내과",
    description: "만성질환 외래 추적관찰. HTN + DM 복합 케이스.",
    text: `62세 남성. HTN, DM type 2로 3개월 f/u.
오늘 특별한 불편 없이 정기 방문.
아침에 가끔 두통 있다고 함 — 혈압 오를 때 그런 것 같다고.
약은 빠짐없이 복용 중. 식이는 잘 안 됨(직장 회식 잦음).
금연 중 (3개월째). 음주 주 2~3회.

BP 142/88 mmHg (R arm, 5분 안정 후).
HR 78 bpm, BT 36.4°C.
체중 81kg (3개월 전 79kg, +2kg).
심음 regular, murmur 없음. 폐음 clear.
하지 부종 없음. 족부 감각 이상 호소 없음.

HbA1c 7.4% (이전 7.8% → 호전). FBS 148 mg/dL.
LDL-C 118 mg/dL. TG 210 mg/dL. HDL 38 mg/dL.
Cr 1.1 mg/dL. eGFR 68 (CKD stage G2 경계).
UA: 단백 trace.

HTN — not at goal (목표 BP <130/80).
DM type 2 — HbA1c 호전 추세, 아직 목표 미달.
고중성지방혈증 동반.
CKD stage G2 경계 — 추적 필요.

Amlodipine 5mg → 10mg 증량.
Metformin 1000mg bid 유지.
Rosuvastatin 10mg 추가 (TG 고려하여 fenofibrate 병용 검토).
저염식·저탄수화물 식이 재교육.
음주 제한 강하게 권고.
3개월 후 f/u — HbA1c, lipid panel, Cr, UA 재검.
eGFR 60 미만 시 신장내과 의뢰 예정.`,
  },
  {
    id: "lbp-1",
    title: "급성 요통 (직장인)",
    department: "정형외과·내과",
    description: "사무직 직장인 급성 요통. 무거운 물건 들다 발생.",
    text: `38세 남성. 어제 이사하다 무거운 짐 들고 난 후 갑자기 허리 통증 발생.
움직일 때 심하고 누워있으면 좀 나음. NRS 6/10.
다리 저림이나 방사통은 없음.
이전에 요통 병력 없음. 좌식 업무 (하루 8시간 이상 컴퓨터).
진통제 자가 복용 안 함.

BP 124/78, HR 72, BT 36.6°C.
체중 75kg.
요추 ROM — 굴곡 제한 (60도). 신전 시 통증 악화.
SLR test (-)/(-). 하지 근력 및 감각 정상.
척추 주위 근육 긴장(+), L4-5 level pressure pain(+).
신경학적 이상 소견 없음.

급성 요추 염좌 (Acute lumbar sprain).
추간판 탈출증(HNP) 가능성 낮음 — 신경 증상 없음.

Ibuprofen 400mg tid (식후) x 5일.
Muscle relaxant (Eperisone 50mg) tid x 5일.
온찜질 하루 2~3회.
급성기 (2~3일) 이후 스트레칭 시작.
무거운 물건 들기 2주 자제.
증상 지속 또는 다리 저림 생기면 X-ray + 재평가.`,
  },
  {
    id: "dm-complication-1",
    title: "당뇨 합병증 모니터링",
    department: "내과",
    description: "DM + CKD + 말초신경병증 병발 복합 케이스.",
    text: `68세 여성. DM type 2 (20년), CKD stage G3a, 말초신경병증으로 f/u.
양쪽 발이 저리고 화끈거리는 느낌 지속됨. 밤에 더 심하다고 함.
시력 약간 흐려진 것 같다고 함 (작년보다).
식욕 좋고 특별한 감기 증상 없음.
Insulin glargine 20U hs + Metformin 500mg bid 복용 중. Pregabalin 75mg bid 복용 중.

BP 136/84, HR 68, BT 36.3°C.
체중 62kg (3개월 전과 동일).
족부 시진 — 상처 없음. 피부 건조(+). 발톱 비후(+).
발 감각 검사 — 10g monofilament 우측 발등 감각 저하(+).
진동 감각 저하(+) 양측.
하지 DTR 저하.
안저 검사 미시행 (오늘은 시간 부족).

DM type 2 — HbA1c 추적 필요.
DM 말초신경병증 — 진행 양상.
CKD stage G3a — 신장 기능 추적 필요.
DM 망막병증 의심 — 안과 의뢰 필요.

HbA1c, FBS, 2h PP glucose 오더.
Cr, BUN, eGFR, UA (albumin/Cr ratio) 오더.
Pregabalin 75mg → 150mg bid 증량 (신경병증 통증 조절).
족부 관리 교육 재시행 — 매일 확인, 보습, 적절한 신발.
안과 의뢰서 작성 (DM 망막병증 스크리닝).
3개월 후 f/u. 혈당 조절 불량 시 당뇨 전문 클리닉 의뢰 검토.`,
  },
];

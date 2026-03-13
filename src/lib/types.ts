// ─── SOAP 섹션 타입 ───────────────────────────────────────────────────────────

export type SoapSectionType =
  | "subjective"
  | "objective"
  | "assessment"
  | "plan"
  | "unclassified";

/** AI가 반환하는 SOAP 구조화 결과 */
export interface SoapResult {
  subjective: string[];
  objective: string[];
  assessment: string[];
  plan: string[];
  unclassified: string[];
}

// ─── API 요청/응답 ────────────────────────────────────────────────────────────

export interface StructurizeRequest {
  text: string;
}

export interface StructurizeResponse {
  success: boolean;
  data?: SoapResult;
  error?: string;
  processingTime?: number;
}

// ─── UI 메타데이터 ────────────────────────────────────────────────────────────

export interface SoapSectionMeta {
  label: string;
  shortLabel: string; // "S" | "O" | "A" | "P" | "?"
  description: string;
  colorClass: string;      // Tailwind border/bg 클래스
  badgeClass: string;      // 헤더 배지 클래스
  textColorClass: string;  // 텍스트 색상 클래스
}

/** SOAP 각 섹션 메타데이터 — UI 렌더링에 사용 */
export const SOAP_META: Record<SoapSectionType, SoapSectionMeta> = {
  subjective: {
    label: "Subjective",
    shortLabel: "S",
    description: "환자의 주관적 호소 · 증상 · 병력",
    colorClass: "border-l-4 border-purple-500 bg-purple-50",
    badgeClass: "bg-purple-500 text-white",
    textColorClass: "text-purple-800",
  },
  objective: {
    label: "Objective",
    shortLabel: "O",
    description: "활력징후 · 신체검진 · 검사 결과",
    colorClass: "border-l-4 border-blue-500 bg-blue-50",
    badgeClass: "bg-blue-500 text-white",
    textColorClass: "text-blue-800",
  },
  assessment: {
    label: "Assessment",
    shortLabel: "A",
    description: "진단명 · 감별진단 · 임상 판단",
    colorClass: "border-l-4 border-amber-500 bg-amber-50",
    badgeClass: "bg-amber-500 text-white",
    textColorClass: "text-amber-800",
  },
  plan: {
    label: "Plan",
    shortLabel: "P",
    description: "처방 · 처치 · 추적관찰 계획",
    colorClass: "border-l-4 border-emerald-500 bg-emerald-50",
    badgeClass: "bg-emerald-500 text-white",
    textColorClass: "text-emerald-800",
  },
  unclassified: {
    label: "Unclassified",
    shortLabel: "?",
    description: "분류되지 않은 항목",
    colorClass: "border-l-4 border-gray-400 bg-gray-50",
    badgeClass: "bg-gray-400 text-white",
    textColorClass: "text-gray-700",
  },
};

/** 렌더링 순서 */
export const SOAP_ORDER: SoapSectionType[] = [
  "subjective",
  "objective",
  "assessment",
  "plan",
  "unclassified",
];

// ─── UI 상태 ──────────────────────────────────────────────────────────────────

export type StructurizeStatus = "idle" | "loading" | "success" | "error";

export interface AppState {
  inputText: string;
  soapResult: SoapResult | null;
  status: StructurizeStatus;
  error: string | null;
  processingTime: number | null;
}

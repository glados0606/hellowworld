"use client";

import { useReducer, useCallback, useEffect } from "react";
import TextInput from "@/components/Editor/TextInput";
import SoapOutput from "@/components/Editor/SoapOutput";
import SampleSelector from "@/components/Demo/SampleSelector";
import Button from "@/components/Common/Button";
import Toast from "@/components/Common/Toast";
import type {
  AppState,
  SoapResult,
  SoapSectionType,
  StructurizeResponse,
} from "@/lib/types";

// ─── 상태 관리 ────────────────────────────────────────────────────────────────

type Action =
  | { type: "SET_INPUT"; payload: string }
  | { type: "STRUCTURIZE_START" }
  | { type: "STRUCTURIZE_SUCCESS"; payload: { result: SoapResult; processingTime: number } }
  | { type: "STRUCTURIZE_ERROR"; payload: string }
  | { type: "UPDATE_SECTION"; payload: { section: SoapSectionType; items: string[] } }
  | { type: "CLEAR" };

const INITIAL_STATE: AppState = {
  inputText: "",
  soapResult: null,
  status: "idle",
  error: null,
  processingTime: null,
};

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "SET_INPUT":
      return { ...state, inputText: action.payload };
    case "STRUCTURIZE_START":
      return { ...state, status: "loading", error: null, soapResult: null, processingTime: null };
    case "STRUCTURIZE_SUCCESS":
      return {
        ...state,
        status: "success",
        soapResult: action.payload.result,
        processingTime: action.payload.processingTime,
        error: null,
      };
    case "STRUCTURIZE_ERROR":
      return { ...state, status: "error", error: action.payload };
    case "UPDATE_SECTION":
      if (!state.soapResult) return state;
      return {
        ...state,
        soapResult: { ...state.soapResult, [action.payload.section]: action.payload.items },
      };
    case "CLEAR":
      return INITIAL_STATE;
    default:
      return state;
  }
}

// ─── 복사 포맷터 ──────────────────────────────────────────────────────────────

function formatSoapForClipboard(result: SoapResult): string {
  const formatSection = (label: string, items: string[]) => {
    if (items.length === 0) return "";
    return `[${label}]\n${items.map((item) => `• ${item}`).join("\n")}`;
  };

  return [
    formatSection("Subjective",   result.subjective),
    formatSection("Objective",    result.objective),
    formatSection("Assessment",   result.assessment),
    formatSection("Plan",         result.plan),
    formatSection("Unclassified", result.unclassified),
  ]
    .filter(Boolean)
    .join("\n\n");
}

// ─── 토스트 상태 ──────────────────────────────────────────────────────────────

type ToastState = {
  message: string;
  type: "success" | "error" | "info" | "warning";
  key: number;
} | null;

// ─── 메인 페이지 ─────────────────────────────────────────────────────────────

export default function Home() {
  const [state, dispatch] = useReducer(reducer, INITIAL_STATE);
  const [toast, setToast] = useReducerToast();

  const { inputText, soapResult, status, error, processingTime } = state;
  const loading = status === "loading";

  // ── AI 구조화 ─────────────────────────────────────────────────
  const handleStructurize = useCallback(async () => {
    const text = inputText.trim();

    if (!text) {
      setToast("진료 기록을 먼저 입력해주세요.", "info");
      return;
    }
    if (text.length > 10_000) {
      setToast("텍스트가 너무 깁니다. 10,000자 이내로 줄여주세요.", "warning");
      return;
    }

    dispatch({ type: "STRUCTURIZE_START" });

    try {
      const res = await fetch("/api/structurize", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text }),
      });

      const data: StructurizeResponse = await res.json();

      if (data.success && data.data) {
        dispatch({
          type: "STRUCTURIZE_SUCCESS",
          payload: {
            result: data.data,
            processingTime: data.processingTime ?? 0,
          },
        });
        setToast(
          `구조화 완료! ${((data.processingTime ?? 0) / 1000).toFixed(1)}초 소요`,
          "success"
        );
      } else {
        const msg = data.error ?? "구조화에 실패했습니다.";
        dispatch({ type: "STRUCTURIZE_ERROR", payload: msg });
        setToast(msg, "error");
      }
    } catch (err) {
      console.error("[SnapSOAP] 네트워크 오류:", err);
      const msg = "네트워크 오류가 발생했습니다. 연결을 확인해주세요.";
      dispatch({ type: "STRUCTURIZE_ERROR", payload: msg });
      setToast(msg, "error");
    }
  }, [inputText, setToast]);

  // ── SOAP 섹션 편집 ────────────────────────────────────────────
  const handleUpdateSection = useCallback(
    (section: SoapSectionType, items: string[]) => {
      dispatch({ type: "UPDATE_SECTION", payload: { section, items } });
    },
    []
  );

  // ── 결과 복사 ─────────────────────────────────────────────────
  const handleCopy = useCallback(() => {
    if (!soapResult) return;
    navigator.clipboard
      .writeText(formatSoapForClipboard(soapResult))
      .then(() => setToast("클립보드에 복사되었습니다.", "success"))
      .catch(() => setToast("복사에 실패했습니다. 브라우저 권한을 확인하세요.", "error"));
  }, [soapResult, setToast]);

  // ── 샘플 선택 ─────────────────────────────────────────────────
  const handleSelectSample = useCallback((text: string) => {
    dispatch({ type: "SET_INPUT", payload: text });
    dispatch({ type: "CLEAR" });
    dispatch({ type: "SET_INPUT", payload: text });
  }, []);

  // ── 전체 초기화 ───────────────────────────────────────────────
  const handleClear = useCallback(() => {
    dispatch({ type: "CLEAR" });
  }, []);

  // ── Ctrl+Enter 단축키 ─────────────────────────────────────────
  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
        e.preventDefault();
        handleStructurize();
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [handleStructurize]);

  const canStructurize = inputText.trim().length > 0 && !loading;
  const canClear = (inputText.length > 0 || soapResult !== null) && !loading;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">

      {/* ── 컨트롤 바 ────────────────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-4">
        <SampleSelector onSelect={handleSelectSample} disabled={loading} />

        <div className="flex items-center gap-2 shrink-0">
          <Button
            onClick={handleClear}
            variant="ghost"
            size="sm"
            disabled={!canClear}
            title="입력과 결과를 모두 초기화합니다"
          >
            초기화
          </Button>
          <Button
            onClick={handleStructurize}
            variant="primary"
            size="md"
            loading={loading}
            disabled={!canStructurize}
            title="Ctrl+Enter"
          >
            {loading ? "분석 중..." : "✨ 구조화"}
          </Button>
        </div>
      </div>

      {/* ── Split-View 에디터 ─────────────────────────────────────── */}
      <div
        className="grid grid-cols-1 lg:grid-cols-2 gap-4"
        style={{ minHeight: "calc(100vh - 200px)" }}
      >
        {/* 좌측: 자유텍스트 입력 */}
        <div className="flex flex-col bg-white rounded-xl border border-gray-200 p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3 shrink-0">
            <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
              입력
            </h2>
            <span className="text-xs text-gray-400">
              <kbd className="px-1.5 py-0.5 bg-gray-100 border border-gray-300 rounded font-mono text-xs">Ctrl</kbd>
              {" + "}
              <kbd className="px-1.5 py-0.5 bg-gray-100 border border-gray-300 rounded font-mono text-xs">Enter</kbd>
              {" 로 구조화"}
            </span>
          </div>
          <div className="flex-1">
            <TextInput
              value={inputText}
              onChange={(v) => dispatch({ type: "SET_INPUT", payload: v })}
              disabled={loading}
            />
          </div>
        </div>

        {/* 우측: SOAP 결과 */}
        <div className="flex flex-col bg-white rounded-xl border border-gray-200 p-5 shadow-sm overflow-y-auto">
          <div className="flex items-center justify-between mb-3 shrink-0">
            <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-wide">
              결과
            </h2>
            <span className="text-xs text-gray-400">SOAP 구조화</span>
          </div>
          <SoapOutput
            result={soapResult}
            loading={loading}
            error={error}
            processingTime={processingTime}
            onUpdate={handleUpdateSection}
            onCopy={handleCopy}
            onRetry={handleStructurize}
          />
        </div>
      </div>

      {/* ── 하단 안내 ────────────────────────────────────────────── */}
      <p className="mt-4 text-center text-xs text-gray-400">
        SnapSOAP는 프로토타입입니다. 실제 환자 정보를 입력하지 마세요.
        AI 분류 결과는 반드시 의료진이 검토해야 합니다.
      </p>

      {/* ── Toast 알림 ───────────────────────────────────────────── */}
      {toast && (
        <Toast
          key={toast.key}
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}

// ─── 토스트 헬퍼 훅 ──────────────────────────────────────────────────────────

function useReducerToast() {
  const [toast, setRaw] = useReducer(
    (_: ToastState, action: { message: string; type: ToastState["type"] } | null) =>
      action === null
        ? null
        : { message: action.message, type: action.type!, key: Date.now() },
    null as ToastState
  );

  const setToast = useCallback(
    (message: string | null, type?: ToastState["type"]) => {
      setRaw(message === null ? null : { message, type: type! });
    },
    []
  );

  return [toast, setToast] as const;
}

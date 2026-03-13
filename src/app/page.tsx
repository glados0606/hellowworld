"use client";

import { useState, useCallback, useEffect, useRef } from "react";
import TextInput from "@/components/Editor/TextInput";
import SoapOutput from "@/components/Editor/SoapOutput";
import SampleSelector from "@/components/Demo/SampleSelector";
import Button from "@/components/Common/Button";
import Toast from "@/components/Common/Toast";
import type { SoapResult, SoapSectionType, StructurizeResponse } from "@/lib/types";

// ─── 타입 ────────────────────────────────────────────────────────────────────

interface ToastState {
  message: string;
  type: "success" | "error" | "info" | "warning";
}

// ─── 복사 포맷터 ──────────────────────────────────────────────────────────────

function formatSoapForClipboard(result: SoapResult): string {
  const formatSection = (label: string, items: string[]) => {
    if (items.length === 0) return "";
    return `[${label}]\n${items.map((item) => `• ${item}`).join("\n")}`;
  };

  return [
    formatSection("Subjective",    result.subjective),
    formatSection("Objective",     result.objective),
    formatSection("Assessment",    result.assessment),
    formatSection("Plan",          result.plan),
    formatSection("Unclassified",  result.unclassified),
  ]
    .filter(Boolean)
    .join("\n\n");
}

// ─── 메인 페이지 ─────────────────────────────────────────────────────────────

export default function Home() {
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  // 상태
  const [inputText, setInputText]           = useState("");
  const [soapResult, setSoapResult]         = useState<SoapResult | null>(null);
  const [loading, setLoading]               = useState(false);
  const [error, setError]                   = useState<string | null>(null);
  const [processingTime, setProcessingTime] = useState<number | null>(null);
  const [toast, setToast]                   = useState<ToastState | null>(null);

  const showToast = useCallback((message: string, type: ToastState["type"]) => {
    setToast({ message, type });
  }, []);

  // ── AI 구조화 ────────────────────────────────────────────────
  const handleStructurize = useCallback(async () => {
    if (!inputText.trim()) {
      showToast("진료 기록을 먼저 입력해주세요.", "info");
      return;
    }
    if (inputText.length > 10_000) {
      showToast("텍스트가 너무 깁니다. 10,000자 이내로 줄여주세요.", "warning");
      return;
    }

    setLoading(true);
    setError(null);
    setSoapResult(null);
    setProcessingTime(null);

    try {
      const res = await fetch("/api/structurize", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text: inputText }),
      });

      const data: StructurizeResponse = await res.json();

      if (data.success && data.data) {
        setSoapResult(data.data);
        setProcessingTime(data.processingTime ?? null);
        showToast(
          `구조화 완료! ${(data.processingTime! / 1000).toFixed(1)}초 소요`,
          "success"
        );
      } else {
        const msg = data.error ?? "구조화에 실패했습니다.";
        setError(msg);
        showToast(msg, "error");
      }
    } catch (err) {
      console.error("[SnapSOAP] fetch 오류:", err);
      const msg = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.";
      setError(msg);
      showToast(msg, "error");
    } finally {
      setLoading(false);
    }
  }, [inputText, showToast]);

  // ── SOAP 섹션 편집 ───────────────────────────────────────────
  const handleUpdateSection = useCallback(
    (type: SoapSectionType, items: string[]) => {
      setSoapResult((prev) => (prev ? { ...prev, [type]: items } : prev));
    },
    []
  );

  // ── 결과 복사 ────────────────────────────────────────────────
  const handleCopy = useCallback(() => {
    if (!soapResult) return;
    const text = formatSoapForClipboard(soapResult);
    navigator.clipboard
      .writeText(text)
      .then(() => showToast("클립보드에 복사되었습니다.", "success"))
      .catch(() => showToast("복사에 실패했습니다. 브라우저 권한을 확인하세요.", "error"));
  }, [soapResult, showToast]);

  // ── 샘플 선택 ────────────────────────────────────────────────
  const handleSelectSample = useCallback((text: string) => {
    setInputText(text);
    setSoapResult(null);
    setError(null);
    setProcessingTime(null);
  }, []);

  // ── 전체 초기화 ──────────────────────────────────────────────
  const handleClear = useCallback(() => {
    setInputText("");
    setSoapResult(null);
    setError(null);
    setProcessingTime(null);
  }, []);

  // ── 키보드 단축키: Ctrl+Enter / Cmd+Enter ────────────────────
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
        e.preventDefault();
        handleStructurize();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleStructurize]);

  const canStructurize = inputText.trim().length > 0 && !loading;
  const canClear = (inputText.length > 0 || soapResult !== null) && !loading;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-5">

      {/* ── 상단 컨트롤 바 ──────────────────────────────────────── */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
        {/* 샘플 선택기 */}
        <SampleSelector onSelect={handleSelectSample} disabled={loading} />

        {/* 액션 버튼 */}
        <div className="flex items-center gap-2 shrink-0">
          <Button
            onClick={handleClear}
            variant="ghost"
            size="sm"
            disabled={!canClear}
            title="입력과 결과를 모두 지웁니다"
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
            {loading ? "분석 중..." : "구조화"}
          </Button>
        </div>
      </div>

      {/* ── Split-View 에디터 ────────────────────────────────────── */}
      <div
        className="grid grid-cols-1 lg:grid-cols-2 gap-4"
        style={{ minHeight: "calc(100vh - 220px)" }}
      >
        {/* 좌측: 자유텍스트 입력 */}
        <div className="bg-white rounded-xl border border-gray-200 p-5 shadow-sm flex flex-col">
          <TextInput
            value={inputText}
            onChange={setInputText}
            disabled={loading}
          />

          {/* 단축키 안내 */}
          <p className="mt-2 text-xs text-gray-400 text-right">
            <kbd className="px-1.5 py-0.5 bg-gray-100 border border-gray-300 rounded text-xs font-mono">
              Ctrl
            </kbd>
            {" + "}
            <kbd className="px-1.5 py-0.5 bg-gray-100 border border-gray-300 rounded text-xs font-mono">
              Enter
            </kbd>
            {" 로 바로 구조화"}
          </p>
        </div>

        {/* 우측: SOAP 결과 */}
        <div className="bg-white rounded-xl border border-gray-200 p-5 shadow-sm overflow-y-auto">
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
      <p className="mt-4 text-xs text-center text-gray-400">
        이 도구는 프로토타입입니다. AI 분류 결과는 반드시 의료진이 검토해야 합니다.
        실제 환자 정보를 입력하지 마세요.
      </p>

      {/* ── Toast 알림 ───────────────────────────────────────────── */}
      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}

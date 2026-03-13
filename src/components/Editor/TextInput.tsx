"use client";

const PLACEHOLDER = `진료 기록을 자유롭게 입력하세요. 형식 제약 없습니다.

예시:
55세 남성 환자. HTN, DM type 2로 f/u 중.
오늘 특별한 불편감 없이 정기 방문함.
BP 138/88 mmHg, HR 76 bpm, BT 36.5°C.
HbA1c 7.2%. Metformin 1000mg bid 유지.
3개월 후 f/u.`;

interface TextInputProps {
  value: string;
  onChange: (value: string) => void;
  disabled?: boolean;
}

export default function TextInput({ value, onChange, disabled }: TextInputProps) {
  const MAX = 10_000;
  const len = value.length;
  const nearLimit = len > MAX * 0.85;
  const overLimit = len > MAX;

  return (
    <div className="flex flex-col h-full gap-2">
      {/* 레이블 + 글자 수 */}
      <div className="flex items-center justify-between">
        <label
          htmlFor="clinical-note"
          className="text-sm font-medium text-gray-700"
        >
          자유텍스트 진료 기록
        </label>
        <span
          className={`text-xs tabular-nums transition-colors ${
            overLimit
              ? "text-red-600 font-semibold"
              : nearLimit
              ? "text-amber-600"
              : "text-gray-400"
          }`}
        >
          {len.toLocaleString()} / {MAX.toLocaleString()}자
        </span>
      </div>

      {/* 텍스트 영역 */}
      <textarea
        id="clinical-note"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        disabled={disabled}
        placeholder={PLACEHOLDER}
        spellCheck={false}
        aria-label="진료 기록 입력"
        className={`
          editor-textarea flex-1 w-full p-4
          border rounded-lg text-sm text-gray-900 leading-relaxed
          placeholder:text-gray-400 placeholder:text-xs placeholder:leading-relaxed
          transition-colors bg-white
          disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
          ${
            overLimit
              ? "border-red-400 focus:border-red-400"
              : "border-gray-200 focus:border-violet-400"
          }
        `}
        style={{ minHeight: "420px" }}
      />

      {/* 초과 경고 */}
      {overLimit && (
        <p className="text-xs text-red-600">
          10,000자를 초과했습니다. 일부를 삭제해주세요.
        </p>
      )}
    </div>
  );
}

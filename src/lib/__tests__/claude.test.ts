import { describe, it, expect } from "vitest";
import { cleanJsonResponse, normalizeResult } from "../claude";

// ─────────────────────────────────────────────
// cleanJsonResponse: JSON 정제 로직
// ─────────────────────────────────────────────
describe("cleanJsonResponse", () => {
  it("마크다운 코드블록(```json ... ```)을 제거한다", () => {
    const input = "```json\n{\"subjective\":[\"기침\"]}\n```";
    const result = cleanJsonResponse(input);
    expect(result).toBe("{\"subjective\":[\"기침\"]}");
  });

  it("일반 코드블록(``` ... ```)을 제거한다", () => {
    const input = "```\n{\"plan\":[\"처방\"]}\n```";
    expect(cleanJsonResponse(input)).toBe("{\"plan\":[\"처방\"]}");
  });

  it("앞뒤 공백과 개행을 제거한다", () => {
    const input = "  {\"objective\":[]}  \n";
    expect(cleanJsonResponse(input)).toBe("{\"objective\":[]}");
  });

  it("코드블록이 없는 순수 JSON은 그대로 반환한다", () => {
    const raw = "{\"assessment\":[\"편도염\"]}";
    expect(cleanJsonResponse(raw)).toBe(raw);
  });

  it("빈 문자열 입력 시 크래시 없이 빈 문자열 반환한다", () => {
    expect(cleanJsonResponse("")).toBe("");
  });

  it("대소문자 혼합된 ```JSON ... ``` 제거한다", () => {
    const input = "```JSON\n{\"unclassified\":[]}\n```";
    expect(cleanJsonResponse(input)).toBe("{\"unclassified\":[]}");
  });
});

// ─────────────────────────────────────────────
// normalizeResult: 필수 키 보정 로직
// ─────────────────────────────────────────────
describe("normalizeResult", () => {
  it("완전한 SOAP 객체는 그대로 반환한다", () => {
    const input = {
      subjective: ["기침 3일"],
      objective: ["BP 120/80"],
      assessment: ["편도염"],
      plan: ["Augmentin 처방"],
      unclassified: [],
    };
    const result = normalizeResult(input);
    expect(result.subjective).toEqual(["기침 3일"]);
    expect(result.objective).toEqual(["BP 120/80"]);
    expect(result.unclassified).toEqual([]);
  });

  it("누락된 키는 빈 배열로 보정한다", () => {
    const result = normalizeResult({ subjective: ["기침"] });
    expect(result.objective).toEqual([]);
    expect(result.assessment).toEqual([]);
    expect(result.plan).toEqual([]);
    expect(result.unclassified).toEqual([]);
  });

  it("null 값인 키는 빈 배열로 보정한다", () => {
    const result = normalizeResult({ subjective: null, objective: ["BP 130"] });
    expect(result.subjective).toEqual([]);
    expect(result.objective).toEqual(["BP 130"]);
  });

  it("문자열 값인 키는 빈 배열로 보정한다 (AI 오응답 방어)", () => {
    // AI가 배열 대신 문자열로 응답할 경우 → 빈 배열로 보정
    const result = normalizeResult({ plan: "Augmentin 처방" } as Record<string, unknown>);
    expect(Array.isArray(result.plan)).toBe(true);
    expect(result.plan).toEqual([]);
  });

  it("빈 객체 입력 시 5개 키 모두 빈 배열로 보정한다", () => {
    const result = normalizeResult({});
    expect(result.subjective).toEqual([]);
    expect(result.objective).toEqual([]);
    expect(result.assessment).toEqual([]);
    expect(result.plan).toEqual([]);
    expect(result.unclassified).toEqual([]);
  });

  it("원본 배열 값을 변경하지 않는다 (불변성)", () => {
    const items = ["f/u 1주 후"];
    const result = normalizeResult({ plan: items });
    expect(result.plan).toBe(items); // 동일 참조
  });
});

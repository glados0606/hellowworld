import { describe, it, expect } from "vitest";
import { createUserPrompt, SOAP_SYSTEM_PROMPT } from "../prompts";

describe("createUserPrompt", () => {
  it("입력 텍스트를 포함한 프롬프트를 반환한다", () => {
    const input = "38.2 기침 3일, BP 120/80";
    const result = createUserPrompt(input);

    expect(result).toContain(input);
    expect(result).toContain("SOAP 형식으로 구조화");
    expect(result).toContain("JSON으로만 응답");
  });

  it("앞뒤 공백을 제거한다", () => {
    const input = "  기침 3일  ";
    const result = createUserPrompt(input);

    expect(result).toContain("기침 3일");
    expect(result).not.toContain("  기침 3일  ");
  });

  it("빈 문자열을 입력해도 크래시하지 않는다", () => {
    expect(() => createUserPrompt("")).not.toThrow();
  });

  it("구분선(---)을 포함한다", () => {
    const result = createUserPrompt("테스트");
    expect(result).toContain("---");
  });
});

describe("SOAP_SYSTEM_PROMPT", () => {
  it("문자열 타입이다", () => {
    expect(typeof SOAP_SYSTEM_PROMPT).toBe("string");
  });

  it("SOAP 4개 섹션 기준이 모두 포함되어 있다", () => {
    expect(SOAP_SYSTEM_PROMPT).toContain("Subjective");
    expect(SOAP_SYSTEM_PROMPT).toContain("Objective");
    expect(SOAP_SYSTEM_PROMPT).toContain("Assessment");
    expect(SOAP_SYSTEM_PROMPT).toContain("Plan");
  });

  it("한국 의료 약어 처리 지침이 포함되어 있다", () => {
    expect(SOAP_SYSTEM_PROMPT).toContain("HTN");
    expect(SOAP_SYSTEM_PROMPT).toContain("BP");
    expect(SOAP_SYSTEM_PROMPT).toContain("r/o");
  });

  it("JSON 출력 형식 지침이 포함되어 있다", () => {
    expect(SOAP_SYSTEM_PROMPT).toContain("subjective");
    expect(SOAP_SYSTEM_PROMPT).toContain("objective");
    expect(SOAP_SYSTEM_PROMPT).toContain("assessment");
    expect(SOAP_SYSTEM_PROMPT).toContain("plan");
    expect(SOAP_SYSTEM_PROMPT).toContain("unclassified");
  });

  it("원문 보존 원칙이 명시되어 있다", () => {
    expect(SOAP_SYSTEM_PROMPT).toContain("원문 보존");
  });
});

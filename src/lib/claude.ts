import Groq from "groq-sdk";
import { SOAP_SYSTEM_PROMPT, createUserPrompt } from "./prompts";
import type { SoapResult } from "./types";

const API_TIMEOUT_MS = 10_000; // 10초

/**
 * JSON 응답에서 마크다운 코드블록 제거 후 trim
 * @internal 유닛 테스트 대상 순수 함수
 */
export function cleanJsonResponse(text: string): string {
  return text
    .replace(/```json\s*/gi, "")
    .replace(/```\s*/g, "")
    .trim();
}

/**
 * 파싱된 객체에서 필수 SOAP 키 누락 시 빈 배열로 보정
 * @internal 유닛 테스트 대상 순수 함수
 */
export function normalizeResult(parsed: Record<string, unknown>): SoapResult {
  const requiredKeys: (keyof SoapResult)[] = [
    "subjective",
    "objective",
    "assessment",
    "plan",
    "unclassified",
  ];
  const result = { ...parsed } as unknown as SoapResult;
  for (const key of requiredKeys) {
    if (!Array.isArray(result[key])) {
      result[key] = [];
    }
  }
  return result;
}

/**
 * 자유텍스트 진료 기록을 SOAP 구조로 변환한다.
 * Groq SDK (llama-3.3-70b-versatile) 사용.
 * API 응답 10초 초과 시 자동 타임아웃 처리.
 *
 * @throws {Error} API 호출 실패, 타임아웃, 파싱 실패 시
 */
export async function structurizeToSoap(text: string): Promise<SoapResult> {
  const startTime = Date.now();

  const client = new Groq({
    apiKey: process.env.GROQ_API_KEY,
    timeout: API_TIMEOUT_MS,
  });

  let completion;
  try {
    completion = await client.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      messages: [
        { role: "system", content: SOAP_SYSTEM_PROMPT },
        { role: "user", content: createUserPrompt(text) },
      ],
      response_format: { type: "json_object" },
      temperature: 0.1,
      max_tokens: 2048,
    });
  } catch (error) {
    const isTimeout =
      error instanceof Error &&
      (error.message.includes("timeout") ||
        error.message.includes("timed out") ||
        error.name === "APIConnectionTimeoutError");
    if (isTimeout) {
      throw new Error(
        "AI 응답 시간이 초과되었습니다. (10초) 잠시 후 다시 시도해주세요."
      );
    }
    throw error;
  }

  const responseText: string = completion.choices[0]?.message?.content || "";

  if (!responseText) {
    throw new Error("AI 응답이 비어있습니다.");
  }

  // 마크다운 코드블록 제거 후 JSON 파싱
  const cleaned = cleanJsonResponse(responseText);

  let parsed: SoapResult;
  try {
    parsed = normalizeResult(JSON.parse(cleaned));
  } catch {
    console.error("[SnapSOAP] JSON 파싱 실패. 원본 응답:", responseText);
    throw new Error("AI 응답을 파싱할 수 없습니다. 원본 텍스트를 확인하세요.");
  }

  const elapsed = Date.now() - startTime;
  console.log(`[SnapSOAP] 구조화 완료: ${elapsed}ms`);

  return parsed;
}

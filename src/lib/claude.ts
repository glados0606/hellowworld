import { GoogleGenerativeAI } from "@google/generative-ai";
import { SOAP_SYSTEM_PROMPT, createUserPrompt } from "./prompts";
import type { SoapResult } from "./types";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

const TIMEOUT_MS = 10_000;

/**
 * 자유텍스트 진료 기록을 SOAP 구조로 변환한다.
 * Gemini API (gemini-2.0-flash) 사용.
 *
 * @throws {Error} API 호출 실패, 파싱 실패, 타임아웃 시
 */
export async function structurizeToSoap(text: string): Promise<SoapResult> {
  const startTime = Date.now();

  const model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash",
    systemInstruction: SOAP_SYSTEM_PROMPT,
    generationConfig: {
      temperature: 0.1,
      responseMimeType: "application/json",
    },
  });

  const timeoutPromise = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error("API 응답 시간 초과 (10초)")), TIMEOUT_MS)
  );

  const apiPromise = model.generateContent(createUserPrompt(text));
  const result = await Promise.race([apiPromise, timeoutPromise]);

  const responseText = result.response.text();

  if (!responseText) {
    throw new Error("AI 응답이 비어있습니다.");
  }

  // 마크다운 코드블록 제거 후 JSON 파싱
  const cleaned = responseText
    .replace(/```json\s*/gi, "")
    .replace(/```\s*/g, "")
    .trim();

  let parsed: SoapResult;
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    console.error("[SnapSOAP] JSON 파싱 실패. 원본 응답:", responseText);
    throw new Error("AI 응답을 파싱할 수 없습니다. 원본 텍스트를 확인하세요.");
  }

  // 필수 키 유효성 검증 — 누락된 키는 빈 배열로 보정
  const requiredKeys: (keyof SoapResult)[] = [
    "subjective",
    "objective",
    "assessment",
    "plan",
    "unclassified",
  ];
  for (const key of requiredKeys) {
    if (!Array.isArray(parsed[key])) {
      parsed[key] = [];
    }
  }

  const elapsed = Date.now() - startTime;
  console.log(`[SnapSOAP] 구조화 완료: ${elapsed}ms`);

  return parsed;
}

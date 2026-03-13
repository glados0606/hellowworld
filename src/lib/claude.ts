import Groq from "groq-sdk";
import { SOAP_SYSTEM_PROMPT, createUserPrompt } from "./prompts";
import type { SoapResult } from "./types";

/**
 * 자유텍스트 진료 기록을 SOAP 구조로 변환한다.
 * Groq SDK (llama-3.3-70b-versatile) 사용.
 *
 * @throws {Error} API 호출 실패, 파싱 실패 시
 */
export async function structurizeToSoap(text: string): Promise<SoapResult> {
  const startTime = Date.now();

  const client = new Groq({ apiKey: process.env.GROQ_API_KEY });

  const completion = await client.chat.completions.create({
    model: "llama-3.3-70b-versatile",
    messages: [
      { role: "system", content: SOAP_SYSTEM_PROMPT },
      { role: "user", content: createUserPrompt(text) },
    ],
    response_format: { type: "json_object" },
    temperature: 0.1,
    max_tokens: 2048,
  });

  const responseText: string = completion.choices[0]?.message?.content || "";

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

import { NextRequest, NextResponse } from "next/server";
import { structurizeToSoap } from "@/lib/claude";
import type { StructurizeResponse } from "@/lib/types";

export async function POST(request: NextRequest) {
  const startTime = Date.now();

  try {
    const body = await request.json();
    const { text } = body;

    // ── 입력 유효성 검사 ────────────────────────────────────────
    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "진료 기록 텍스트를 입력해주세요." },
        { status: 400 }
      );
    }

    if (text.trim().length < 5) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "텍스트가 너무 짧습니다. 진료 기록을 더 입력해주세요." },
        { status: 400 }
      );
    }

    if (text.length > 10_000) {
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "텍스트가 너무 깁니다. 10,000자 이내로 입력해주세요." },
        { status: 400 }
      );
    }

    // ── API 키 확인 ──────────────────────────────────────────────
    if (!process.env.GROQ_API_KEY) {
      console.error("[SnapSOAP] GROQ_API_KEY 환경 변수 미설정");
      return NextResponse.json<StructurizeResponse>(
        { success: false, error: "서버 설정 오류입니다. .env.local의 GROQ_API_KEY를 확인하세요." },
        { status: 500 }
      );
    }

    // ── AI 구조화 실행 ───────────────────────────────────────────
    console.log(`[SnapSOAP] 구조화 요청 (${text.length}자)`);
    const result = await structurizeToSoap(text);
    const processingTime = Date.now() - startTime;

    const totalItems =
      result.subjective.length +
      result.objective.length +
      result.assessment.length +
      result.plan.length +
      result.unclassified.length;

    console.log(
      `[SnapSOAP] 완료 ${processingTime}ms | ` +
      `S:${result.subjective.length} O:${result.objective.length} ` +
      `A:${result.assessment.length} P:${result.plan.length} ` +
      `?:${result.unclassified.length} (총 ${totalItems}항목)`
    );

    return NextResponse.json<StructurizeResponse>({
      success: true,
      data: result,
      processingTime,
    });
  } catch (error) {
    const processingTime = Date.now() - startTime;
    const errorMessage =
      error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.";

    console.error("[SnapSOAP] API 오류:", errorMessage);

    return NextResponse.json<StructurizeResponse>(
      { success: false, error: errorMessage, processingTime },
      { status: 500 }
    );
  }
}

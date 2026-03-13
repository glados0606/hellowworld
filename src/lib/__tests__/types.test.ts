import { describe, it, expect } from "vitest";
import { SOAP_ORDER, SOAP_META, type SoapSectionType } from "../types";

describe("SOAP_ORDER", () => {
  it("5개 섹션이 정의되어 있다", () => {
    expect(SOAP_ORDER).toHaveLength(5);
  });

  it("SOAP + unclassified 순서로 정렬되어 있다", () => {
    expect(SOAP_ORDER[0]).toBe("subjective");
    expect(SOAP_ORDER[1]).toBe("objective");
    expect(SOAP_ORDER[2]).toBe("assessment");
    expect(SOAP_ORDER[3]).toBe("plan");
    expect(SOAP_ORDER[4]).toBe("unclassified");
  });

  it("중복 섹션이 없다", () => {
    const unique = new Set(SOAP_ORDER);
    expect(unique.size).toBe(SOAP_ORDER.length);
  });
});

describe("SOAP_META", () => {
  const sections: SoapSectionType[] = [
    "subjective",
    "objective",
    "assessment",
    "plan",
    "unclassified",
  ];

  it("모든 섹션에 대한 메타데이터가 있다", () => {
    sections.forEach((section) => {
      expect(SOAP_META[section]).toBeDefined();
    });
  });

  it("각 섹션 메타데이터에 필수 필드가 있다", () => {
    sections.forEach((section) => {
      const meta = SOAP_META[section];
      expect(meta.label).toBeTruthy();
      expect(meta.shortLabel).toBeTruthy();
      expect(meta.description).toBeTruthy();
      expect(meta.colorClass).toBeTruthy();
      expect(meta.badgeClass).toBeTruthy();
      expect(meta.textColorClass).toBeTruthy();
    });
  });

  it("shortLabel이 단일 문자 또는 '?'이다", () => {
    sections.forEach((section) => {
      const { shortLabel } = SOAP_META[section];
      expect(shortLabel.length).toBe(1);
    });
  });

  it("S/O/A/P/? shortLabel이 순서대로 맞다", () => {
    expect(SOAP_META.subjective.shortLabel).toBe("S");
    expect(SOAP_META.objective.shortLabel).toBe("O");
    expect(SOAP_META.assessment.shortLabel).toBe("A");
    expect(SOAP_META.plan.shortLabel).toBe("P");
    expect(SOAP_META.unclassified.shortLabel).toBe("?");
  });
});

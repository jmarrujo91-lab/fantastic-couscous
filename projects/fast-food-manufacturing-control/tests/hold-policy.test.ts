import { describe, expect, it } from "vitest";
import { evaluateHoldRequirement } from "../src/domain/hold-policy.js";

describe("evaluateHoldRequirement", () => {
  it("does not require a hold when every required check passes", () => {
    expect(evaluateHoldRequirement([
      { code: "TEMP", result: "PASS" },
      { code: "LABEL", result: "PASS" }
    ])).toEqual({ holdRequired: false, reasons: [] });
  });

  it("requires a hold when a required check fails", () => {
    const result = evaluateHoldRequirement([{ code: "TEMP", result: "FAIL" }]);
    expect(result.holdRequired).toBe(true);
    expect(result.reasons).toContain("Failed required check: TEMP");
  });

  it("treats missing evidence as unverified and requires a hold", () => {
    const result = evaluateHoldRequirement([{ code: "ALLERGEN" }]);
    expect(result.holdRequired).toBe(true);
    expect(result.reasons).toContain("Missing or unverified required check: ALLERGEN");
  });
});

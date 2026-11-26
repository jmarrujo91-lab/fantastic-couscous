export type CheckResult = "PASS" | "FAIL" | "NOT_APPLICABLE";

export interface RequiredCheck {
  code: string;
  result?: CheckResult;
}

export interface HoldDecision {
  holdRequired: boolean;
  reasons: string[];
}

/**
 * Conservative policy helper only. The caller must load the authoritative
 * SOP-defined required checks and persist a hold transactionally.
 * This function never releases product or changes a database record.
 */
export function evaluateHoldRequirement(checks: RequiredCheck[]): HoldDecision {
  const reasons = checks
    .filter((check) => check.result !== "PASS")
    .map((check) => check.result === "FAIL"
      ? `Failed required check: ${check.code}`
      : `Missing or unverified required check: ${check.code}`);

  return { holdRequired: reasons.length > 0, reasons };
}

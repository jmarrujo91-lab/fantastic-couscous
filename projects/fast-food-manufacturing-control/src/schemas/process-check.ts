import { z } from "zod";

export const ProcessCheckSchema = z.object({
  siteId: z.string().uuid(),
  workOrderId: z.string().uuid().optional(),
  productionRunId: z.string().uuid().optional(),
  checkCode: z.string().trim().min(1).max(80),
  observedValue: z.number().finite().optional(),
  unit: z.string().trim().min(1).max(24).optional(),
  result: z.enum(["PASS", "FAIL", "NOT_APPLICABLE"]),
  observedAt: z.iso.datetime({ offset: true }).optional(),
  instrumentId: z.string().trim().min(1).max(100).optional(),
  evidenceRef: z.string().trim().min(1).max(500).optional()
}).strict().superRefine((value, ctx) => {
  if (!value.workOrderId && !value.productionRunId) {
    ctx.addIssue({
      code: "custom",
      message: "A work order or production run is required",
      path: ["workOrderId"]
    });
  }
  if (value.result === "PASS" && value.observedValue === undefined && !value.evidenceRef) {
    ctx.addIssue({
      code: "custom",
      message: "A passing check requires an observed value or evidence reference",
      path: ["observedValue"]
    });
  }
});

export type ProcessCheckInput = z.infer<typeof ProcessCheckSchema>;

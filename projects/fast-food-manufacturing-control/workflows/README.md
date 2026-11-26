# Workflow catalog

These workflows are records and human-approved state transitions, not machine-control scripts.

| Workflow | Trigger | Required evidence | Stop condition |
|---|---|---|---|
| Production order | Approved schedule | product/recipe revision, site, quantity, materials | unapproved recipe or unavailable material |
| Receiving | Delivery arrival | supplier, lot, quantity, condition, applicable temperature record | damaged, unidentified, or out-of-spec goods |
| Inventory issue | Material requested | released internal lot, quantity, operator | quarantined, held, expired, or rejected lot |
| Food-safety check | SOP checkpoint | observation, units, time, instrument, operator | failed/missing check or uncalibrated instrument |
| Quality inspection | In-process/final sample | sampling plan, result, evidence | failed specification or traceability gap |
| Nonconformance | Deviation detected | defect, affected lots, containment | product remains on hold pending disposition |
| Maintenance | Equipment fault | asset, fault, isolation/LOTO evidence, repair, verification | equipment not verified safe for use |
| Workforce authorization | Shift assignment | role-specific training current | training expired or authorization absent |
| Changeover/SMED | Product/line change | sanitation/changeover checklist, line clearance | incomplete sanitation or line clearance |
| Corrective action | Repeat/serious deviation | root cause, owner, due date, effectiveness check | effectiveness not verified |

## Mandatory rules
- Failed critical check creates or links an open hold for affected product.
- Default policy requires independent review before a hold is closed.
- Only qualified, authorized quality/food-safety personnel can disposition held product.
- Disposition requires reason, evidence, actor, timestamp, and affected-product scope.
- RELEASE is a recorded human decision, never a side effect of a successful workflow run.
- Unknown, stale, or missing evidence is not verified.

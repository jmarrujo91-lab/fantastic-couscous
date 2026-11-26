# Validation and acceptance plan

## Schema and migration
- Apply migration to isolated PostgreSQL 15+ database.
- Verify foreign keys, uniqueness, checks, indexes, and rollback.
- Verify audit role cannot UPDATE, DELETE, or TRUNCATE audit rows.
- Verify application cannot cross site boundaries through supplied IDs.

## Workflow tests
- Work order with approved recipe can enter READY; draft/retired recipe cannot.
- Quarantined, held, rejected, or depleted material cannot be consumed.
- Failed or missing required process check opens/retains a hold.
- Operator and production supervisor cannot release held product.
- Quality disposition requires authorized role, reason, evidence, and independent review per site policy.
- Work order cannot be marked shippable while any linked hold is open.
- Duplicate event delivery is idempotent by event ID/correlation key.

## Security tests
- Authentication required for every non-health endpoint; MFA for privileged roles.
- Test RBAC for operator, supervisor, quality, food-safety, inventory, maintenance, auditor, administrator.
- Test tenant/site isolation at query and service layers.
- Secrets loaded from a secret manager; .env is local-only and never committed.
- Sensitive values use KMS-managed envelope encryption; keys are not stored in the database.
- Audit payloads exclude passwords, tokens, payment data, and unnecessary personal data.

## Food-safety validation
- Site/product SOP owners approve limits and check frequency before configuration.
- Verify calibrated instruments and record instrument identifiers.
- Simulate out-of-limit, missing-check, expired-instrument, and traceability-gap scenarios.
- Verify affected product is contained and no automatic release path exists.
- Validate sanitation, allergen changeover, labeling, lot genealogy, and recall trace exercises.

## Operational readiness
- Backup restore and disaster-recovery exercise.
- Monitoring for failed checks, open holds, overdue corrective actions, and audit export failures.
- User acceptance testing with trained staff.
- Signed site approval and controlled SOP revision before production use.

Exit criteria: all critical tests pass, no open critical/high security findings remain, food-safety owner signs validation, and deployment approval is separately documented. This repository is not evidence of production validation.

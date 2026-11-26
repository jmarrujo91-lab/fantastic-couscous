# Manufacturing Control Architecture

## Scope
Development scaffold for a multi-site quick-service food manufacturing operation. Records work orders, lots, process checks, quality decisions, holds, and corrective actions. It does not control machinery, release held product, or make regulatory determinations.

## Logical flow
1. Approved production plan creates a work order.
2. Planning validates product, recipe revision, site, line, shift, and materials.
3. Receiving and inventory record supplier lot, internal lot, quantity, and status.
4. Production records material consumption and process observations.
5. Food-safety and quality checks record operator, time, instrument, units, and evidence.
6. Any failed or missing required check places affected lot/work order on HOLD.
7. Authorized quality personnel review evidence and record disposition. No automatic product release.
8. Shipment is permitted only after a separately authorized release decision and all required checks pass.

## Boundaries
- Site scope comes from authenticated server identity, never request-body site IDs.
- Roles: operator, supervisor, quality, food-safety lead, inventory, maintenance, auditor, administrator.
- Quality disposition is separate from production execution.
- Audit events are append-only; corrections are compensating events.
- Critical limits are approved for each product/site/process by qualified personnel. No universal values are hard-coded.
- POS, payments, payroll, supplier writes, and equipment-control integrations are out of scope.

## Production gates
Identity provider and MFA; tested RBAC/site isolation; KMS encryption; immutable audit export; backup/restore; monitoring; validated SOPs and approved critical limits; instrument calibration; staff training; site acceptance testing.

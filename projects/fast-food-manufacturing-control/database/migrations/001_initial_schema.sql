-- Development schema. PostgreSQL 15+. Apply only to a disposable development database.
BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE sites (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 code text NOT NULL UNIQUE,
 name text NOT NULL,
 timezone text NOT NULL DEFAULT 'UTC',
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE products (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 sku text NOT NULL UNIQUE,
 name text NOT NULL,
 active boolean NOT NULL DEFAULT true,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE recipe_revisions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 product_id uuid NOT NULL REFERENCES products(id),
 revision text NOT NULL,
 approval_status text NOT NULL CHECK (approval_status IN ('DRAFT','APPROVED','RETIRED')),
 effective_from timestamptz,
 approved_by text,
 approved_at timestamptz,
 UNIQUE(product_id, revision),
 CHECK (approval_status <> 'APPROVED' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL))
);
CREATE TABLE work_orders (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 site_id uuid NOT NULL REFERENCES sites(id),
 product_id uuid NOT NULL REFERENCES products(id),
 recipe_revision_id uuid NOT NULL REFERENCES recipe_revisions(id),
 order_number text NOT NULL,
 planned_quantity numeric(14,3) NOT NULL CHECK (planned_quantity > 0),
 unit text NOT NULL,
 status text NOT NULL DEFAULT 'PLANNED'
   CHECK (status IN ('PLANNED','READY','IN_PROGRESS','COMPLETED','CANCELED','ON_HOLD')),
 planned_start timestamptz,
 created_by text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(site_id, order_number)
);
CREATE TABLE material_lots (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 site_id uuid NOT NULL REFERENCES sites(id),
 material_sku text NOT NULL,
 supplier_lot text NOT NULL,
 internal_lot text NOT NULL,
 received_quantity numeric(14,3) NOT NULL CHECK (received_quantity >= 0),
 unit text NOT NULL,
 status text NOT NULL DEFAULT 'QUARANTINE'
   CHECK (status IN ('QUARANTINE','RELEASED','ON_HOLD','REJECTED','DEPLETED')),
 received_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(site_id, internal_lot)
);
CREATE TABLE lot_consumptions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 work_order_id uuid NOT NULL REFERENCES work_orders(id),
 material_lot_id uuid NOT NULL REFERENCES material_lots(id),
 quantity numeric(14,3) NOT NULL CHECK (quantity > 0),
 unit text NOT NULL,
 recorded_by text NOT NULL,
 recorded_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE production_runs (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 work_order_id uuid NOT NULL REFERENCES work_orders(id),
 line_code text NOT NULL,
 shift_code text NOT NULL,
 started_at timestamptz NOT NULL,
 ended_at timestamptz,
 good_quantity numeric(14,3) NOT NULL DEFAULT 0 CHECK (good_quantity >= 0),
 reject_quantity numeric(14,3) NOT NULL DEFAULT 0 CHECK (reject_quantity >= 0),
 recorded_by text NOT NULL,
 CHECK (ended_at IS NULL OR ended_at >= started_at)
);
CREATE TABLE process_checks (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 site_id uuid NOT NULL REFERENCES sites(id),
 work_order_id uuid REFERENCES work_orders(id),
 production_run_id uuid REFERENCES production_runs(id),
 check_code text NOT NULL,
 observed_value numeric(16,5),
 unit text,
 result text NOT NULL CHECK (result IN ('PASS','FAIL','NOT_APPLICABLE')),
 observed_at timestamptz NOT NULL DEFAULT now(),
 instrument_id text,
 evidence_ref text,
 recorded_by text NOT NULL,
 CHECK (result <> 'PASS' OR observed_value IS NOT NULL OR evidence_ref IS NOT NULL)
);
CREATE TABLE product_holds (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 site_id uuid NOT NULL REFERENCES sites(id),
 work_order_id uuid REFERENCES work_orders(id),
 material_lot_id uuid REFERENCES material_lots(id),
 reason_code text NOT NULL,
 reason text NOT NULL,
 status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','UNDER_REVIEW','DISPOSITIONED')),
 opened_by text NOT NULL,
 opened_at timestamptz NOT NULL DEFAULT now(),
 closed_by text,
 closed_at timestamptz,
 disposition text CHECK (disposition IN ('RELEASE','REWORK','REJECT','RETURN_TO_SUPPLIER')),
 CHECK (status <> 'DISPOSITIONED' OR (closed_by IS NOT NULL AND closed_at IS NOT NULL AND disposition IS NOT NULL))
);
CREATE TABLE audit_events (
 id bigserial PRIMARY KEY,
 occurred_at timestamptz NOT NULL DEFAULT now(),
 actor_id text NOT NULL,
 actor_role text NOT NULL,
 site_id uuid REFERENCES sites(id),
 action text NOT NULL,
 entity_type text NOT NULL,
 entity_id text NOT NULL,
 correlation_id text,
 reason text,
 payload jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX idx_work_orders_site_status ON work_orders(site_id, status);
CREATE INDEX idx_material_lots_site_status ON material_lots(site_id, status);
CREATE INDEX idx_checks_work_order_time ON process_checks(work_order_id, observed_at DESC);
CREATE INDEX idx_holds_site_status ON product_holds(site_id, status);
CREATE INDEX idx_audit_entity_time ON audit_events(entity_type, entity_id, occurred_at DESC);
-- Application roles should receive INSERT/SELECT on audit_events, never UPDATE/DELETE.
REVOKE UPDATE, DELETE, TRUNCATE ON audit_events FROM PUBLIC;
COMMIT;

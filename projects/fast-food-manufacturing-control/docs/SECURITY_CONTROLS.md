# Security controls

- Authentication: managed identity provider; MFA for privileged access.
- Authorization: deny-by-default RBAC plus site-scoped checks in every service query.
- Input validation: validate API bodies, params, and environment configuration with Zod.
- Secrets: cloud secret manager; never commit API keys, passwords, tokens, certificates, or production connection strings.
- Encryption: TLS in transit; KMS-managed envelope encryption for sensitive records; documented key rotation.
- Audit: append-only events with actor/role/site, timestamp, action, entity, reason, and correlation ID; export to immutable storage.
- Privacy: minimum workforce data; no payment credentials, full card data, or unrelated identity/credit data.
- Integrations: default deny; no POS writes, payment actions, payroll writes, supplier writes, or equipment control.
- Supply chain: lock dependency versions, scan dependencies/containers, pin CI actions, protect default branch, require review.
- Incident response: preserve evidence, revoke credentials, isolate integration, assess product/lot impact with qualified personnel.

## Production blockers
Production authentication provider, RBAC middleware, KMS adapter, immutable audit sink, alerting, backup/restore proof, penetration test, and site validation are not implemented.

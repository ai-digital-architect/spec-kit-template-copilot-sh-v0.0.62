---
title: Governance & Compliance Features
category: Governance
priority: Tier 2-3
version: 1.0.0
date: 2025-11-07
---

# Governance & Compliance Features

Tools for enforcing architectural standards, meeting regulatory requirements, and maintaining event catalog health.

## Feature 4.1: Architecture Decision Records (ADR) Integration

### Description
Capture and link Architecture Decision Records to events, schemas, and services in EventCatalog.

### Problem Statement
Architectural decisions are made but not documented or linked to the artifacts they affect, leading to lost context and repeated discussions.

### Key Capabilities
- ADR template for event-driven decisions
- Link ADRs to specific events/schemas/services
- Track decision history and superseded decisions
- Generate ADR documentation in EventCatalog

### Template Example
```markdown
---
adr: 001
title: Use Avro for Event Schemas
status: accepted
date: 2025-11-07
supersedes: none
---

## Context
Need to select schema format for event serialization in Kafka.

## Decision
Use Apache Avro for all event schemas.

## Consequences
**Positive:**
- Schema evolution support
- Compact binary format
- Strong typing
- Confluent Schema Registry integration

**Negative:**
- Learning curve for team
- Additional tooling required
- Not human-readable

## Affected Events
- user.registered
- order.placed
- payment.processed
```

### Priority
**Tier 2-3** - Important for governance and knowledge management.

---

## Feature 4.2: Compliance Checker

### Description
Automated validation of event schemas and data handling against regulatory requirements (GDPR, HIPAA, PCI-DSS, SOC 2).

### Problem Statement
Manual compliance checks are error-prone, inconsistent, and don't scale. Teams need automated validation to ensure regulatory requirements are met.

### Key Capabilities

#### GDPR Compliance Checks
- PII field identification
- Data retention policies defined
- Right to deletion support
- Consent tracking
- Data processing lawful basis

#### HIPAA Compliance Checks
- PHI field identification and encryption
- Audit logging requirements
- Access controls
- Data integrity verification
- Breach notification readiness

#### PCI-DSS Compliance Checks
- Credit card data handling
- Encryption requirements
- Access logging
- Key rotation policies

### Configuration Example
```yaml
# .specify/config/compliance.yml

compliance:
  regulations:
    - gdpr
    - hipaa
    - pci-dss

  gdpr:
    pii_fields:
      - email
      - name
      - phone
      - address

    requirements:
      - data_retention_policy: required
      - right_to_deletion: required
      - consent_tracking: required
      - data_minimization: enforced

  hipaa:
    phi_patterns:
      - medical_record_number
      - health_plan_number
      - diagnosis
      - treatment

    requirements:
      - encryption_at_rest: required
      - encryption_in_transit: required
      - audit_logging: required
      - access_controls: required

  validation:
    on_schema_create: true
    on_schema_update: true
    block_non_compliant: true
```

### Validation Report
```
Compliance Validation Report
============================

Schema: patient.admitted v1.0.0

GDPR Compliance: FAILED
  ✗ Field 'email' marked as PII but no retention policy defined
  ✗ No consent tracking mechanism specified
  ✓ Data minimization requirements met

HIPAA Compliance: FAILED
  ✗ PHI field 'diagnosis' not encrypted
  ✗ Audit logging not configured
  ✗ Access controls not specified
  ✓ Data integrity checks present

PCI-DSS: NOT APPLICABLE
  ✓ No credit card data detected

RECOMMENDATION: Add encryption, retention policy, and audit logging
before deploying to production.
```

### Priority
**Tier 3** - Critical for regulated industries.

---

## Feature 4.3: Event Catalog Health Dashboard

### Description
Comprehensive health metrics and quality scores for EventCatalog, identifying gaps, drift, and areas for improvement.

### Problem Statement
EventCatalog quality degrades over time without visibility into coverage, staleness, and consistency. Teams need metrics to maintain quality.

### Key Capabilities

#### Documentation Coverage Metrics
```
Overall Coverage: 73%

Events: 145/200 (72% documented)
  ✓ Documented: 145
  ✗ Missing docs: 55

Schemas: 180/200 (90% have schemas)
  ✓ With schemas: 180
  ✗ Missing schemas: 20

Services: 42/50 (84% documented)
  ✓ Documented: 42
  ✗ Missing docs: 8

Domains: 8/10 (80% documented)
  ✓ Documented: 8
  ✗ Missing docs: 2
```

#### Schema Drift Detection
```
Schema Drift Report
===================

Events with schema mismatches: 12

High Priority (production mismatch):
  ✗ user.registered: Catalog shows v2.1.0, Registry has v2.3.0
  ✗ order.placed: Field 'total' type mismatch (catalog: int, registry: decimal)

Medium Priority (staging mismatch):
  ⚠ payment.processed: New optional field 'currency' in registry

Low Priority (beta versions):
  ⚠ product.updated: Beta version in catalog, not in registry
```

#### Orphaned Events
```
Orphaned Events: 8

Events with no producers:
  - inventory.adjusted (last produced: 90 days ago)
  - user.suspended (never produced)

Events with no consumers:
  - session.expired (no known consumers)
  - cache.invalidated (legacy, deprecated)

Recommendation: Archive or deprecate unused events
```

#### Quality Scores
```
Event Quality Scores
====================

Excellent (90-100): 45 events
  - Complete documentation
  - Schema present and validated
  - Examples included
  - Ownership clear

Good (75-89): 78 events
  - Documentation present
  - Schema validated
  - Minor issues

Fair (50-74): 52 events
  - Basic documentation
  - Schema issues
  - Ownership unclear

Poor (<50): 25 events
  - Minimal documentation
  - Schema missing or invalid
  - No ownership
```

#### Trends Over Time
```
Documentation Trends (Last 30 Days)
====================================

New events added: 15
Events documented: 12 (80% documentation rate)

Schemas updated: 34
Documentation updated: 28 (82% sync rate)

Average time to document: 2.3 days (target: <3 days)

Quality score trend: 73% → 76% (+3% improvement)
```

### Dashboard Visualization
```
┌─────────────────────────────────────────────────────┐
│ EventCatalog Health Dashboard                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Overall Health Score: 76/100                        │
│ ████████████████████░░░░░░░░░                       │
│                                                     │
│ Coverage:        73%  ███████████░░░░                │
│ Schema Quality:  85%  ████████████████░              │
│ Freshness:       68%  ██████████░░░░░                │
│ Ownership:       92%  ██████████████████░            │
│                                                     │
│ Top Issues:                                         │
│ • 55 events missing documentation                   │
│ • 12 schema drift issues                            │
│ • 8 orphaned events                                 │
│ • 23 events >90 days since update                   │
│                                                     │
│ Action Items:                                       │
│ [1] Document high-priority missing events           │
│ [2] Resolve schema drift for production events      │
│ [3] Archive or deprecate orphaned events            │
└─────────────────────────────────────────────────────┘
```

### Implementation
```bash
#!/bin/bash
# .specify/scripts/bash/catalog-health.sh

generate_health_report() {
  # Calculate coverage metrics
  total_events=$(count_events_in_catalog)
  documented_events=$(count_documented_events)
  coverage=$((documented_events * 100 / total_events))

  # Detect schema drift
  drift_issues=$(detect_schema_drift)

  # Find orphaned events
  orphaned=$(find_orphaned_events)

  # Calculate quality scores
  quality_scores=$(calculate_quality_scores)

  # Generate report
  create_health_dashboard "$coverage" "$drift_issues" "$orphaned" "$quality_scores"
}
```

### Priority
**Tier 2-3** - Important for maintaining long-term catalog quality.

---

## Related Features
- **Feature 1.2:** EventCatalog Schema Validator (validates schemas)
- **Feature 2.3:** Schema Governance Rules (enforces standards)
- **Feature 9.3:** Event Catalog Drift Detection (runtime drift detection)

## Resources
- [GDPR Compliance Guide](https://gdpr.eu/)
- [HIPAA Requirements](https://www.hhs.gov/hipaa/)
- [Architecture Decision Records](https://adr.github.io/)

---
title: Schema Lifecycle Management Features
category: Schema Management
priority: Tier 1-2
version: 1.0.0
date: 2025-11-07
---

# Schema Lifecycle Management Features

Comprehensive workflow for creating, evolving, and governing event schemas throughout their entire lifecycle, from initial design to deprecation.

## Overview

Event schema management is one of the most challenging aspects of event-driven architectures. These features provide structured workflows, automated validation, and governance to ensure schema quality, compatibility, and compliance throughout the lifecycle.

## Feature 2.1: Schema-First Workflow

### Description

A guided, step-by-step workflow for creating new event schemas with built-in best practices, validation, and compatibility checking.

### Problem Statement

**Pain Point:** Teams struggle with schema design because:
- No standardized process for creating schemas
- Best practices not codified or enforced
- Compatibility issues discovered too late
- Inconsistent schema quality across teams
- Missing critical metadata and documentation

**Impact:** EventCatalog team identified that "the life-cycle of defining messages, schemas, ideas, collaboration with teams, documentation and governance is a mess."

### Target Users

- **Schema Owners** creating new event definitions
- **Domain Experts** defining business events
- **Developers** implementing event producers/consumers
- **Architects** ensuring schema consistency

### Key Capabilities

#### Interactive Schema Wizard

**Step 1: Schema Type Selection**
```
Select schema format:
[1] Avro (recommended for Kafka)
[2] JSON Schema (recommended for REST/HTTP)
[3] Protobuf (recommended for gRPC)
[4] Custom format

Selected: [1] Avro
```

**Step 2: Event Metadata**
```
Event Name: user.registered
Domain: user-management
Owner: identity-team
Version: 1.0.0
Description: Fired when a new user completes registration

Business Context: [User provides context]
Use Cases: [User provides use cases]
```

**Step 3: Schema Definition**
- Template selection (create new, copy existing, import)
- Field definition with types
- Required/optional field designation
- Default values
- Documentation strings

**Step 4: Compatibility Rules**
```
Select compatibility mode:
[1] BACKWARD (consumers using older schema can read new data)
[2] FORWARD (consumers using newer schema can read old data)
[3] FULL (both backward and forward)
[4] NONE (breaking changes allowed)

Selected: [3] FULL

Justification: [Required for non-FULL modes]
```

**Step 5: Governance Checks**
- PII field identification
- Data retention policy
- Security classification
- Compliance requirements (GDPR, HIPAA, etc.)

**Step 6: Validation and Generation**
- Schema syntax validation
- Compatibility simulation
- Example payload generation
- EventCatalog documentation generation

#### Schema Templates

**Avro Schema Template:**
```json
{
  "type": "record",
  "namespace": "com.yourcompany.{domain}",
  "name": "{EventName}",
  "version": "1.0.0",
  "doc": "{Event description}",
  "fields": [
    {
      "name": "eventId",
      "type": "string",
      "doc": "Unique identifier for this event instance",
      "logicalType": "uuid"
    },
    {
      "name": "occurredAt",
      "type": "long",
      "doc": "Timestamp when event occurred",
      "logicalType": "timestamp-millis"
    },
    {
      "name": "aggregateId",
      "type": "string",
      "doc": "ID of the aggregate that produced this event"
    },
    {
      "name": "aggregateVersion",
      "type": "long",
      "doc": "Version of the aggregate after this event"
    }
  ]
}
```

**JSON Schema Template:**
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://yourcompany.com/schemas/{domain}/{event-name}.schema.json",
  "title": "{EventName}",
  "description": "{Event description}",
  "type": "object",
  "properties": {
    "eventId": {
      "type": "string",
      "format": "uuid",
      "description": "Unique identifier for this event instance"
    },
    "occurredAt": {
      "type": "string",
      "format": "date-time",
      "description": "Timestamp when event occurred"
    }
  },
  "required": ["eventId", "occurredAt"],
  "additionalProperties": false
}
```

#### Best Practices Enforcement

**Naming Conventions:**
- Event names: past tense, domain-prefixed (e.g., `user.registered`, `order.shipped`)
- Field names: camelCase for Avro/JSON, snake_case for Protobuf
- Namespace: organization.domain structure

**Required Fields:**
- Event ID (unique identifier)
- Timestamp (when event occurred)
- Aggregate ID (source entity)
- Version (for event versioning)

**Anti-Patterns Detection:**
- Generic field names (e.g., `data`, `payload`, `info`)
- Missing documentation strings
- Overly large schemas (>50 fields warning)
- Nested depth >5 levels
- Non-nullable fields without defaults

### Technical Approach

#### Implementation

```bash
#!/bin/bash
# .specify/scripts/bash/schema-workflow.sh

schema_wizard() {
  echo "=== Schema-First Workflow ==="

  # Step 1: Select schema format
  schema_format=$(prompt_schema_format)

  # Step 2: Gather metadata
  event_name=$(prompt "Event name (e.g., user.registered): ")
  domain=$(prompt "Domain (e.g., user-management): ")
  owner=$(prompt "Owner team: ")
  version=$(prompt "Version [1.0.0]: " "1.0.0")
  description=$(prompt "Description: ")

  # Step 3: Create schema file
  schema_file="specs/${FEATURE_ID}/schemas/${event_name}.${schema_format}"
  create_schema_from_template "$schema_format" "$schema_file"

  # Step 4: Open in editor for field definition
  ${EDITOR:-vi} "$schema_file"

  # Step 5: Validate schema
  validate_schema "$schema_file" "$schema_format"

  # Step 6: Check compatibility
  compatibility_mode=$(prompt_compatibility_mode)
  validate_compatibility "$schema_file" "$compatibility_mode"

  # Step 7: Governance checks
  run_governance_checks "$schema_file"

  # Step 8: Generate EventCatalog docs
  generate_event_documentation "$event_name" "$schema_file"

  echo "✓ Schema created successfully: $schema_file"
  echo "✓ EventCatalog documentation generated"
}

# Compatibility validation
validate_compatibility() {
  local schema_file=$1
  local mode=$2

  # Find existing schemas for this event
  existing_schemas=$(find_previous_versions "$schema_file")

  if [ -z "$existing_schemas" ]; then
    echo "✓ No previous versions found. Compatibility check skipped."
    return 0
  fi

  # Use avro-tools or schema-registry-cli for validation
  case $mode in
    BACKWARD)
      check_backward_compatibility "$schema_file" "$existing_schemas"
      ;;
    FORWARD)
      check_forward_compatibility "$schema_file" "$existing_schemas"
      ;;
    FULL)
      check_backward_compatibility "$schema_file" "$existing_schemas"
      check_forward_compatibility "$schema_file" "$existing_schemas"
      ;;
  esac
}
```

#### Integration with SpecKit

```
/speckit.schema create
→ Launches schema wizard
→ Creates schema file in specs/{feature}/schemas/
→ Validates and generates documentation
→ Updates plan.md with schema reference
```

### Success Metrics

- **Schema Quality:** 95%+ schemas pass all governance checks on first submission
- **Time to Create:** 50% reduction in time to create compliant schema
- **Compatibility Issues:** 90% reduction in production compatibility errors
- **Documentation Coverage:** 100% of schemas have complete documentation
- **Developer Satisfaction:** 4.5+ out of 5 rating for workflow usability

### Dependencies

- Schema format validators (avro-tools, ajv, protoc)
- Schema registry (Confluent, AWS Glue, or similar) for compatibility checks
- SpecKit constitution for governance rules
- EventCatalog generator (Feature 1.1)

### Priority

**Tier 1** - Addresses primary pain point in schema lifecycle.

---

## Feature 2.2: Schema Evolution Planner

### Description

Analyze the impact of schema changes across the system, identify breaking changes, and generate comprehensive migration plans for safe schema evolution.

### Problem Statement

**Pain Point:** Schema evolution is risky and poorly managed:
- Breaking changes discovered in production
- Unclear impact on downstream consumers
- No standardized migration process
- Communication gaps across teams
- Rollback complexity

**Impact:** Production incidents, data loss, consumer failures, and eroded trust in event-driven architecture.

### Target Users

- **Schema Owners** evolving existing events
- **Platform Engineers** managing schema registries
- **Development Teams** consuming events
- **SRE Teams** managing production rollouts

### Key Capabilities

#### Change Impact Analysis

**Schema Comparison:**
```
Comparing schemas:
  Old: user.registered v1.2.0
  New: user.registered v2.0.0

BREAKING CHANGES (3):
  ✗ Removed field: middleName (string)
  ✗ Changed type: age (int → string)
  ✗ Added required field: phoneNumber (string)

NON-BREAKING CHANGES (2):
  ✓ Added optional field: preferences (record)
  ✓ Added default value: country = "US"

COMPATIBILITY: NONE (breaking changes present)
```

**Consumer Impact Mapping:**
```
Downstream consumers affected: 12 services

HIGH IMPACT (immediate action required):
  - user-notification-service (uses middleName, age)
  - analytics-pipeline (uses age for segmentation)
  - crm-sync-service (uses middleName, age)

MEDIUM IMPACT (testing required):
  - email-service (may use new phoneNumber field)
  - reporting-service (schema upgrade needed)

LOW IMPACT (monitoring recommended):
  - audit-logger (schemaless processing)
  - metrics-collector (field-agnostic)
```

#### Migration Strategy Generation

**Parallel Schema Strategy:**
```markdown
# Migration Plan: user.registered v1.2.0 → v2.0.0

## Strategy: Parallel Schemas (Recommended)

### Phase 1: Dual Publishing (Week 1-2)
- Producer publishes to TWO topics:
  - user.registered.v1 (existing consumers)
  - user.registered.v2 (new schema)
- Both schemas maintained in parallel
- No consumer changes required yet

### Phase 2: Consumer Migration (Week 3-6)
Migrate consumers one at a time:

Week 3-4:
  - [ ] user-notification-service → v2
  - [ ] crm-sync-service → v2

Week 5-6:
  - [ ] analytics-pipeline → v2 (requires data backfill)
  - [ ] email-service → v2
  - [ ] reporting-service → v2

### Phase 3: Cleanup (Week 7)
- [ ] Verify all consumers migrated
- [ ] Deprecate v1 topic
- [ ] Remove v1 publishing code
- [ ] Update EventCatalog documentation

### Rollback Plan
If issues arise:
1. Pause consumer migrations
2. Keep dual publishing active
3. Debug and fix issues
4. Resume migration

### Required Code Changes

**Producer:**
```java
// Dual publishing during migration
eventPublisher.publish("user.registered.v1", eventV1);
eventPublisher.publish("user.registered.v2", eventV2);
```

**Transformation Layer:**
```java
// Convert v1 → v2
UserRegisteredV2 transform(UserRegisteredV1 v1) {
  return UserRegisteredV2.builder()
    .eventId(v1.eventId)
    .occurredAt(v1.occurredAt)
    .age(String.valueOf(v1.age))  // int → string
    .phoneNumber(lookupPhoneNumber(v1.userId))  // fetch from user service
    // middleName dropped
    .build();
}
```
```

**Alternative Strategies:**

1. **Transformation Layer:**
   - Add adapter service to transform v1 → v2
   - Consumers continue reading v1
   - Adapter publishes v2 to new topic
   - Gradual consumer migration

2. **Schema Evolution with Defaults:**
   - Make breaking fields optional with defaults
   - Maintains backward compatibility
   - Temporary workaround for urgent cases

3. **Big Bang Migration:**
   - Coordinate simultaneous update across all services
   - High risk, suitable only for small systems
   - Requires extensive testing and rollback plan

#### Migration Timeline Generator

```
Migration Timeline: user.registered v1.2.0 → v2.0.0

Week 1: Preparation
  Mon: Schema review meeting with consumers
  Tue-Wed: Update producer code for dual publishing
  Thu: Deploy producer to staging
  Fri: Staging validation

Week 2: Dual Publishing Start
  Mon: Deploy dual publishing to production
  Tue-Fri: Monitor both topics for consistency

Week 3-4: High-Priority Consumers
  [Detailed timeline for each service]

Week 5-6: Remaining Consumers
  [Detailed timeline for each service]

Week 7: Cleanup
  Mon: Final verification
  Tue: Remove v1 topic
  Wed-Thu: Monitor for issues
  Fri: Retrospective
```

### Technical Approach

#### Schema Diff Engine

```bash
#!/bin/bash
# .specify/scripts/bash/schema-evolution.sh

compare_schemas() {
  local old_schema=$1
  local new_schema=$2
  local format=$3

  case $format in
    avro)
      diff_avro_schemas "$old_schema" "$new_schema"
      ;;
    json-schema)
      diff_json_schemas "$old_schema" "$new_schema"
      ;;
    protobuf)
      diff_protobuf_schemas "$old_schema" "$new_schema"
      ;;
  esac
}

# Avro-specific comparison
diff_avro_schemas() {
  local old=$1
  local new=$2

  # Extract fields from both schemas
  old_fields=$(jq -r '.fields[].name' "$old")
  new_fields=$(jq -r '.fields[].name' "$new")

  # Find removed fields (breaking)
  removed_fields=$(comm -23 <(echo "$old_fields" | sort) <(echo "$new_fields" | sort))
  if [ -n "$removed_fields" ]; then
    echo "BREAKING: Removed fields: $removed_fields"
  fi

  # Find added required fields (breaking)
  # Find type changes (potentially breaking)
  # etc.
}

# Consumer impact analysis
find_consumers() {
  local event_name=$1

  # Search codebase for event consumers
  grep -r "subscribe.*$event_name" . --include="*.java" --include="*.ts"

  # Query EventCatalog for registered consumers
  # Query service mesh/API gateway for subscription data
  # Parse Kafka consumer groups
}

generate_migration_plan() {
  local event_name=$1
  local old_version=$2
  local new_version=$3

  # Analyze breaking changes
  breaking_changes=$(compare_schemas "$old_version" "$new_version")

  if [ -z "$breaking_changes" ]; then
    echo "No breaking changes. Safe to deploy."
    return 0
  fi

  # Find consumers
  consumers=$(find_consumers "$event_name")

  # Generate migration plan template
  cat > "migration-plan-$event_name.md" <<EOF
# Migration Plan: $event_name $old_version → $new_version

## Breaking Changes
$breaking_changes

## Affected Consumers
$consumers

## Recommended Strategy
[Auto-generated based on change type and consumer count]

## Timeline
[Auto-generated migration timeline]

## Rollback Plan
[Auto-generated rollback procedures]
EOF
}
```

#### Integration

```
/speckit.schema evolve
→ Prompts for event name and new schema version
→ Runs diff analysis
→ Identifies consumers
→ Generates migration plan
→ Updates EventCatalog with deprecation notices
```

### Success Metrics

- **Breaking Change Detection:** 100% of breaking changes identified pre-deployment
- **Consumer Impact Accuracy:** 95%+ consumer impact predictions accurate
- **Migration Success Rate:** 98%+ migrations complete without incidents
- **Planning Time:** 75% reduction in migration planning time
- **Rollback Rate:** <2% of migrations require rollback

### Dependencies

- Schema registry with versioning
- Service catalog or consumer registry
- EventCatalog integration
- Feature 2.1 (Schema-First Workflow)

### Priority

**Tier 2** - High impact for teams managing schema evolution.

---

## Feature 2.3: Schema Governance Rules

### Description

Constitution-style governance rules for schema design that enforce organizational standards automatically during schema creation and evolution.

### Problem Statement

**Pain Point:** Inconsistent schema quality because:
- Best practices not codified
- Manual reviews miss issues
- No enforcement mechanism
- Standards vary across teams
- Compliance requirements overlooked

**Impact:** Technical debt, compliance violations, integration difficulties, and reduced system reliability.

### Target Users

- **Platform Engineers** defining standards
- **Architects** enforcing consistency
- **Compliance Officers** ensuring regulatory compliance
- **Schema Owners** following guidelines

### Key Capabilities

#### Governance Rule Categories

**Naming Conventions:**
```yaml
# .specify/config/schema-governance.yml

naming:
  event_names:
    pattern: "^[a-z]+\\.[a-z]+(\\.[a-z]+)*$"
    description: "Must be lowercase, dot-separated (e.g., user.registered)"
    severity: error

  field_names:
    avro:
      pattern: "^[a-zA-Z][a-zA-Z0-9]*$"
      description: "Must be camelCase"
      severity: error

    protobuf:
      pattern: "^[a-z][a-z0-9_]*$"
      description: "Must be snake_case"
      severity: error

  namespaces:
    pattern: "^com\\.yourcompany\\.[a-z]+(\\.[a-z]+)*$"
    description: "Must follow org.domain structure"
    severity: error
```

**Required Metadata:**
```yaml
required_fields:
  - name: eventId
    type: [string, uuid]
    description: "Unique event identifier"
    severity: error

  - name: occurredAt
    type: [timestamp, datetime, long]
    description: "Event timestamp"
    severity: error

  - name: aggregateId
    type: string
    description: "Source aggregate ID"
    severity: error

  - name: schemaVersion
    type: string
    description: "Schema version"
    severity: warning

required_metadata:
  - field: doc
    description: "Schema-level documentation required"
    severity: error

  - field: owner
    description: "Team ownership required"
    severity: error
```

**Data Privacy & Compliance:**
```yaml
pii_detection:
  enabled: true

  pii_fields:
    - patterns: ["email", ".*Email.*", ".*_email"]
      classification: PII
      requirements:
        - encryption_at_rest: true
        - retention_policy: required
        - gdpr_compliant: true

    - patterns: ["ssn", "socialSecurity", ".*_ssn"]
      classification: SENSITIVE_PII
      requirements:
        - encryption_at_rest: true
        - encryption_in_transit: true
        - access_logging: true
        - retention_policy: required
        - hipaa_compliant: true

  auto_tag: true
  require_justification: true
```

**Schema Complexity Rules:**
```yaml
complexity:
  max_fields: 50
  max_nesting_depth: 5
  max_array_nesting: 3

  warnings:
    field_count_warning: 30
    nesting_warning: 3

  forbidden_patterns:
    - pattern: "^(data|payload|info|object)$"
      reason: "Generic field names reduce clarity"
      severity: warning

    - pattern: ".*temp.*|.*tmp.*"
      reason: "Temporary field names in production schema"
      severity: error
```

**Versioning Rules:**
```yaml
versioning:
  format: semver  # semantic versioning required

  breaking_changes_require:
    - major_version_bump: true
    - migration_plan: true
    - deprecation_notice: true
    - consumer_notification: true

  non_breaking_changes_require:
    - minor_version_bump: true
    - changelog_entry: true
```

#### Validation Workflow

```
Schema Validation Report
========================

Schema: user.registered v2.0.0
File: specs/001-user-registration/schemas/user.registered.avro

ERRORS (2) - Must fix before proceeding:
  ✗ [NAMING] Field 'EMail' violates camelCase convention
    → Suggestion: Rename to 'email'

  ✗ [REQUIRED_FIELD] Missing required field 'occurredAt'
    → Add timestamp field for event occurrence

WARNINGS (3) - Review recommended:
  ⚠ [COMPLEXITY] Schema has 45 fields (warning threshold: 30)
    → Consider splitting into multiple events

  ⚠ [PII] Field 'email' contains PII
    → Ensure retention policy defined: [not found]
    → Ensure encryption configured: [not found]

  ⚠ [NAMING] Generic field name 'data' found
    → Rename to describe actual content

COMPLIANCE CHECKS (2):
  ✓ GDPR: Data retention policy defined
  ✗ HIPAA: Missing required audit fields

Fix errors and re-run validation with:
  /speckit.schema validate specs/001-user-registration/schemas/user.registered.avro
```

#### Custom Rules

Allow teams to define custom rules:

```yaml
# .specify/config/schema-governance-custom.yml

custom_rules:
  - id: require-correlation-id
    description: "All events must have correlationId for tracing"
    check: |
      field_exists("correlationId") ||
      field_exists("correlation_id") ||
      field_exists("traceId")
    severity: error
    message: "Add correlationId field for distributed tracing"

  - id: immutable-events
    description: "Events are immutable - no update/delete operations"
    check: |
      !event_name_contains("updated") &&
      !event_name_contains("deleted") &&
      !event_name_contains("modified")
    severity: warning
    message: "Consider using state-transition events instead of updates"

  - id: event-size-limit
    description: "Event payload should be under 1MB"
    check: estimated_size_bytes() < 1048576
    severity: error
    message: "Event too large. Consider event enrichment pattern."
```

### Technical Approach

```bash
#!/bin/bash
# .specify/scripts/bash/schema-governance.sh

validate_governance() {
  local schema_file=$1
  local config_file=".specify/config/schema-governance.yml"

  # Load governance rules
  source_governance_rules "$config_file"

  # Run validations
  validate_naming_conventions "$schema_file"
  validate_required_fields "$schema_file"
  validate_pii_compliance "$schema_file"
  validate_complexity_rules "$schema_file"
  validate_versioning_rules "$schema_file"
  validate_custom_rules "$schema_file"

  # Generate report
  generate_governance_report
}

# Example: PII detection
validate_pii_compliance() {
  local schema_file=$1

  # Extract all field names
  fields=$(extract_field_names "$schema_file")

  for field in $fields; do
    # Check against PII patterns
    if matches_pii_pattern "$field"; then
      # Verify compliance requirements
      if ! has_retention_policy "$field"; then
        add_error "PII field '$field' missing retention policy"
      fi

      if ! has_encryption_config "$field"; then
        add_warning "PII field '$field' should configure encryption"
      fi
    fi
  done
}
```

### Success Metrics

- **Rule Compliance:** 95%+ schemas pass all governance checks
- **Compliance Violations:** 0 compliance violations in production
- **Review Time:** 70% reduction in manual review time
- **Standards Adoption:** 100% of teams using governance rules
- **Custom Rules:** Average 5+ custom rules per organization

### Dependencies

- Schema validators (avro-tools, ajv, protoc)
- YAML parser for rule configuration
- SpecKit constitution framework
- Feature 2.1 (Schema-First Workflow)

### Priority

**Tier 2** - Important for organizations with compliance requirements and large teams.

---

## Implementation Roadmap

### Phase 1: Foundation (Month 1-2)
- Implement Feature 2.1 (Schema-First Workflow)
- Create schema templates for Avro, JSON Schema, Protobuf
- Basic validation and compatibility checking

### Phase 2: Governance (Month 2-3)
- Implement Feature 2.3 (Schema Governance Rules)
- Build rule engine and validation framework
- Create default rule sets

### Phase 3: Evolution (Month 3-4)
- Implement Feature 2.2 (Schema Evolution Planner)
- Build diff engine and impact analysis
- Create migration plan templates

### Phase 4: Integration (Month 4-5)
- Integrate with schema registries
- Connect to EventCatalog
- Add CI/CD pipeline integration

## Related Features

- **Feature 1.1:** EventCatalog Generator (generates schema docs)
- **Feature 1.2:** EventCatalog Schema Validator (uses same validation engine)
- **Feature 5.1:** AsyncAPI Code Generator (uses schemas for generation)
- **Feature 9.1:** Event Schema Registry Integration (runtime sync)

## Resources

- [Schema Registry Documentation](https://docs.confluent.io/platform/current/schema-registry/)
- [Avro Schema Evolution](https://docs.confluent.io/platform/current/schema-registry/avro.html)
- [JSON Schema Best Practices](https://json-schema.org/understanding-json-schema/)
- [EventCatalog Schema Support](https://www.eventcatalog.dev/docs/events/schemas)

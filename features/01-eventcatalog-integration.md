---
title: EventCatalog Integration Features
category: Integration
priority: Tier 1
version: 1.0.0
date: 2025-11-07
---

# EventCatalog Integration Features

Core integration features that bridge design-time workflows with EventCatalog's documentation platform, enabling automatic generation and synchronization of event-driven architecture documentation.

## Overview

EventCatalog excels at documenting existing event-driven architectures, but lacks structured workflows for the creation phase. These integration features fill that gap by connecting design-time artifacts (specs, DDD models, contracts) with EventCatalog's documentation capabilities.

## Feature 1.1: EventCatalog Generator Plugin

### Description

Automatically generate EventCatalog markdown files and documentation structure from SpecKit DDD artifacts and planning documents.

### Problem Statement

**Pain Point:** Teams manually duplicate information between design documents and EventCatalog, leading to:
- Documentation drift and inconsistency
- Significant manual effort
- Delayed or missing documentation
- Context loss between design and documentation phases

**Impact:** The EventCatalog team identified that "the life-cycle of defining messages, schemas, ideas, collaboration with teams, documentation and governance is a mess."

### Target Users

- **Software Architects** designing event-driven systems
- **Platform Engineers** maintaining EventCatalog instances
- **Development Teams** implementing event-driven features
- **Technical Writers** maintaining architecture documentation

### Key Capabilities

#### Automatic Mapping
- **Domain Events → EventCatalog Events**
  - Extract event metadata from DDD domain event templates
  - Generate event markdown with schema, version, ownership
  - Include examples and payload structures

- **Bounded Contexts → EventCatalog Services/Domains**
  - Map bounded context definitions to service documentation
  - Extract ubiquitous language for glossaries
  - Generate domain relationship diagrams

- **Contracts → AsyncAPI Specifications**
  - Convert API contract templates to AsyncAPI 3.0 specs
  - Include message formats, channels, bindings
  - Generate EventBridge, Kafka, or custom broker configurations

- **Aggregates → Service Resources**
  - Document aggregate roots as key service resources
  - Link related events and commands
  - Include state transition diagrams

#### Generated Content Structure

```
eventcatalog/
├── domains/
│   └── {bounded-context-name}/
│       ├── index.md                    # From bounded-context.md
│       └── openapi.yml                 # From api-contract.md
├── services/
│   └── {service-name}/
│       ├── index.md                    # From plan.md + DDD artifacts
│       ├── asyncapi.yml                # From contracts/events.md
│       └── changelog.md                # From version history
└── events/
    └── {event-name}/
        ├── index.md                    # From domain-event.md
        ├── schema.avro                 # From data-model.md
        └── examples/
            └── example-1.json          # From test scenarios
```

#### Metadata Extraction

Automatically extract and populate:
- Event/service ownership from plan.md
- Version information from spec.md front matter
- Tags and categories from DDD templates
- Relationships (produces/consumes) from context maps
- Deprecation status from lifecycle metadata

### Technical Approach

#### Phase 1: Template Parser
- Read SpecKit templates from `specs/{feature}/`
- Parse YAML front matter and markdown content
- Extract DDD artifact metadata
- Build intermediate representation (IR) of architecture

#### Phase 2: EventCatalog Generator
- Transform IR to EventCatalog markdown format
- Generate AsyncAPI/OpenAPI specifications
- Create directory structure matching EventCatalog conventions
- Populate schema files in required formats (Avro, JSON Schema, Protobuf)

#### Phase 3: Integration Script
- Bash script: `.specify/scripts/bash/generate-eventcatalog.sh`
- Triggered via: `/speckit.eventcatalog generate`
- Configuration file: `.specify/config/eventcatalog.config.yml`

#### Configuration Example

```yaml
# .specify/config/eventcatalog.config.yml
eventcatalog:
  output_dir: "./eventcatalog"
  version: "1.0.0"

  mappings:
    # Map SpecKit artifacts to EventCatalog types
    domain_events: events
    bounded_contexts: domains
    aggregates: services

  schema_formats:
    - avro
    - json-schema

  generators:
    asyncapi:
      enabled: true
      version: "3.0.0"
      default_protocol: kafka

    openapi:
      enabled: true
      version: "3.1.0"

  metadata:
    default_owner: "architecture-team"
    organization: "your-company"
```

### Success Metrics

- **Automation Rate:** 90%+ of EventCatalog content auto-generated
- **Time Savings:** 80% reduction in manual documentation time
- **Documentation Coverage:** 100% of designed events documented
- **Sync Accuracy:** <1% drift between specs and EventCatalog
- **Adoption:** Used in 70%+ of new feature implementations

### Dependencies

- EventCatalog instance (self-hosted or cloud)
- SpecKit DDD templates populated
- Bash 4.0+ for script execution
- Node.js (for AsyncAPI/OpenAPI generation libraries)

### Priority

**Tier 1** - Foundational integration that enables all other EventCatalog features.

---

## Feature 1.2: EventCatalog Schema Validator

### Description

Validate SpecKit contract specifications against EventCatalog schema requirements before generation, ensuring compliance with organizational standards and EventCatalog conventions.

### Problem Statement

**Pain Point:** Teams create schemas that don't meet EventCatalog requirements, resulting in:
- Generation failures
- Invalid EventCatalog documentation
- Manual fixes and rework
- Inconsistent schema quality across teams

### Target Users

- **Developers** creating event contracts
- **Schema Owners** responsible for event definitions
- **Platform Engineers** maintaining standards
- **QA Engineers** validating specifications

### Key Capabilities

#### Pre-Generation Validation
- Check schema format compatibility (Avro, JSON Schema, Protobuf)
- Validate required metadata fields
- Ensure naming conventions compliance
- Verify version compatibility rules
- Check for reserved keywords and forbidden patterns

#### Schema Format Validation

**Avro Schemas:**
- Valid Avro syntax
- Namespace conventions
- Field naming standards
- Required documentation strings
- Logical type usage

**JSON Schemas:**
- Valid JSON Schema Draft 2020-12
- Required `$schema`, `title`, `description`
- Type definitions completeness
- Reference resolution

**Protobuf:**
- Valid proto3 syntax
- Package naming conventions
- Field number reservations
- Import resolution

#### EventCatalog Metadata Validation
- Required front matter fields present
- Valid event/service names (kebab-case)
- Owner information specified
- Version format compliance (semver)
- Tag vocabulary adherence

#### Governance Rules
- PII fields properly marked
- Retention policies specified
- Breaking change flags accurate
- Deprecation notices formatted correctly
- Consumer compatibility declarations

### Technical Approach

#### Validation Engine
```bash
#!/bin/bash
# .specify/scripts/bash/validate-eventcatalog.sh

# Validate schema files
validate_schema() {
  local schema_file=$1
  local format=$2

  case $format in
    avro)
      validate_avro_schema "$schema_file"
      ;;
    json-schema)
      validate_json_schema "$schema_file"
      ;;
    protobuf)
      validate_protobuf_schema "$schema_file"
      ;;
  esac
}

# Validate EventCatalog metadata
validate_metadata() {
  local spec_file=$1

  # Check required front matter
  check_yaml_field "$spec_file" "title"
  check_yaml_field "$spec_file" "owner"
  check_yaml_field "$spec_file" "version"

  # Validate version format
  check_semver_format "$spec_file"

  # Check naming conventions
  check_naming_conventions "$spec_file"
}
```

#### Integration Points
- Pre-commit hook validation
- `/speckit.plan` phase validation gate
- CI/CD pipeline checks
- Real-time IDE feedback (via AI agent context)

#### Validation Report Format
```json
{
  "valid": false,
  "errors": [
    {
      "severity": "error",
      "code": "MISSING_METADATA",
      "message": "Required field 'owner' missing in front matter",
      "file": "specs/001-user-registration/contracts/user-registered.md",
      "line": 1
    }
  ],
  "warnings": [
    {
      "severity": "warning",
      "code": "NAMING_CONVENTION",
      "message": "Event name 'UserRegistered' should use kebab-case: 'user-registered'",
      "file": "specs/001-user-registration/domain-events/user-registered.md",
      "line": 3
    }
  ],
  "stats": {
    "total_schemas": 5,
    "valid_schemas": 3,
    "warnings": 2,
    "errors": 2
  }
}
```

### Success Metrics

- **Validation Coverage:** 100% of schemas validated before generation
- **Error Detection:** 95%+ of invalid schemas caught pre-generation
- **False Positives:** <5% validation errors requiring override
- **Time to Validate:** <2 seconds per schema
- **Developer Satisfaction:** 4+ out of 5 rating for validation feedback clarity

### Dependencies

- Schema format validators (avro-tools, ajv, protoc)
- YAML parser for front matter extraction
- SpecKit constitution rules engine

### Priority

**Tier 1** - Critical for ensuring quality and preventing generation failures.

---

## Feature 1.3: Bi-Directional Sync

### Description

Maintain synchronization between SpecKit specifications and EventCatalog documentation, enabling changes in either location to propagate with conflict detection and resolution workflows.

### Problem Statement

**Pain Point:** After initial generation, specs and EventCatalog docs diverge because:
- EventCatalog is updated directly for quick fixes
- Specs evolve during implementation
- No mechanism to reconcile changes
- Single source of truth becomes unclear

**Impact:** Documentation debt accumulates, trust in EventCatalog erodes, manual reconciliation becomes overwhelming.

### Target Users

- **Documentation Maintainers** keeping EventCatalog current
- **Architects** evolving design specifications
- **Platform Teams** managing multiple EventCatalog instances
- **Product Owners** tracking feature evolution

### Key Capabilities

#### Change Detection

**Spec → EventCatalog Direction:**
- Monitor file changes in `specs/` directory
- Detect modifications to DDD templates
- Identify contract updates
- Track version bumps

**EventCatalog → Spec Direction:**
- Watch EventCatalog markdown files
- Detect schema changes in catalog
- Track metadata updates
- Monitor new events/services added directly

#### Sync Strategies

**One-Way Sync (Spec → EventCatalog):**
- Specs are source of truth
- EventCatalog regenerated on spec changes
- Suitable for early-stage projects
- Preserves design-driven workflow

**Two-Way Sync (Bidirectional):**
- Changes merge from both directions
- Conflict detection and resolution
- Suitable for mature projects
- Requires conflict resolution workflow

**Selective Sync:**
- Configure which artifacts sync
- Exclude certain fields from sync
- Custom merge strategies per artifact type

#### Conflict Resolution Workflow

When conflicts detected:

1. **Automatic Resolution (Safe Cases):**
   - Non-overlapping field changes → Merge automatically
   - EventCatalog-only fields (views, custom sections) → Preserve
   - Spec-only fields (implementation notes) → Preserve

2. **Manual Resolution (Conflicts):**
   - Schema structure changes in both → Flag for review
   - Version conflicts → Prompt for resolution
   - Breaking change disagreements → Escalate to architect

3. **Resolution Interface:**
   ```
   Conflict detected in: specs/001-user-registration/domain-events/user-registered.md

   Field: schema.properties.email.format
   Spec value:    "email"
   Catalog value: "idn-email"
   Last synced:   2025-11-01 14:30:00

   Choose resolution:
   [1] Keep Spec version (email)
   [2] Keep EventCatalog version (idn-email)
   [3] Manual merge
   [4] View full diff
   [5] Skip this conflict
   ```

### Technical Approach

#### Sync Daemon
```bash
#!/bin/bash
# .specify/scripts/bash/sync-eventcatalog.sh

MODE=${1:-"watch"}  # watch | once | spec-to-catalog | catalog-to-spec

sync_spec_to_catalog() {
  # Detect changed specs
  changed_specs=$(git diff --name-only HEAD~1 specs/)

  for spec in $changed_specs; do
    # Extract feature ID
    feature_id=$(extract_feature_id "$spec")

    # Regenerate EventCatalog docs
    generate_eventcatalog_docs "$feature_id"

    # Check for conflicts
    if detect_conflicts "$feature_id"; then
      prompt_conflict_resolution "$feature_id"
    fi
  done
}

sync_catalog_to_spec() {
  # Monitor EventCatalog directory
  changed_docs=$(git diff --name-only HEAD~1 eventcatalog/)

  for doc in $changed_docs; do
    # Map to spec file
    spec_file=$(map_catalog_to_spec "$doc")

    # Extract changes
    changes=$(extract_catalog_changes "$doc")

    # Apply to spec
    apply_changes_to_spec "$spec_file" "$changes"
  done
}

# Watch mode for continuous sync
if [ "$MODE" = "watch" ]; then
  while true; do
    sync_spec_to_catalog
    sync_catalog_to_spec
    sleep 30
  done
fi
```

#### Configuration

```yaml
# .specify/config/eventcatalog-sync.config.yml
sync:
  enabled: true
  mode: bidirectional  # one-way-spec | one-way-catalog | bidirectional
  interval: 30  # seconds

  conflict_resolution:
    strategy: prompt  # auto | prompt | spec-wins | catalog-wins
    auto_merge_safe: true

  exclude_from_sync:
    # Fields that don't sync from catalog to spec
    catalog_to_spec:
      - visualizations
      - custom_sections
      - view_counts

    # Fields that don't sync from spec to catalog
    spec_to_catalog:
      - implementation_notes
      - internal_todos

  notifications:
    on_conflict: true
    on_sync_complete: false
    channels:
      - slack
      - email
```

### Success Metrics

- **Sync Reliability:** 99.9% successful sync operations
- **Conflict Rate:** <10% of syncs require manual resolution
- **Resolution Time:** <5 minutes average time to resolve conflicts
- **Drift Reduction:** 90% reduction in spec-catalog divergence
- **Developer Confidence:** 85%+ trust EventCatalog as source of truth

### Dependencies

- File system watchers (fswatch, inotify)
- Git for change detection
- EventCatalog CLI or API
- Conflict resolution UI/CLI
- Feature 1.1 (EventCatalog Generator)

### Priority

**Tier 3** - Strategic feature for mature implementations after basic generation is working.

---

## Implementation Roadmap

### Phase 1: Foundation (Month 1-2)
- Implement Feature 1.1 (EventCatalog Generator Plugin)
- Implement Feature 1.2 (Schema Validator)
- Basic one-way sync (spec → catalog)

### Phase 2: Enhancement (Month 3-4)
- Add support for all DDD templates
- Implement conflict detection
- Create validation rule library

### Phase 3: Advanced (Month 5-6)
- Implement Feature 1.3 (Bi-Directional Sync)
- Build conflict resolution UI
- Add real-time sync capabilities

## Related Features

- **Feature 2.1:** Schema-First Workflow (uses validator)
- **Feature 5.1:** AsyncAPI Code Generator (shares spec parsing)
- **Feature 8.1:** API Documentation Generator (similar generation logic)
- **Feature 9.3:** Event Catalog Drift Detection (uses sync mechanisms)

## Resources

- [EventCatalog CLI Documentation](https://www.eventcatalog.dev/docs/cli)
- [AsyncAPI Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- [Avro Schema Specification](https://avro.apache.org/docs/current/spec.html)
- [SpecKit DDD Templates](.specify/templates/ddd/)

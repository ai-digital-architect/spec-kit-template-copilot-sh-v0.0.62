# ============================================================
# FILE: context-map-template.md
# ============================================================
---
title: "Context Map: [System Name]"
version: "1.0.0"
date: "YYYY-MM-DD"
status: "draft | review | approved"
---

# Context Map: [System Name]

## Overview
[Brief description of the overall system and its domain landscape]

## Bounded Contexts

### [Bounded Context Name 1]
- **Type**: Core | Supporting | Generic
- **Team**: [Team Name]
- **Technology**: [Tech stack]
- **Purpose**: [Single responsibility statement]

### [Bounded Context Name 2]
- **Type**: Core | Supporting | Generic
- **Team**: [Team Name]
- **Technology**: [Tech stack]
- **Purpose**: [Single responsibility statement]

[Repeat for all contexts]

## Context Relationships

### [Upstream Context] → [Downstream Context]

**Pattern**: Customer-Supplier | Conformist | Shared Kernel | ACL | OHS | Published Language

**Description**: [Why this relationship exists and what flows between contexts]

**Contract**:
- **Type**: REST API | Events | Shared Library | gRPC | GraphQL
- **Location**: [Path to contract specification]
- **Versioning**: [Strategy]

**Governance**:
- **Upstream Rights**: [What upstream can change unilaterally]
- **Downstream Rights**: [What downstream can influence]
- **Change Process**: [How changes are negotiated/communicated]

**Integration Points**:
- [Specific API endpoints, events, or shared modules]

[Repeat for all relationships]

## Strategic Patterns Summary

| Upstream | Downstream | Pattern | Contract | Maturity |
|----------|------------|---------|----------|----------|
| [Context A] | [Context B] | Customer-Supplier | REST API | Stable |
| [Context C] | [Context D] | Conformist | Events | Evolving |

## Organizational Alignment

| Bounded Context | Team | Deployment | Data Store |
|-----------------|------|------------|------------|
| [Context A] | [Team 1] | [Independent/Shared] | [Database] |
| [Context B] | [Team 2] | [Independent/Shared] | [Database] |

## Evolution & Migration Notes

[Describe planned changes to context boundaries or relationships]

- **Short-term** (0-3 months): [Planned changes]
- **Medium-term** (3-12 months): [Planned changes]
- **Long-term** (12+ months): [Vision]

## Open Questions

1. [Question about context boundary]
2. [Question about relationship pattern]

## References

- [Link to detailed bounded context specifications]
- [Link to API contracts]
- [Link to architecture decision records]

---
# ============================================================
# FILE: bounded-context-template.md
# ============================================================
---
title: "Bounded Context: [Context Name]"
domain: "[Parent Domain]"
type: "core | supporting | generic"
version: "1.0.0"
status: "draft | review | approved"
team: "[Team Name]"
---

# Bounded Context: [Context Name]

## Purpose & Scope

**Purpose**: [Single, clear responsibility statement]

**In Scope**:
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Explicitly Out of Scope**:
- [What this context does NOT handle]
- [Boundaries with other contexts]

## Ubiquitous Language

| Term | Definition | Aliases | Notes |
|------|------------|---------|-------|
| [Term 1] | [Context-specific definition] | [Alt names] | [Usage notes] |
| [Term 2] | [Context-specific definition] | [Alt names] | [Usage notes] |

## Strategic Context

**Domain**: [Core, Supporting, or Generic]

**Business Value**: [Why this context matters to the business]

**Change Cadence**: [How frequently requirements change: High/Medium/Low]

**Team Ownership**: [Team name and contact]

## Relationships

### Upstream Dependencies
| Context | Pattern | Contract | Critical? |
|---------|---------|----------|-----------|
| [Context A] | [Pattern] | [API/Events] | Yes/No |

### Downstream Consumers
| Context | Pattern | Contract | Critical? |
|---------|---------|----------|-----------|
| [Context B] | [Pattern] | [API/Events] | Yes/No |

### Partnerships
| Context | Pattern | Shared Elements |
|---------|---------|-----------------|
| [Context C] | Shared Kernel | [Shared models/libs] |

## Aggregates

### [Aggregate Name 1]
- **Root Entity**: [Entity Name]
- **Purpose**: [Why this aggregate exists]
- **Key Invariants**: [Rules that must always be true]
- **See**: [Link to aggregate-[name].md]

### [Aggregate Name 2]
- **Root Entity**: [Entity Name]
- **Purpose**: [Why this aggregate exists]
- **Key Invariants**: [Rules that must always be true]
- **See**: [Link to aggregate-[name].md]

## Domain Services

### [Service Name]
- **Purpose**: [What business logic this encapsulates]
- **Operations**: [Key operations]
- **Stateless**: Yes
- **See**: [Link to domain-services-[name].md]

## Application Services

### [Service Name]
- **Purpose**: [What workflow this orchestrates]
- **Coordinates**: [Which aggregates/services]
- **See**: [Link to application-services-[name].md]

## Events & Commands

**Commands** (Intent to change state):
- [CommandName]: [Brief description]
- [CommandName]: [Brief description]

**Domain Events** (Facts about what happened):
- [EventName]: [Brief description]
- [EventName]: [Brief description]

**See**: [Link to events-and-commands-[context].md]

## APIs & Contracts

### [API Name]
- **Style**: REST | gRPC | GraphQL | Event-Driven
- **Contract**: [Link to OpenAPI/AsyncAPI/MDSL spec]
- **Versioning**: [Strategy]
- **Authentication**: [Method]

## Consistency & Transactions

**Internal Consistency**: Strong | Eventual | Mixed

**Transaction Boundaries**: [Description of what's updated atomically]

**Cross-Aggregate Consistency**: Eventual (via domain events)

**Idempotency**: [Strategy for ensuring operations are idempotent]

**See**: [Link to consistency-[context].md]

## Non-Functional Constraints

| Category | Requirement | Rationale | Design Impact |
|----------|-------------|-----------|---------------|
| Performance | [e.g., <100ms p99] | [Why] | [How design addresses] |
| Scalability | [e.g., 10K req/s] | [Why] | [How design addresses] |
| Security | [e.g., PCI compliance] | [Why] | [How design addresses] |

## Technology Choices

- **Language/Framework**: [e.g., Java/Spring Boot]
- **Data Store**: [e.g., PostgreSQL]
- **Messaging**: [e.g., Kafka, RabbitMQ]
- **Deployment**: [e.g., Kubernetes, serverless]

## Testing Strategy

- **Unit Tests**: [Aggregate invariants, domain logic]
- **Integration Tests**: [Repository, external APIs]
- **Contract Tests**: [APIs consumed by other contexts]
- **Event Tests**: [Event publishing/handling]

## References

- [Link to aggregate specifications]
- [Link to API contracts]
- [Link to architecture decision records]
- [Link to context map]

---

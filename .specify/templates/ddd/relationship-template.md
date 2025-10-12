# ============================================================
# FILE: relationship-template.md
# ============================================================
---
title: "Context Relationship: [Upstream] → [Downstream]"
pattern: "[Pattern Name]"
version: "1.0.0"
status: "draft | review | approved"
---

# Context Relationship: [Upstream Context] → [Downstream Context]

## Pattern

**Type**: Customer-Supplier | Conformist | Shared Kernel | Anti-Corruption Layer | Open Host Service | Published Language

## Participants

**Upstream Context**: [Context Name]
- **Role**: Provides services/events
- **Team**: [Team Name]

**Downstream Context**: [Context Name]
- **Role**: Consumes services/events
- **Team**: [Team Name]

## Rationale

[Why this relationship exists and why this pattern was chosen]

## Integration Contract

### Type
[REST API | Events | Shared Library | gRPC | GraphQL]

### Contract Location
[Link to OpenAPI spec, AsyncAPI spec, or code]

### Version
Current: v1.0

## Pattern Details

### [Customer-Supplier]
**Characteristics**:
- Downstream depends on upstream
- Upstream provides services
- Negotiated contract between teams
- Upstream must consider downstream needs

**Governance**:
- **Upstream Commitments**: [What upstream guarantees]
- **Downstream Rights**: [What downstream can influence]
- **Change Process**: [How changes are negotiated]

### [Conformist]
**Characteristics**:
- Downstream conforms to upstream model
- No negotiation power
- Upstream changes unilaterally

**Implications**:
- Downstream must adapt to upstream changes
- Risk: Breaking changes from upstream

### [Shared Kernel]
**Characteristics**:
- Small, carefully managed shared subset
- Both contexts depend on shared code/model
- High coordination required

**Shared Elements**:
- [Shared model classes]
- [Shared value objects]
- [Shared utilities]

**Governance**:
- Changes require consensus
- Shared codebase or repository

### [Anti-Corruption Layer (ACL)]
**Characteristics**:
- Downstream translates upstream concepts
- Protects downstream from upstream changes
- Maintains autonomy

**Translation**:
- Upstream model → ACL → Downstream model

**Components**:
- Adapters
- Facades
- Translators

### [Open Host Service (OHS)]
**Characteristics**:
- Upstream provides well-documented, stable API
- Designed for multiple consumers
- Versioned and backward compatible

**API**: [Link to API documentation]

### [Published Language]
**Characteristics**:
- Standardized integration language
- Well-documented schemas
- Often used with OHS

**Schema**: [Link to schema definitions]

## Integration Points

### Data Flow
[What data flows from upstream to downstream]

### Synchronization
**Frequency**: Real-time | Batch | Event-driven

**Mechanism**: API calls | Message queue | Shared database (not recommended)

## Contract Details

### Upstream Provides

#### APIs (if applicable)
- **Endpoint**: `POST /v1/resource`
- **Purpose**: [What operation]
- **SLA**: [Response time, availability]

#### Events (if applicable)
- **Event**: [EventName]
- **Topic**: `[topic-name]`
- **Schema**: [Link to schema]
- **Delivery Guarantee**: At-least-once | Exactly-once

### Downstream Consumes

**Consumption Pattern**: [Polling | Push | Subscribe]

**Error Handling**: [How downstream handles failures]

**Retry Policy**: [Exponential backoff, max attempts]

## Versioning

**Strategy**: [Semantic versioning, backward compatibility]

**Breaking Changes**: [How handled - new version, deprecation period]

**Deprecation Policy**: [Notice period, migration support]

## Governance

**Change Ownership**:
- **Upstream Can Change**: [What they control]
- **Downstream Can Influence**: [What they can request]

**Change Process**:
1. [Proposal]
2. [Review]
3. [Approval]
4. [Implementation]
5. [Migration]

**Communication Channel**: [Slack, email, meetings]

## Testing

**Contract Tests**: [Pact, Spring Cloud Contract, etc.]

**Test Ownership**:
- Upstream: Provides contract
- Downstream: Verifies contract

## Failure Scenarios

| Scenario | Impact on Downstream | Mitigation |
|----------|----------------------|------------|
| Upstream API down | [Impact] | [Fallback, cache, circuit breaker] |
| Upstream breaking change | [Impact] | [Versioning, ACL] |
| Event delivery failure | [Impact] | [Retry, dead letter queue] |

## SLA

**Upstream Commitments**:
- Availability: [99.9%]
- Response Time: [p95 < 200ms]
- Breaking Change Notice: [30 days]

**Downstream Expectations**:
- Handle at-least-once delivery
- Implement retry logic
- Monitor upstream health

## Evolution

**Current State**: [Description]

**Planned Changes**:
- [Change 1]
- [Change 2]

**Migration Plan**: [If pattern or contract is changing]

## References

- [Link to upstream context]
- [Link to downstream context]
- [Link to contract specification]
- [Link to context map]

---

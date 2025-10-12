# ============================================================
# FILE: domain-service-template.md
# ============================================================
---
title: "Domain Service: [Service Name]"
context: "[Bounded Context Name]"
version: "1.0.0"
type: "domain-service"
---

# Domain Service: [Service Name]

## Purpose

[Why this service exists - what domain logic doesn't naturally fit in an entity or value object]

## Characteristics

- **Stateless**: Yes (no instance state)
- **Pure Domain Logic**: Yes (no infrastructure concerns)
- **Operates On**: [Which entities/value objects/aggregates]
- **Layer**: Domain Layer

## When to Use a Domain Service

Use a domain service when:
- Operation spans multiple aggregates
- Logic doesn't naturally belong to any one entity
- Requires domain knowledge but is conceptually a standalone operation
- Represents a domain process or transformation

## Operations

### [Operation Name]
```
method(param1: Type, param2: Type): Result<ReturnType, Error>
```

**Intent**: [What business operation this represents]

**Domain Logic**: [What domain rules or calculations are applied]

**Parameters**:
- `param1`: [Purpose and constraints]
- `param2`: [Purpose and constraints]

**Returns**: [What is returned and what it means]

**Preconditions**:
- [What must be true before calling]

**Postconditions**:
- [What's guaranteed after successful execution]

**Business Rules Applied**:
1. [Rule 1]
2. [Rule 2]

**Domain Events** (if any):
- [EventName]: [When and why published]

**Invariants Enforced**:
- [Which aggregate or cross-aggregate invariants]

**Example**:
```
Given: [Input state]
When: service.method(arg1, arg2)
Then: [Output state or result]
```

[Repeat for all operations]

## Dependencies

### Domain Layer Dependencies (OK)
- **Aggregates**: [[AggregateA], [AggregateB]]
- **Entities**: [[Entity1], [Entity2]]
- **Value Objects**: [[VO1], [VO2]]
- **Other Domain Services**: [[Service1]]
- **Domain Events**: [[Event1], [Event2]]

### NO Infrastructure Dependencies
- ❌ No repositories directly
- ❌ No databases or external APIs
- ❌ No frameworks (except domain-focused libraries)

**Note**: If infrastructure is needed, inject via **application service** or use **ports (interfaces)** in domain, implemented in infrastructure layer.

## Collaborations

### With Aggregates
- **[Aggregate A]**: [How they interact - service calls aggregate methods]
- **[Aggregate B]**: [How they interact]

### With Other Domain Services
- **[Service A]**: [How they collaborate]

### With Policies (Reactive Logic)
- **[Policy A]**: [Domain service may be invoked by policy in response to event]

## Domain Logic Examples

### Example 1: [Scenario]
```
// Example code showing domain logic
const result = transferService.transfer(fromAccount, toAccount, amount);

// Domain rules:
// - fromAccount must have sufficient balance
// - amount must be positive
// - currency must match or be convertible
// - transfer creates MoneyTransferred event
```

### Example 2: [Scenario]
```
// Another example
```

## Comparison with Application Service

| Aspect | Domain Service | Application Service |
|--------|----------------|---------------------|
| **Concern** | Domain logic | Orchestration |
| **Stateless** | Yes | Yes |
| **Dependencies** | Domain objects only | Domain + Infrastructure |
| **Transaction** | No | Yes (manages) |
| **Events** | May publish | Commits events to store |
| **Layer** | Domain | Application |

## Testing Strategy

- **Unit Tests**: Domain logic in isolation with mock/stub aggregates
- **Property-Based Tests**: Domain rules hold for random inputs
- **Example-Based Tests**: Known scenarios with expected outcomes

## Design Decisions

**Why Not in Entity/Aggregate?**
[Justification for why this logic is a separate service]

**Why Not Application Service?**
[This is pure domain logic, not orchestration]

**Alternatives Considered**:
- [Alternative 1 and why it was rejected]
- [Alternative 2 and why it was rejected]

## References

- [Link to aggregates used]
- [Link to bounded context]
- [Link to domain events]

---
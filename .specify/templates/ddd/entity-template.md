# ============================================================
# FILE: entity-template.md
# ============================================================
---
title: "Entity: [Entity Name]"
context: "[Bounded Context Name]"
aggregate: "[Aggregate Name]"
version: "1.0.0"
---

# Entity: [Entity Name]

## Definition

[1-2 sentence description of what this entity represents in the domain]

## Identity

**Unique Identifier**: [Field name and type, e.g., orderId: UUID]

**Identity Generation**: [How IDs are created: auto-increment, UUID, domain-specific]

**Identity Immutability**: [Can ID change? Usually no]

## Attributes

| Attribute | Type | Mutable | Required | Default | Validation |
|-----------|------|---------|----------|---------|------------|
| [attr1] | [type] | Yes/No | Yes/No | [value] | [rules] |
| [attr2] | [type] | Yes/No | Yes/No | [value] | [rules] |

### Attribute Details

#### [Attribute Name]
- **Purpose**: [Why this attribute exists]
- **Constraints**: [Min/max, format, referential integrity]
- **Business Rules**: [Domain-specific rules]

[Repeat for complex attributes]

## Lifecycle

**Creation**: [How instances are created]
- Via: [Factory | Constructor | Repository]
- Required Data: [Minimum data needed]
- Initial State: [Default state]

**State Transitions**:
```
[State 1] --[action/event]--> [State 2] --[action/event]--> [State 3]
```

**Termination**: [Can entity be deleted? Soft delete? Hard delete?]

## Behaviors

### [Method Name]
```
method(param1: Type, param2: Type): ReturnType
```
- **Intent**: [What business operation this represents]
- **Preconditions**: [What must be true before calling]
- **Postconditions**: [What's guaranteed after execution]
- **Side Effects**: [State changes, events published]
- **Invariants Enforced**: [Which aggregate invariants this protects]

[Repeat for all methods]

## Relationships

### Within Aggregate
- **Contains**: [[ValueObject], [ChildEntity]]
- **References**: [[OtherEntity] via [field]]

### Across Aggregates
- **References by ID Only**: [[AggregateRoot] via [aggregateId: UUID]]
- **Coordination**: [Via events, not direct calls]

## Validation Rules

### Business Rules
1. [Rule 1: e.g., "quantity must be positive"]
2. [Rule 2: e.g., "status transitions must follow state machine"]

### Technical Constraints
1. [Constraint 1: e.g., "email must be valid format"]
2. [Constraint 2: e.g., "maximum length 255 characters"]

## Events

### Published Events
- **[EventName]**: [When this is published, what data included]

### Consumed Events
- **[EventName]**: [How this entity reacts to external events]

## Persistence Mapping

**Table/Collection**: [Database table or collection name]

**Primary Key**: [Field(s)]

**Indexes**: [Fields that should be indexed]

**Relationships**: [Foreign keys, joins, embedded documents]

## Examples

### Example 1: Valid Instance
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "field1": "value1",
  "field2": 42,
  "status": "ACTIVE",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

### Example 2: State Transition
```
Given: Entity in state "PENDING"
When: approve() is called
Then: State changes to "APPROVED", ApprovedEvent is published
```

## Design Decisions

**Why Entity (not Value Object)?**
[Justification: has identity, mutable, lifecycle matters]

**Why in This Aggregate?**
[Justification: invariants, transactional consistency needs]

## References

- [Link to aggregate]
- [Link to value objects]
- [Link to domain events]

---
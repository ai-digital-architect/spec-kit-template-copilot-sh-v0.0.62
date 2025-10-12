# ============================================================
# FILE: aggregate-template.md
# ============================================================
---
title: "Aggregate: [Aggregate Name]"
context: "[Bounded Context Name]"
root: "[Root Entity Name]"
version: "1.0.0"
status: "draft | review | approved"
---

# Aggregate: [Aggregate Name]

## Purpose

[Why this aggregate exists and what business concept it represents]

## Aggregate Root

**Entity**: [Root Entity Name]

**Identity**: [How instances are uniquely identified]

**Lifecycle**: [Creation → States → Termination]

## Structure

```
[AggregateRoot]
├── [Entity1]
│   └── [ValueObject1]
├── [Entity2]
└── [ValueObject2]
```

## Invariants

Business rules that MUST always be true within this aggregate:

1. **[Invariant Name]**
   - **Rule**: [Precise statement of the rule]
   - **Enforcement Point**: [Where/when this is checked]
   - **Violation Outcome**: [What happens if violated]

2. **[Invariant Name]**
   - **Rule**: [Precise statement of the rule]
   - **Enforcement Point**: [Where/when this is checked]
   - **Violation Outcome**: [What happens if violated]

## Transaction Boundary

**Scope**: [What's included in a single atomic transaction]

**Consistency**: Strong (within aggregate boundary)

**Concurrency**: [Optimistic locking | Pessimistic locking | Version-based]

## Entities

### [Entity Name]
- **Identity**: [ID field(s)]
- **Attributes**: [Key attributes with types]
- **Behaviors**: [Key methods]
- **Lifecycle**: [State transitions]
- **See**: [Link to entity-[name].md]

[Repeat for all entities]

## Value Objects

### [Value Object Name]
- **Attributes**: [All attributes with types]
- **Immutable**: Yes
- **Validation**: [Rules for valid instances]
- **Behaviors**: [Methods, if any]
- **See**: [Link to value-object-[name].md]

[Repeat for all value objects]

## Behavior

### Commands Accepted

#### [CommandName]
- **Intent**: [What the user/system wants to do]
- **Preconditions**: [What must be true before execution]
- **Payload**: 
  ```json
  {
    "aggregateId": "string",
    "field1": "type",
    "field2": "type"
  }
  ```
- **Validation**: [Business rules checked]
- **Outcome**: [Success event(s) or failure scenarios]
- **Handler**: [Method name on aggregate root]

[Repeat for all commands]

### Events Published

#### [EventName]
- **Triggered By**: [Which command or state change]
- **Intent**: [What happened]
- **Payload**:
  ```json
  {
    "aggregateId": "string",
    "aggregateVersion": "integer",
    "field1": "type",
    "field2": "type",
    "metadata": {
      "eventId": "string",
      "correlationId": "string",
      "causationId": "string",
      "timestamp": "ISO 8601"
    }
  }
  ```
- **Consumers**: [Policies, sagas, other contexts]

[Repeat for all events]

## Repository

**Interface**: [Repository name]

**Methods**:
- `findById(id: AggregateId): Aggregate | null`
- `save(aggregate: Aggregate): void`
- `delete(id: AggregateId): void`
- [Additional query methods if needed]

**Implementation Notes**: [Technology, caching strategy, etc.]

## Factory

**Factory**: [Factory name, if complex construction needed]

**Creation Rules**:
- [Rule 1 for valid initial state]
- [Rule 2 for valid initial state]

**Factory Method**: `create(...): Aggregate`

## Cross-Aggregate Coordination

**Other Aggregates Involved**:
- [Aggregate B]: [How coordination happens - via events, saga, etc.]

**Eventual Consistency**:
- [Event X] triggers [Policy/Saga Y] which coordinates with [Aggregate Z]

## State Diagram

```
[Initial State]
    |
    v
[State 1] --[Event A]--> [State 2]
    |
    +--[Event B]--> [State 3]
                        |
                        v
                   [Terminal State]
```

## Design Decisions

### Size & Boundary Rationale
[Why this aggregate includes what it does and excludes what it doesn't]

### Performance Considerations
[Caching, query optimization, denormalization needs]

### Scalability Considerations
[Sharding strategy, if applicable]

## Examples

### Example 1: [Scenario Name]
```
Given: [Initial state]
When: [Command is executed]
Then: [Expected outcome and events]
```

### Example 2: [Scenario Name]
```
Given: [Initial state]
When: [Command is executed]
Then: [Expected outcome and events]
```

## Testing Strategy

- **Unit Tests**: Invariant enforcement, state transitions, command validation
- **Integration Tests**: Repository persistence, event publishing
- **Property-Based Tests**: Invariant preservation across random command sequences

## References

- [Link to entities]
- [Link to value objects]
- [Link to domain events]
- [Link to bounded context]

---

---

# ============================================================
# FILE: consistency-template.md
# ============================================================
---
title: "Consistency Model: [Bounded Context Name]"
context: "[Bounded Context Name]"
version: "1.0.0"
---

# Consistency Model: [Bounded Context Name]

## Overview

[High-level description of consistency strategy for this bounded context]

## Consistency Guarantees

### Within Aggregate
**Model**: Strong Consistency

**Mechanism**: Single database transaction

**Scope**: Aggregate root + all child entities/value objects

**ACID Properties**: ✅ Atomicity, ✅ Consistency, ✅ Isolation, ✅ Durability

**Example**:
```
Order aggregate:
- Order (root)
- OrderLines (children)
- Updated atomically in single transaction
- All invariants enforced before commit
```

### Across Aggregates (Same Context)
**Model**: Eventual Consistency

**Mechanism**: Domain events + event handlers (policies/sagas)

**Timing**: [Immediate after transaction | Async via message queue]

**Example**:
```
OrderPlaced event
→ (eventually) triggers ReserveInventory
→ (eventually) StockReserved event
```

### Across Bounded Contexts
**Model**: Eventual Consistency (always)

**Mechanism**: Published domain events via message broker

**Delivery Guarantee**: At-least-once

**Idempotency**: Required in all consumers

**Example**:
```
Order Context: OrderPlaced event
→ Inventory Context: ReserveStock command
→ Payment Context: AuthorizePayment command
```

## Transaction Boundaries

### Transaction 1: [Name]
**Scope**: [What's included]

**Aggregates Involved**: [[Aggregate1]]

**Duration**: [Expected duration]

**Example**:
```sql
BEGIN TRANSACTION;
  -- Update Order
  -- Update OrderLines
  -- Add OrderPlaced event to outbox
COMMIT;
```

### Transaction 2: [Name]
[Repeat for each transaction boundary]

## Event-Driven Consistency

### Transactional Outbox Pattern
**Problem**: Ensure events are published reliably after transaction commit

**Solution**: Store events in database table (outbox) in same transaction

**Process**:
1. Business logic updates aggregates
2. Domain events written to `outbox` table
3. Transaction commits
4. Background worker polls outbox and publishes to message broker
5. Events marked as published

**Outbox Table**:
```sql
CREATE TABLE outbox (
  event_id UUID PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  event_type VARCHAR(255) NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMP NOT NULL,
  published_at TIMESTAMP
);
```

### Event Sourcing (if applicable)
**Store**: All state changes as events

**Replay**: Rebuild aggregate state by replaying events

**Consistency**: Strong consistency within event store; eventual elsewhere

## Idempotency

### Commands
**Idempotency Key**: [commandId | custom key in payload]

**Implementation**: Store processed command IDs; reject duplicates

**Example**:
```typescript
if (await processedCommands.exists(command.commandId)) {
  return cached result;
}
// Execute command
await processedCommands.add(command.commandId, result);
return result
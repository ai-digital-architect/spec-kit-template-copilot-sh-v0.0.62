# ============================================================
# FILE: domain-event-template.md
# ============================================================
---
title: "Domain Event: [EventName]"
context: "[Bounded Context Name]"
aggregate: "[Source Aggregate]"
version: "1.0.0"
---

# Domain Event: [EventName]

## Definition

[What happened - described as a past-tense fact]

## Event Type

**Category**: [Business Event | System Event | Integration Event]

**Scope**: [Within Context | Cross-Context]

## Source

**Aggregate**: [Which aggregate publishes this event]

**Triggered By**: [Command or action that causes this event]

**Timing**: [Immediately after state change | Async after transaction commit]

## Intent

[Why this event matters - what business fact it represents]

## Payload Schema

### Version 1.0
```json
{
  "eventId": "uuid",
  "eventType": "[EventName]",
  "aggregateId": "uuid",
  "aggregateType": "[AggregateName]",
  "aggregateVersion": 1,
  "occurredAt": "2025-01-15T10:30:00Z",
  "data": {
    "field1": "value",
    "field2": 42,
    "nestedObject": {
      "field3": "value"
    }
  },
  "metadata": {
    "correlationId": "uuid",
    "causationId": "uuid",
    "userId": "uuid",
    "tenantId": "uuid"
  }
}
```

### Data Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| field1 | string | Yes | [Purpose] |
| field2 | integer | Yes | [Purpose] |
| nestedObject | object | No | [Purpose] |

## Metadata

**Correlation ID**: [Tracks related events across workflow]

**Causation ID**: [ID of event/command that caused this event]

**User ID**: [Who initiated the action]

**Tenant ID**: [Multi-tenancy support, if applicable]

## Consumers

### Within Bounded Context
- **[Policy 1]**: [How it reacts]
- **[Saga 1]**: [How it participates in workflow]

### Cross-Context
- **[Other Context 1]**: [How it consumes this event]
- **[Other Context 2]**: [How it consumes this event]

## Guarantees

**Delivery**: At-least-once | Exactly-once | At-most-once

**Ordering**: [Per aggregate | Global | None]

**Idempotency**: [How consumers handle duplicates]

**Retry**: [Retry policy if consumer fails]

## Versioning

**Current Version**: 1.0

**Breaking Changes**: [List any breaking changes from previous versions]

**Schema Evolution Strategy**:
- **Backward Compatible**: Add optional fields
- **Breaking Change**: Create new event type or new version

**Deprecation Policy**: [How old versions are phased out]

## Publishing

**Technology**: [Kafka, RabbitMQ, EventBridge, etc.]

**Topic/Queue**: `[topic-name]`

**Partitioning**: [Partition by aggregateId for ordering]

**Serialization**: JSON | Avro | Protobuf

## Example

### Scenario: [Description]
```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "eventType": "OrderPlaced",
  "aggregateId": "order-12345",
  "aggregateType": "Order",
  "aggregateVersion": 1,
  "occurredAt": "2025-01-15T10:30:00Z",
  "data": {
    "customerId": "cust-789",
    "orderTotal": {
      "amount": 150.00,
      "currency": "USD"
    },
    "lineItems": [
      {
        "productId": "prod-1",
        "quantity": 2,
        "price": { "amount": 50.00, "currency": "USD" }
      },
      {
        "productId": "prod-2",
        "quantity": 1,
        "price": { "amount": 50.00, "currency": "USD" }
      }
    ],
    "shippingAddress": {
      "street": "123 Main St",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62701"
    }
  },
  "metadata": {
    "correlationId": "checkout-session-abc",
    "causationId": "command-place-order-xyz",
    "userId": "user-456",
    "tenantId": "tenant-1"
  }
}
```

## Handler Examples

### Policy (Synchronous Reaction)
```typescript
// Within same context
@OnEvent('OrderPlaced')
class SendOrderConfirmationPolicy {
  handle(event: OrderPlacedEvent): void {
    // Synchronous side effect
    emailService.sendOrderConfirmation(event.data.customerId, event.aggregateId);
  }
}
```

### Saga Step (Workflow Coordination)
```typescript
// Cross-context coordination
@OnEvent('OrderPlaced')
class CheckoutSaga {
  handle(event: OrderPlacedEvent): void {
    // Next step in workflow
    this.sendCommand('ReserveInventory', {
      orderId: event.aggregateId,
      lineItems: event.data.lineItems
    });
  }
}
```

### External Consumer (Another Context)
```typescript
// In Inventory context
@OnEvent('OrderPlaced')
class InventoryReservationHandler {
  async handle(event: OrderPlacedEvent): Promise {
    // Idempotency check
    if (await this.alreadyProcessed(event.eventId)) return;
    
    // Reserve inventory
    for (const item of event.data.lineItems) {
      await this.inventoryService.reserve(item.productId, item.quantity);
    }
    
    // Mark as processed
    await this.markProcessed(event.eventId);
  }
}
```

## Testing

### Unit Tests
- Schema validation
- Serialization/deserialization
- Field constraints

### Integration Tests
- Publishing to message broker
- Consumer receives event
- Idempotency handling

### Contract Tests
- Verify consumers can parse schema
- Detect breaking changes

## Design Decisions

**Why This Event?**
[Justification for event existence and granularity]

**Data Included vs. Referenced**:
- **Included**: [Which data is in payload]
- **Referenced**: [Which data consumers must fetch separately]

**Rationale**: [Why these choices - balance between completeness and size]

## References

- [Link to aggregate that publishes this]
- [Link to commands that trigger this]
- [Link to policies that react to this]
- [Link to sagas that coordinate on this]

---
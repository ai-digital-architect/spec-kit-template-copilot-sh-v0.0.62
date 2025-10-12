# ============================================================
# FILE: command-template.md
# ============================================================
---
title: "Command: [CommandName]"
context: "[Bounded Context Name]"
aggregate: "[Target Aggregate]"
version: "1.0.0"
---

# Command: [CommandName]

## Definition

[What the user/system intends to do - imperative statement]

## Intent

[Why this command exists - what business goal it serves]

## Target

**Aggregate**: [Which aggregate handles this command]

**Handler**: [Application service or aggregate method]

## Payload Schema

```json
{
  "commandId": "uuid",
  "commandType": "[CommandName]",
  "aggregateId": "uuid",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "field1": "value",
    "field2": 42
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

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| field1 | string | Yes | [Rules] |
| field2 | integer | Yes | [Range, constraints] |

## Validation

### Syntactic Validation (Structure)
- [Rule 1: e.g., "field1 must not be empty"]
- [Rule 2: e.g., "field2 must be positive"]

### Semantic Validation (Business Rules)
- [Rule 1: e.g., "aggregate must be in PENDING state"]
- [Rule 2: e.g., "user must have permission"]

## Preconditions

**Aggregate State**:
- [What state aggregate must be in]

**Permissions**:
- [Who can execute this command]

**External Constraints**:
- [Any dependencies on other systems/data]

## Execution Flow

1. **Receive Command**: [From API, message queue, etc.]
2. **Validate**: [Check structure and business rules]
3. **Load Aggregate**: [From repository]
4. **Execute**: [Call aggregate method]
5. **Persist**: [Save updated aggregate]
6. **Publish Events**: [Emit resulting domain events]
7. **Return**: [Success/failure response]

## Outcomes

### Success
- **Events Published**: [[EventName1], [EventName2]]
- **State Change**: [How aggregate state changes]
- **Response**: [What's returned to caller]

### Failure Scenarios

| Scenario | Reason | Error Code | User Message |
|----------|--------|------------|--------------|
| [Scenario 1] | [Why] | [CODE] | [User-friendly message] |
| [Scenario 2] | [Why] | [CODE] | [User-friendly message] |

## Idempotency

**Strategy**: [How duplicate commands are handled]

**Idempotency Key**: [commandId | custom key]

**Duplicate Detection**: [How system knows command was already processed]

**Result**: [Duplicate commands return same result without re-executing]

## Authorization

**Required Role**: [User role or permission needed]

**Resource Ownership**: [Must user own the aggregate?]

**Policy**: [Policy-based authorization if applicable]

## Example

### Scenario: [Description]

**Command**:
```json
{
  "commandId": "cmd-12345",
  "commandType": "PlaceOrder",
  "aggregateId": "order-67890",
  "timestamp": "2025-01-15T10:30:00Z",
  "data": {
    "customerId": "cust-111",
    "lineItems": [
      { "productId": "prod-1", "quantity": 2 },
      { "productId": "prod-2", "quantity": 1 }
    ],
    "shippingAddress": {
      "street": "123 Main St",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62701"
    }
  },
  "metadata": {
    "correlationId": "session-abc",
    "causationId": "cart-checkout-xyz",
    "userId": "user-456",
    "tenantId": "tenant-1"
  }
}
```

**Result**:
```json
{
  "success": true,
  "orderId": "order-67890",
  "events": ["OrderPlaced"]
}
```

## Handler Implementation (Pseudocode)

```typescript
class PlaceOrderHandler {
  async handle(command: PlaceOrderCommand): Promise {
    // 1. Validate
    this.validate(command);
    
    // 2. Load aggregate (or create new)
    const order = await this.orderFactory.create(
      command.data.customerId,
      command.data.lineItems,
      command.data.shippingAddress
    );
    
    // 3. Execute domain logic
    order.place(); // Emits OrderPlaced event
    
    // 4. Persist
    await this.orderRepo.save(order);
    
    // 5. Publish events
    await this.eventBus.publish(order.domainEvents);
    
    // 6. Return result
    return order.id;
  }
}
```

## Testing

### Unit Tests
- Validation logic
- Success and failure paths
- Idempotency

### Integration Tests
- Full command execution flow
- Event publishing
- Database persistence

### Contract Tests
- API clients can send valid commands
- Command schema is backward compatible

## Design Decisions

**Why This Command?**
[Justification for command existence and granularity]

**Synchronous vs. Asynchronous**:
- [Is command handled synchronously (API) or asynchronously (queue)?]
- [Rationale]

**Coarse-Grained vs. Fine-Grained**:
- [Does command handle entire workflow or single step?]
- [Rationale]

## References

- [Link to aggregate]
- [Link to events published]
- [Link to application service]
- [Link to API endpoint documentation]

---
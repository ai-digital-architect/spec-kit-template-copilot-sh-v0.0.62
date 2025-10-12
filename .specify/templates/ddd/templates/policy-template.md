# ============================================================
# FILE: policy-template.md
# ============================================================
---
title: "Policy: [Policy Name]"
context: "[Bounded Context Name]"
type: "reactive-logic | business-rule"
version: "1.0.0"
---

# Policy: [Policy Name]

## Definition

[Reactive business rule - "When X happens, then do Y"]

## Characteristics

- **Trigger**: Event-driven (reacts to domain events)
- **Synchronous**: Usually executes within same transaction
- **Deterministic**: Same input always produces same output
- **Side-Effect Free Logic**: Decision logic is pure; actions may have side effects

## Trigger

**Event**: [EventName that triggers this policy]

**Condition** (optional): [Additional condition to check before executing]

## Action

**Intent**: [What business operation is performed]

**Result**: 
- Issues **Command**: [CommandName]
- OR Publishes **Event**: [EventName]
- OR Invokes **Domain Service**: [ServiceName]

## Business Rule

**Rule Statement**: [Natural language statement of the business rule]

**Example**: "When an order is placed, then reserve inventory for all line items"

## Execution

### Synchronous (Immediate)
```
Event: OrderPlaced
Policy: ReserveInventoryPolicy
  → Trigger: ReserveInventory command
  → Timing: Same transaction or immediately after
```

### Asynchronous (Eventual)
```
Event: PaymentFailed
Policy: NotifyCustomerPolicy
  → Trigger: SendEmail command
  → Timing: Queued for async processing
```

## Logic

```typescript
class [PolicyName] {
  @OnEvent('[EventName]')
  handle(event: [EventName]): void {
    // 1. Check condition (if any)
    if (!this.shouldExecute(event)) return;
    
    // 2. Make decision (pure logic)
    const action = this.decide(event);
    
    // 3. Execute action (side effect)
    this.execute(action);
  }
  
  private shouldExecute(event: [EventName]): boolean {
    // Optional condition logic
    return true;
  }
  
  private decide(event: [EventName]): Action {
    // Business logic to determine what to do
    return new ReserveInventoryCommand(...);
  }
  
  private execute(action: Action): void {
    // Send command, publish event, or call service
    this.commandBus.send(action);
  }
}
```

## Dependencies

- **Events**: [Which events this policy listens to]
- **Commands**: [Which commands this policy issues]
- **Domain Services**: [Which services this policy invokes]

## Examples

### Example 1: [Scenario]
```
Given: OrderPlaced event with 2 line items
When: ReserveInventoryPolicy executes
Then: ReserveInventory command issued for each product
```

### Example 2: [Scenario]
```
Given: PaymentAuthorized event for order-123
When: ConfirmOrderPolicy executes
Then: ConfirmOrder command issued
```

## Idempotency

**Strategy**: [How duplicate events are handled]

**Duplicate Detection**: [Event ID tracking]

**Outcome**: [Policy executes once even if event delivered multiple times]

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| [Error 1] | [Cause] | [Retry | Log | Alert] |
| [Error 2] | [Cause] | [Retry | Log | Alert] |

## Testing

### Unit Tests
- Decision logic with various inputs
- Condition evaluation
- Command/event generation

### Integration Tests
- End-to-end: Event → Policy → Command → Outcome
- Idempotency verification

## Comparison: Policy vs. Saga

| Aspect | Policy | Saga |
|--------|--------|------|
| **Trigger** | Single event | Multiple events |
| **State** | Stateless | Stateful |
| **Scope** | Reactive rule | Long-running workflow |
| **Timing** | Immediate | Multi-step coordination |

## Design Decisions

**Why Policy (Not Saga)?**
[This is a simple reaction, not a complex workflow]

**Synchronous vs. Asynchronous?**
[Rationale for timing choice]

## References

- [Link to trigger event]
- [Link to issued commands]
- [Link to bounded context]

---
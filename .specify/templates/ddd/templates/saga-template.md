# ============================================================
# FILE: saga-template.md
# ============================================================
---
title: "Saga: [Saga Name]"
context: "[Bounded Context or Cross-Context]"
type: "orchestration | choreography"
version: "1.0.0"
status: "draft | review | approved"
---

# Saga: [Saga Name]

## Purpose

[What long-running, cross-aggregate or cross-context workflow this saga coordinates]

## Type

**Pattern**: Orchestration | Choreography

**Orchestration**: Central coordinator issues commands and listens for events
**Choreography**: Decentralized; each service reacts to events and publishes new events

## Trigger

**Initiating Event**: [EventName that starts this saga]

**Example**: CartCheckoutRequested

## Workflow Steps

### Step 1: [Step Name]
- **Action**: Issue [CommandName] to [Context/Aggregate]
- **Target**: [Context name]
- **Success Event**: [EventName]
- **Failure Event**: [EventName]
- **Timeout**: [Duration]

**On Success**: → Proceed to Step 2
**On Failure**: → Execute Compensation for Step 1 → End with failure

### Step 2: [Step Name]
- **Action**: Issue [CommandName] to [Context/Aggregate]
- **Target**: [Context name]
- **Success Event**: [EventName]
- **Failure Event**: [EventName]
- **Timeout**: [Duration]

**On Success**: → Proceed to Step 3
**On Failure**: → Execute Compensations for Step 2, Step 1 → End with failure

[Repeat for all steps]

### Step N: [Final Step]
- **Action**: Issue [CommandName]
- **Success Event**: [EventName] (saga completes successfully)

## State Machine

```
[STARTED]
    |
    v
[STEP_1_IN_PROGRESS]
    |-- Success --> [STEP_2_IN_PROGRESS]
    |-- Failure --> [COMPENSATING_STEP_1]
                        |
                        v
                   [FAILED]

[STEP_2_IN_PROGRESS]
    |-- Success --> [COMPLETED]
    |-- Failure --> [COMPENSATING_STEP_2]
                        |
                        v
                   [COMPENSATING_STEP_1]
                        |
                        v
                   [FAILED]
```

## Saga State

The saga maintains state to track progress:

```json
{
  "sagaId": "uuid",
  "sagaType": "[SagaName]",
  "status": "IN_PROGRESS | COMPLETED | FAILED | COMPENSATING",
  "currentStep": 2,
  "completedSteps": [1],
  "compensatedSteps": [],
  "data": {
    "orderId": "uuid",
    "customerId": "uuid",
    "reservationIds": ["uuid1", "uuid2"]
  },
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

## Compensations (Rollback)

### Compensation for Step 1
- **Action**: Issue [CompensatingCommand]
- **Intent**: Undo the effect of Step 1
- **Example**: ReleaseInventory (to undo ReserveInventory)

### Compensation for Step 2
- **Action**: Issue [CompensatingCommand]
- **Intent**: Undo the effect of Step 2
- **Example**: RefundPayment (to undo AuthorizePayment)

**Compensation Order**: Reverse order of execution (Step 2, then Step 1)

## Timeouts

**Step-Level Timeout**: [Duration per step, e.g., 30 seconds]

**Saga-Level Timeout**: [Max duration for entire saga, e.g., 5 minutes]

**Timeout Behavior**: 
- Treat as failure
- Execute compensations for completed steps
- Publish SagaFailed event

## Idempotency

**Saga Instance**: Identified by sagaId; ensures single execution

**Command Idempotency**: All commands issued by saga are idempotent

**Event Handling**: Saga state prevents duplicate event processing

## Example: Checkout Saga

### Trigger
- **Event**: CartCheckoutRequested
- **Data**: cartId, customerId

### Steps

#### Step 1: Reserve Inventory
- **Command**: ReserveInventory(orderId, lineItems) → Inventory Context
- **Success**: InventoryReserved event
- **Failure**: InventoryNotAvailable event
- **Compensation**: ReleaseInventory(orderId, lineItems)

#### Step 2: Authorize Payment
- **Command**: AuthorizePayment(orderId, amount) → Payment Context
- **Success**: PaymentAuthorized event
- **Failure**: PaymentFailed event
- **Compensation**: RefundPayment(orderId, transactionId)

#### Step 3: Confirm Order
- **Command**: ConfirmOrder(orderId) → Order Context
- **Success**: OrderConfirmed event
- **Compensation**: CancelOrder(orderId)

### Success Path
```
CartCheckoutRequested
 → ReserveInventory → InventoryReserved
 → AuthorizePayment → PaymentAuthorized
 → ConfirmOrder → OrderConfirmed
 → CheckoutCompleted (saga done)
```

### Failure Path (Payment Fails)
```
CartCheckoutRequested
 → ReserveInventory → InventoryReserved
 → AuthorizePayment → PaymentFailed
 → Compensate: ReleaseInventory
 → CheckoutFailed (saga failed)
```

## Implementation

### Orchestration Style (Recommended for Complex Workflows)
```typescript
class CheckoutSaga {
  private state: SagaState;
  
  @OnEvent('CartCheckoutRequested')
  async start(event: CartCheckoutRequestedEvent) {
    this.state = this.initializeSaga(event);
    await this.executeStep1();
  }
  
  private async executeStep1() {
    await this.commandBus.send(new ReserveInventoryCommand(...));
    this.state.currentStep = 1;
    await this.saveSagaState();
  }
  
  @OnEvent('InventoryReserved')
  async onInventoryReserved(event: InventoryReservedEvent) {
    if (this.state.currentStep !== 1) return;
    this.state.completedSteps.push(1);
    await this.executeStep2();
  }
  
  @OnEvent('InventoryNotAvailable')
  async onInventoryFailed(event: InventoryNotAvailableEvent) {
    await this.fail("Inventory not available");
  }
  
  // ... more event handlers and steps
  
  private async compensateStep1() {
    await this.commandBus.send(new ReleaseInventoryCommand(...));
  }
}
```

### Choreography Style (For Simple Workflows)
```
// No central saga; each service reacts independently

// Order Context
@OnEvent('CartCheckoutRequested')
async createOrder(event) {
  const order = Order.create(...);
  await orderRepo.save(order);
  await eventBus.publish(new OrderCreated(order.id));
}

// Inventory Context
@OnEvent('OrderCreated')
async reserveInventory(event) {
  // Reserve inventory
  await eventBus.publish(new InventoryReserved(event.orderId));
}

// Payment Context
@OnEvent('InventoryReserved')
async authorizePayment(event) {
  // Authorize payment
  await eventBus.publish(new PaymentAuthorized(event.orderId));
}
```

## Persistence

**Saga State Storage**: [Database table or event store]

**State Recovery**: [How saga resumes after crash]

**Event Replay**: [Can saga replay events to recover state?]

## Monitoring & Observability

**Metrics**:
- Saga duration (p50, p95, p99)
- Success rate
- Failure rate per step
- Compensation frequency

**Logging**:
- Log each step transition
- Log compensations
- Log timeouts

**Alerts**:
- High failure rate
- Timeouts exceeding threshold
- Sagas stuck in IN_PROGRESS

## Testing

### Unit Tests
- State transitions
- Compensation logic
- Timeout handling

### Integration Tests
- End-to-end happy path
- Each failure scenario
- Timeout scenarios
- Idempotency

### Chaos Testing
- Random failures at each step
- Network delays
- Service unavailability

## Design Decisions

**Why Saga (Not Single Transaction)?**
[Justification: cross-context, long-running, eventual consistency]

**Orchestration vs. Choreography?**
[Rationale for chosen pattern]

**Compensation Strategy?**
[Why compensations are designed this way]

## References

- [Link to commands]
- [Link to events]
- [Link to bounded contexts involved]
- [Link to context map]

---

# ============================================================
# FILE: application-service-template.md
# ============================================================
---
title: "Application Service: [Service Name]"
context: "[Bounded Context Name]"
version: "1.0.0"
type: "application-service"
---

# Application Service: [Service Name]

## Purpose

[What workflow or use case this service orchestrates]

## Characteristics

- **Stateless**: Yes (no instance state between calls)
- **Thin Layer**: Delegates to domain model
- **Orchestration**: Coordinates aggregates, domain services, infrastructure
- **Transaction Boundary**: Manages transactions
- **Layer**: Application Layer

## Responsibilities

- ✅ Coordinate workflow across aggregates/services
- ✅ Manage transactions
- ✅ Publish domain events to message broker
- ✅ Handle infrastructure concerns (via injected dependencies)
- ✅ Translate DTOs ↔ domain objects
- ❌ NO business logic (delegate to domain)

## Operations

### [Operation Name]
```
method(command: CommandDTO): Result<ResponseDTO, Error>
```

**Use Case**: [High-level user or system goal]

**Input**: [Command object or DTO]
```json
{
  "field1": "value",
  "field2": 42
}
```

**Output**: [Result DTO or acknowledgment]
```json
{
  "id": "uuid",
  "status": "success",
  "message": "..."
}
```

**Workflow Steps**:
1. **Validate Input**: [Check command structure and permissions]
2. **Load Aggregates**: [Retrieve from repositories]
3. **Execute Domain Logic**: [Call aggregate methods or domain services]
4. **Persist Changes**: [Save updated aggregates]
5. **Publish Events**: [Emit domain events to message broker]
6. **Return Result**: [Build response DTO]

**Transaction Scope**: [What's included in the transaction]

**Error Handling**:
- [Error Type 1]: [How handled]
- [Error Type 2]: [How handled]

**Retry Strategy**: [Idempotent? Retry policy?]

**Idempotency**: [How duplicate commands are handled]

**Authorization**: [Who can execute this operation]

**Example**:
```typescript
// Pseudocode
async placeOrder(command: PlaceOrderCommand): Promise {
  // 1. Validate
  validateCommand(command);
  checkAuthorization(command.userId);
  
  // 2. Load aggregates
  const cart = await cartRepo.findById(command.cartId);
  const customer = await customerRepo.findById(command.userId);
  
  // 3. Domain logic
  const order = orderFactory.createFromCart(cart, customer);
  order.place(); // Emits OrderPlaced event
  
  // 4. Persist
  await orderRepo.save(order);
  
  // 5. Publish events
  await eventBus.publish(order.domainEvents);
  
  // 6. Return
  return order.id;
}
```

[Repeat for all operations]

## Dependencies

### Domain Layer
- **Aggregates**: [[Aggregate1], [Aggregate2]]
- **Domain Services**: [[DomainService1]]
- **Factories**: [[Factory1]]

### Infrastructure Layer (Injected via DI)
- **Repositories**: [[Repository1], [Repository2]]
- **Event Bus**: [Message broker abstraction]
- **External Services**: [[PaymentGateway], [EmailService]] (via ports)

### Application Layer
- **Commands**: [[Command1], [Command2]]
- **DTOs**: [[DTO1], [DTO2]]
- **Mappers**: [[Mapper1]]

## Transactional Consistency

**Transaction Boundaries**:
- [Description of what's in a single transaction]
- Example: Single order + all order lines saved atomically

**Event Publishing**:
- **Pattern**: Transactional Outbox | Event Sourcing | Dual Write (not recommended)
- **Timing**: After successful transaction commit
- **Idempotency**: Events include messageId for deduplication

## Event Handling

### Events Published (Produced)
- **[EventName]**: [When and why]

### Events Consumed (Reacted to)
If this service also acts as an event handler:
- **[EventName]**: [How it reacts]

## Cross-Aggregate Coordination

**Saga/Process Manager** (if applicable):
[Link to saga-[name].md if this service participates in a long-running workflow]

**Eventual Consistency**:
[How eventual consistency is managed across aggregates]

## Security & Authorization

**Authentication**: [Required? How validated?]

**Authorization**: [Role-based? Claims-based? Policy?]

**Audit Logging**: [What's logged: user, action, timestamp, outcome]

## Error Scenarios

| Error | Cause | Handling | User Message |
|-------|-------|----------|--------------|
| [Error1] | [Cause] | [Retry/Fail/Compensate] | [User-friendly message] |
| [Error2] | [Cause] | [Retry/Fail/Compensate] | [User-friendly message] |

## Testing Strategy

- **Unit Tests**: Mock repositories and dependencies; test workflow logic
- **Integration Tests**: Real repositories, in-memory database; test full workflow
- **Contract Tests**: Verify published events match consumer expectations

## Design Decisions

**Transaction Scope Rationale**:
[Why this transaction boundary was chosen]

**Async vs Sync**:
[Why operations are synchronous or asynchronous]

## Example Usage

### From API Controller
```typescript
// REST Controller
@Post('/orders')
async placeOrder(@Body() dto: PlaceOrderDto) {
  const command = mapDtoToCommand(dto);
  const orderId = await orderApplicationService.placeOrder(command);
  return { orderId };
}
```

### From Message Handler
```typescript
// Event Handler
@OnEvent('CartCheckoutRequested')
async handleCartCheckout(event: CartCheckoutRequestedEvent) {
  const command = new PlaceOrderCommand(event.cartId, event.userId);
  await orderApplicationService.placeOrder(command);
}
```

## References

- [Link to aggregates]
- [Link to domain services]
- [Link to repositories]
- [Link to commands]
- [Link to domain events]

---

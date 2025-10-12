# ============================================================
# FILE: factory-template.md
# ============================================================
---
title: "Factory: [Factory Name]"
context: "[Bounded Context Name]"
creates: "[Aggregate or Entity Name]"
version: "1.0.0"
---

# Factory: [Factory Name]

## Purpose

[Why a factory is needed - complexity of creating valid aggregate/entity instances]

## Creates

**Target**: [Aggregate Root or Entity Name]

**Complexity**: [Why simple constructor is insufficient]

## Factory Methods

### [create]
```
create(param1: Type, param2: Type): Result<Aggregate, Error>
```

**Intent**: [What scenario this factory method serves]

**Parameters**:
- `param1`: [Purpose]
- `param2`: [Purpose]

**Construction Rules**:
1. [Rule 1: e.g., "must have at least one line item"]
2. [Rule 2: e.g., "default status is PENDING"]
3. [Rule 3: e.g., "calculate totals from line items"]

**Validation**:
- [Validation 1]
- [Validation 2]

**Returns**: [Valid aggregate instance or error]

**Example**:
```typescript
const order = OrderFactory.create(customerId, lineItems);
// Returns: Order with ID, initial status, calculated totals
```

### [createFrom]
```
createFrom(source: SourceType): Result<Aggregate, Error>
```

**Intent**: [E.g., create Order from Cart]

**Transformation Rules**:
- [How source is transformed to target]

**Example**:
```typescript
const order = OrderFactory.createFromCart(cart);
// Converts cart items to order lines, copies customer info, etc.
```

[Repeat for all factory methods]

## Construction Complexity

**Why Not Simple Constructor?**
- [Reason 1: e.g., "Requires complex validation"]
- [Reason 2: e.g., "Needs to fetch related data"]
- [Reason 3: e.g., "Multiple creation scenarios with different rules"]

**Encapsulated Logic**:
- [What logic is hidden in the factory]

## Dependencies

### Domain Layer
- **Value Objects**: [Which value objects are created as part of aggregate]
- **Domain Services**: [If domain logic is needed during creation]

### Infrastructure (via DI, if needed)
- **Repositories**: [If factory needs to check uniqueness or fetch related data]
- **ID Generation**: [UUID generator, sequence, etc.]

**⚠️ Keep Factories Pure When Possible**:
- Prefer factories that don't depend on infrastructure
- If infrastructure is needed, inject via interface (port)

## Validation at Creation

All factories must ensure created aggregates are **valid from the start**.

**Validation Checks**:
1. [Check 1]
2. [Check 2]

**Invalid Input → Error**:
```typescript
OrderFactory.create(customerId, []); // Empty line items
// Returns: Error("Order must have at least one line item")
```

## Initial State

**Default Values**:
- [Field 1]: [Default value and why]
- [Field 2]: [Default value and why]

**Calculated Values**:
- [Field 3]: [How calculated from inputs]

**Generated Values**:
- [Field 4]: [E.g., UUID, timestamp]

## Domain Events

**Events Published During Creation** (if any):
- **[EventName]**: [E.g., OrderCreated]

**Timing**: [When event is added to aggregate's uncommitted events]

## Examples

### Example 1: Standard Creation
```typescript
const order = OrderFactory.create({
  customerId: CustomerId.create("123"),
  lineItems: [
    { productId: "p1", quantity: 2, price: Money.create(10, "USD") },
    { productId: "p2", quantity: 1, price: Money.create(20, "USD") }
  ],
  shippingAddress: Address.create(...)
});

// Result:
// - Order ID: generated UUID
// - Status: PENDING
// - Total: $40.00
// - Created timestamp: now
// - Events: [OrderCreated]
```

### Example 2: Creation from Another Aggregate
```typescript
const order = OrderFactory.createFromCart(cart, shippingAddress);

// Transformation:
// - Cart items → Order lines
// - Cart customer → Order customer
// - Cart totals → Order totals
// - Cart cleared after order created
```

## Testing Strategy

- **Unit Tests**: Valid and invalid inputs
- **Property-Based Tests**: All created instances are valid
- **Example-Based Tests**: Known scenarios

## Design Decisions

**Why Factory (Not Static Constructor)?**
[Justification for using factory pattern]

**Alternative Approaches Considered**:
- [Alternative 1 and why rejected]
- [Alternative 2 and why rejected]

## References

- [Link to aggregate/entity]
- [Link to value objects]
- [Link to domain events]

---

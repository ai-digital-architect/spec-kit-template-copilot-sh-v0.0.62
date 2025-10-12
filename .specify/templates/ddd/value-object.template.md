# ============================================================
# FILE: value-object-template.md
# ============================================================
---
title: "Value Object: [Value Object Name]"
context: "[Bounded Context Name]"
aggregate: "[Aggregate Name (if part of one)]"
version: "1.0.0"
---

# Value Object: [Value Object Name]

## Definition

[1-2 sentence description of what this value object represents]

## Characteristics

- **Immutable**: Yes (all value objects are immutable)
- **Identified By**: Attributes (not identity)
- **Equality**: Two instances with same attributes are considered equal
- **Side-Effect Free**: Methods return new instances, never mutate

## Attributes

| Attribute | Type | Required | Validation |
|-----------|------|----------|------------|
| [attr1] | [type] | Yes/No | [rules] |
| [attr2] | [type] | Yes/No | [rules] |

### Attribute Details

#### [Attribute Name]
- **Purpose**: [Why this attribute exists]
- **Constraints**: [Format, range, allowed values]
- **Examples**: [Valid examples]

[Repeat for each attribute]

## Validation Rules

Value objects must be **always valid**. Invalid instances should never exist.

### Validation at Construction
1. [Rule 1: e.g., "amount must be non-negative"]
2. [Rule 2: e.g., "currency code must be ISO 4217"]
3. [Rule 3: e.g., "email must match regex pattern"]

### Invariants
- [Invariant 1: e.g., "start date must be before end date"]
- [Invariant 2: e.g., "latitude must be between -90 and 90"]

## Behaviors

### [Method Name]
```
method(param: Type): ValueObject
```
- **Intent**: [What operation this represents]
- **Returns**: [New value object instance]
- **Pure Function**: Yes (no side effects)
- **Example**: 
  ```
  money.add(otherMoney) → new Money(sum)
  ```

[Repeat for all methods]

## Creation

### Constructor / Factory
```
create(attr1: Type, attr2: Type): Result<ValueObject, ValidationError>
```
- **Validates**: [All rules checked at construction]
- **Throws/Returns Error**: If validation fails
- **Example**:
  ```
  Money.create(100, "USD") → Money{amount: 100, currency: "USD"}
  Money.create(-50, "USD") → Error("Amount must be positive")
  ```

### Named Constructors (Optional)
- `fromString(str: string): Result<ValueObject, Error>`
- `fromJSON(json: object): Result<ValueObject, Error>`

## Equality & Comparison

### Equality
Two instances are equal if **all attributes** are equal.

```
Money(100, "USD") == Money(100, "USD")  → true
Money(100, "USD") == Money(100, "EUR")  → false
```

### Comparison (if applicable)
If value object can be ordered:
```
Money(100, "USD") < Money(200, "USD")  → true
```

## Serialization

### To Primitive
```json
{
  "field1": "value1",
  "field2": 42
}
```

### From Primitive
```
ValueObject.fromJSON(json) → ValueObject instance
```

## Usage Examples

### Example 1: Creation
```typescript
const email = Email.create("user@example.com");
// Returns: Email{value: "user@example.com"}

const invalidEmail = Email.create("not-an-email");
// Returns: Error("Invalid email format")
```

### Example 2: Immutability
```typescript
const money1 = Money.create(100, "USD");
const money2 = money1.add(Money.create(50, "USD"));
// money1 is unchanged: Money(100, "USD")
// money2 is new instance: Money(150, "USD")
```

### Example 3: Equality
```typescript
const addr1 = Address.create("123 Main St", "Springfield", "IL", "62701");
const addr2 = Address.create("123 Main St", "Springfield", "IL", "62701");
addr1.equals(addr2); // true
```

## Common Patterns

### Money Pattern
```
Money {
  amount: Decimal,
  currency: CurrencyCode
}
Methods: add, subtract, multiply, divide, isZero, isPositive
```

### Range Pattern
```
DateRange {
  start: Date,
  end: Date
}
Invariant: start <= end
Methods: contains, overlaps, duration
```

### Measurement Pattern
```
Temperature {
  value: Decimal,
  unit: "C" | "F" | "K"
}
Methods: convertTo, compare
```

## Design Decisions

**Why Value Object (not Entity)?**
- No intrinsic identity needed
- Equality is by attributes
- Immutability is desired
- Can be freely replaced

**Why Not Primitive Type?**
- Domain concept deserves explicit representation
- Encapsulates validation logic
- Provides domain-specific operations
- Makes code more expressive

## Testing Strategy

- **Unit Tests**: Validation rules, all operations, equality
- **Property-Based Tests**: Immutability, associativity, commutativity (where applicable)
- **Example-Based Tests**: Edge cases, boundary values

## References

- [Link to entity or aggregate that uses this]
- [Link to bounded context]
- [Domain glossary entry]

---
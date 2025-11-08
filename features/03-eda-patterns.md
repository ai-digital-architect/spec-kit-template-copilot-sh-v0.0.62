---
title: Event-Driven Architecture Patterns Features
category: Architecture Patterns
priority: Tier 2-3
version: 1.0.0
date: 2025-11-07
---

# Event-Driven Architecture Patterns Features

Pre-built templates and generators for common event-driven architecture patterns, enabling teams to implement proven solutions quickly and correctly.

## Overview

Event-driven architectures benefit from well-established patterns for managing complexity. These features codify best practices into reusable templates, reducing implementation time and increasing quality.

## Feature 3.1: Event Storming Templates

### Description

Structured templates for capturing Event Storming session outputs in a format that feeds directly into SpecKit workflows and EventCatalog documentation.

### Problem Statement

**Pain Point:** Event Storming is valuable for domain discovery, but outputs are often:
- Captured in photos of sticky notes
- Lost after sessions end
- Not translated into actionable specifications
- Disconnected from implementation
- Difficult to maintain and evolve

**Impact:** Valuable domain knowledge is wasted, and the gap between discovery and implementation remains wide.

### Target Users

- **Domain Experts** participating in Event Storming
- **Facilitators** running discovery workshops
- **Business Analysts** capturing requirements
- **Architects** translating business flows to technical design

### Key Capabilities

#### Event Storming Artifacts

**Domain Events Template:**
```markdown
---
type: event-storming-event
name: Order Placed
color: orange
timestamp: when customer completes checkout
---

# Domain Event: Order Placed

## Trigger
Customer clicks "Place Order" button after reviewing cart

## Business Context
Critical event marking transition from shopping to fulfillment

## Data Carried
- Order ID
- Customer ID
- Order items (product IDs, quantities, prices)
- Shipping address
- Payment method reference
- Total amount

## Consequences
- Inventory reserved
- Payment authorized
- Fulfillment process initiated
- Confirmation email sent
```

**Commands Template:**
```markdown
---
type: event-storming-command
name: Place Order
color: blue
actor: Customer
---

# Command: Place Order

## Intent
Customer requests to purchase items in cart

## Preconditions
- Cart contains items
- Shipping address provided
- Payment method selected
- Inventory available

## Business Rules
- Order total must be > $0
- All items must be in stock
- Payment method must be valid
- Shipping address must be deliverable

## Produces Events
- Order Placed (success case)
- Order Rejected (failure case)
```

**Aggregates Template:**
```markdown
---
type: event-storming-aggregate
name: Order
color: yellow
---

# Aggregate: Order

## Responsibility
Ensure order consistency and enforce business rules for ordering process

## Invariants
- Order total matches sum of line items
- Order status follows valid state transitions
- Order cannot be modified after shipment

## Commands Handled
- Place Order
- Cancel Order
- Modify Order
- Confirm Payment

## Events Emitted
- Order Placed
- Order Cancelled
- Order Modified
- Payment Confirmed
```

**Policies Template:**
```markdown
---
type: event-storming-policy
name: Reserve Inventory
trigger_event: Order Placed
---

# Policy: Reserve Inventory

## Whenever
Order Placed event occurs

## Then
- Reserve inventory for ordered items
- Set reservation expiration (15 minutes)
- Publish Inventory Reserved event

## Business Logic
If any item is out of stock:
- Release all reservations
- Publish Order Rejected event
- Notify customer
```

**Hotspots Template:**
```markdown
---
type: event-storming-hotspot
name: Payment Race Condition
severity: high
---

# Hotspot: Payment Race Condition

## Issue
Multiple simultaneous orders could authorize same payment method causing overdraft

## Impact
- Customer experience degradation
- Potential financial loss
- Compliance risk

## Stakeholders
- Payment team
- Customer service
- Risk management

## Needs Clarification
- Payment authorization timeout
- Retry logic
- Idempotency handling

## Proposed Solution
- Implement payment authorization saga
- Add distributed lock on payment method
- Idempotency keys for all payment operations
```

#### Session Capture Workflow

```bash
#!/bin/bash
# .specify/scripts/bash/event-storming.sh

capture_event_storming_session() {
  local session_name=$1
  local session_dir="specs/${FEATURE_ID}/event-storming/${session_name}"

  mkdir -p "$session_dir"/{events,commands,aggregates,policies,hotspots}

  echo "=== Event Storming Session: $session_name ==="
  echo ""
  echo "Capture your Event Storming outputs:"
  echo "1. Domain Events (orange stickies)"
  echo "2. Commands (blue stickies)"
  echo "3. Aggregates (yellow stickies)"
  echo "4. Policies (lilac stickies)"
  echo "5. Hotspots (red stickies)"
  echo ""

  # Capture each artifact type
  capture_events "$session_dir/events"
  capture_commands "$session_dir/commands"
  capture_aggregates "$session_dir/aggregates"
  capture_policies "$session_dir/policies"
  capture_hotspots "$session_dir/hotspots"

  # Generate timeline view
  generate_timeline "$session_dir"

  # Generate EventCatalog docs
  generate_eventcatalog_from_storming "$session_dir"
}
```

#### Timeline View Generation

```markdown
# Event Storming Timeline: Order Management Flow

## Customer Journey

1. **Customer** → `Browse Products`
2. **Customer** → **[Add to Cart]** → **Cart**
3. **Cart** → `Item Added to Cart`
4. **Customer** → **[Place Order]** → **Order**
5. **Order** → `Order Placed` → **POLICY: Reserve Inventory**
6. **Inventory** → `Inventory Reserved` → **POLICY: Authorize Payment**
7. **Payment** → `Payment Authorized` → **POLICY: Initiate Fulfillment**
8. **Fulfillment** → `Order Shipped`
9. **Customer** ← `Shipping Notification`

## Hotspots
- 🔴 Payment Race Condition (step 6)
- 🔴 Inventory Sync Delay (step 5)
```

### Success Metrics

- **Session Capture Time:** 50% reduction in time to document Event Storming output
- **Knowledge Retention:** 90% of domain insights captured in structured format
- **Implementation Speed:** 40% faster transition from discovery to spec
- **Hotspot Resolution:** 100% of hotspots tracked and addressed

### Priority

**Tier 2** - Valuable for teams doing domain-driven design and Event Storming.

---

## Feature 3.2: Saga Pattern Generator

### Description

Generate saga implementations for complex distributed transactions, including orchestration code, compensation logic, and state management.

### Problem Statement

**Pain Point:** Implementing sagas is complex and error-prone:
- Compensation logic often overlooked
- State management inconsistent
- Timeout handling incomplete
- Idempotency not guaranteed
- Difficult to test and debug

**Impact:** Production failures, data inconsistencies, and difficult-to-maintain code.

### Target Users

- **Backend Engineers** implementing distributed transactions
- **Architects** designing resilient workflows
- **SRE Teams** managing saga reliability

### Key Capabilities

#### Saga Definition DSL

```yaml
# specs/001-order-processing/sagas/order-fulfillment-saga.yml

saga:
  name: OrderFulfillmentSaga
  trigger_event: OrderPlaced
  description: Coordinates order fulfillment across inventory, payment, and shipping

  steps:
    - id: reserve-inventory
      service: inventory-service
      command: ReserveInventory
      timeout: 5s
      compensation: ReleaseInventory
      retry:
        max_attempts: 3
        backoff: exponential

    - id: authorize-payment
      service: payment-service
      command: AuthorizePayment
      timeout: 10s
      compensation: RefundPayment
      retry:
        max_attempts: 2
        backoff: linear
      depends_on: [reserve-inventory]

    - id: create-shipment
      service: shipping-service
      command: CreateShipment
      timeout: 5s
      compensation: CancelShipment
      depends_on: [authorize-payment]

    - id: confirm-order
      service: order-service
      command: ConfirmOrder
      timeout: 3s
      depends_on: [create-shipment]

  compensation_order: reverse  # reverse | custom

  failure_handling:
    on_timeout: compensate
    on_error: compensate
    max_compensation_attempts: 3

  state_persistence:
    backend: database  # database | event-store | memory
    table: saga_state

  idempotency:
    enabled: true
    key_fields: [orderId, sagaId]
```

#### Generated Saga Code

**Orchestrator (TypeScript):**
```typescript
// Generated by SpecKit Saga Generator

export class OrderFulfillmentSaga {
  constructor(
    private inventoryService: InventoryService,
    private paymentService: PaymentService,
    private shippingService: ShippingService,
    private orderService: OrderService,
    private stateStore: SagaStateStore
  ) {}

  async execute(event: OrderPlaced): Promise<SagaResult> {
    const sagaId = generateSagaId();
    const state = await this.stateStore.create({
      sagaId,
      orderId: event.orderId,
      status: 'STARTED',
      steps: []
    });

    try {
      // Step 1: Reserve Inventory
      await this.executeStep(sagaId, 'reserve-inventory', async () => {
        return await this.inventoryService.reserveInventory({
          orderId: event.orderId,
          items: event.items
        });
      });

      // Step 2: Authorize Payment
      await this.executeStep(sagaId, 'authorize-payment', async () => {
        return await this.paymentService.authorizePayment({
          orderId: event.orderId,
          amount: event.total
        });
      });

      // Step 3: Create Shipment
      await this.executeStep(sagaId, 'create-shipment', async () => {
        return await this.shippingService.createShipment({
          orderId: event.orderId,
          address: event.shippingAddress
        });
      });

      // Step 4: Confirm Order
      await this.executeStep(sagaId, 'confirm-order', async () => {
        return await this.orderService.confirmOrder({
          orderId: event.orderId
        });
      });

      await this.stateStore.complete(sagaId);
      return { success: true };

    } catch (error) {
      await this.compensate(sagaId);
      return { success: false, error };
    }
  }

  private async compensate(sagaId: string): Promise<void> {
    const state = await this.stateStore.get(sagaId);
    const completedSteps = state.steps.filter(s => s.status === 'COMPLETED');

    // Compensate in reverse order
    for (const step of completedSteps.reverse()) {
      try {
        await this.executeCompensation(step);
      } catch (error) {
        // Log compensation failure but continue
        console.error(`Compensation failed for step ${step.id}`, error);
      }
    }

    await this.stateStore.fail(sagaId);
  }

  private async executeCompensation(step: SagaStep): Promise<void> {
    switch (step.id) {
      case 'reserve-inventory':
        await this.inventoryService.releaseInventory(step.output);
        break;
      case 'authorize-payment':
        await this.paymentService.refundPayment(step.output);
        break;
      case 'create-shipment':
        await this.shippingService.cancelShipment(step.output);
        break;
    }
  }
}
```

#### State Machine Visualization

```
OrderFulfillmentSaga State Machine
===================================

[Start] → Reserve Inventory
           ↓ Success  ↓ Failure
           ↓          ↓
    Authorize Payment  → [Compensate: Release Inventory] → [Failed]
           ↓ Success  ↓ Failure
           ↓          ↓
    Create Shipment   → [Compensate: Refund + Release] → [Failed]
           ↓ Success  ↓ Failure
           ↓          ↓
    Confirm Order     → [Compensate: Cancel + Refund + Release] → [Failed]
           ↓ Success
           ↓
       [Completed]
```

#### Test Scenario Generation

```typescript
// Generated test scenarios

describe('OrderFulfillmentSaga', () => {
  it('should complete successfully when all steps succeed', async () => {
    // Generated happy path test
  });

  it('should compensate after inventory reservation failure', async () => {
    // Generated compensation test
  });

  it('should compensate after payment authorization failure', async () => {
    // Generated compensation test with inventory release
  });

  it('should handle timeout in payment step', async () => {
    // Generated timeout handling test
  });

  it('should be idempotent on retry', async () => {
    // Generated idempotency test
  });
});
```

### Success Metrics

- **Development Time:** 60% reduction in saga implementation time
- **Bug Reduction:** 80% fewer saga-related production bugs
- **Compensation Coverage:** 100% of saga steps have compensation
- **Test Coverage:** 90%+ test coverage for generated saga code

### Priority

**Tier 2** - High value for microservices architectures with complex transactions.

---

## Feature 3.3: Event Versioning Strategy Templates

### Description

Pre-built templates and code generators for common event versioning strategies, enabling teams to evolve events safely.

### Problem Statement

**Pain Point:** Teams struggle with consistent event versioning approaches:
- No standardized versioning strategy
- Ad-hoc solutions per team
- Difficulty maintaining multiple versions
- Complex transformation code
- Testing challenges

### Target Users

- **Platform Engineers** defining versioning standards
- **Developers** evolving events
- **Integration Teams** managing multi-version support

### Key Capabilities

#### Strategy Templates

**Strategy 1: Parallel Versions (Multiple Topics)**

```yaml
# specs/001-user-management/versioning/user-registered-strategy.yml

strategy: parallel-versions

event: user.registered

versions:
  v1:
    topic: user.registered.v1
    schema: schemas/user-registered.v1.avro
    status: deprecated
    sunset_date: 2026-01-01

  v2:
    topic: user.registered.v2
    schema: schemas/user-registered.v2.avro
    status: current

  v3:
    topic: user.registered.v3
    schema: schemas/user-registered.v3.avro
    status: beta

publishing:
  mode: dual  # Publish to both v2 and v3 during migration
  targets: [v2, v3]
```

**Generated Producer Code:**
```typescript
export class UserRegisteredPublisher {
  async publish(user: User): Promise<void> {
    // Transform to v2
    const eventV2 = this.transformToV2(user);
    await this.eventBus.publish('user.registered.v2', eventV2);

    // Transform to v3
    const eventV3 = this.transformToV3(user);
    await this.eventBus.publish('user.registered.v3', eventV3);
  }

  private transformToV2(user: User): UserRegisteredV2 {
    // Auto-generated transformation logic
  }

  private transformToV3(user: User): UserRegisteredV3 {
    // Auto-generated transformation logic
  }
}
```

**Strategy 2: Single Writer Principle**

```yaml
strategy: single-writer

event: user.registered

canonical_version: v3  # Always write latest version

transformation_layer:
  enabled: true
  service: user-event-transformer
  supports_versions: [v1, v2, v3]

consumers:
  - name: email-service
    requested_version: v1
    transformation: v3 → v1

  - name: analytics-service
    requested_version: v2
    transformation: v3 → v2

  - name: crm-service
    requested_version: v3
    transformation: none
```

**Generated Transformer Service:**
```typescript
export class UserRegisteredTransformer {
  transform(event: UserRegisteredV3, targetVersion: string): any {
    switch (targetVersion) {
      case 'v1':
        return this.transformV3ToV1(event);
      case 'v2':
        return this.transformV3ToV2(event);
      case 'v3':
        return event;
      default:
        throw new Error(`Unsupported version: ${targetVersion}`);
    }
  }

  private transformV3ToV1(event: UserRegisteredV3): UserRegisteredV1 {
    return {
      userId: event.userId,
      email: event.email,
      name: `${event.firstName} ${event.lastName}`,
      // Drop v3-specific fields
    };
  }

  private transformV3ToV2(event: UserRegisteredV3): UserRegisteredV2 {
    return {
      userId: event.userId,
      email: event.email,
      firstName: event.firstName,
      lastName: event.lastName,
      // Map v3 fields to v2 structure
    };
  }
}
```

**Strategy 3: Consumer-Driven Contracts**

```yaml
strategy: consumer-driven-contracts

event: user.registered

contracts:
  - consumer: email-service
    required_fields:
      - userId
      - email
      - name
    optional_fields:
      - preferences.emailOptIn
    version: v1

  - consumer: analytics-service
    required_fields:
      - userId
      - email
      - createdAt
      - source
    version: v2

contract_validation:
  on_publish: true
  break_build_on_violation: true
```

### Success Metrics

- **Strategy Adoption:** 100% of events use defined versioning strategy
- **Version Sprawl:** <3 active versions per event average
- **Transformation Bugs:** 90% reduction in version transformation errors
- **Migration Time:** 50% faster version migrations

### Priority

**Tier 2-3** - Important for mature event-driven systems with many consumers.

---

## Implementation Roadmap

### Phase 1: Event Storming (Month 1-2)
- Create Event Storming templates
- Build capture workflow
- Implement timeline generation

### Phase 2: Saga Patterns (Month 2-3)
- Design saga DSL
- Build code generators for TypeScript, Java, Go
- Create state machine visualizations

### Phase 3: Versioning (Month 3-4)
- Create versioning strategy templates
- Build transformation code generators
- Implement contract validation

## Related Features

- **Feature 1.1:** EventCatalog Generator (generates saga documentation)
- **Feature 2.2:** Schema Evolution Planner (uses versioning strategies)
- **Feature 5.2:** Event Contract Testing (validates versioning)
- **Feature 7.2:** Event Flow Visualizer (visualizes sagas)

## Resources

- [Event Storming Guide](https://www.eventstorming.com/)
- [Saga Pattern](https://microservices.io/patterns/data/saga.html)
- [Semantic Versioning](https://semver.org/)
- [Consumer-Driven Contracts](https://martinfowler.com/articles/consumerDrivenContracts.html)

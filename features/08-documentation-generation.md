---
title: Documentation Generation Features
category: Documentation
priority: Tier 2
version: 1.0.0
date: 2025-11-07
---

# Documentation Generation Features

Automated documentation generation from specifications and templates, keeping documentation synchronized with implementation.

## Feature 8.1: API Documentation Generator

### Description
Generate comprehensive API documentation from SpecKit contract templates, including REST APIs, GraphQL endpoints, and gRPC services alongside event documentation.

### Problem Statement
API documentation is manually maintained separate from event documentation, leading to inconsistency and outdated docs.

### Key Capabilities

#### OpenAPI Specification Generation

From REST API contract templates:

```yaml
# Generated from specs/001-user-management/contracts/api-contract.md

openapi: 3.1.0
info:
  title: User Management API
  version: 1.0.0
  description: RESTful API for user account management

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

paths:
  /users:
    post:
      summary: Create a new user
      operationId: createUser
      tags:
        - Users
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
            examples:
              basic:
                value:
                  email: user@example.com
                  firstName: John
                  lastName: Doe
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Invalid request
        '409':
          description: User already exists

      x-events-published:
        - user.registered

components:
  schemas:
    CreateUserRequest:
      type: object
      required:
        - email
        - firstName
        - lastName
      properties:
        email:
          type: string
          format: email
        firstName:
          type: string
        lastName:
          type: string

    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        firstName:
          type: string
        lastName:
          type: string
        createdAt:
          type: string
          format: date-time
```

#### API + Event Documentation Integration

Link synchronous APIs with async events they produce:

```markdown
# POST /users

Creates a new user account.

## Request
```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe"
}
```

## Response
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "createdAt": "2025-11-07T14:30:00Z"
}
```

## Events Published

### user.registered
Published when user account is successfully created.

**Schema:** [user.registered.v2.avro](../events/user-registered.md)

**Example:**
```json
{
  "eventId": "evt-123",
  "userId": "uuid-here",
  "email": "user@example.com",
  "occurredAt": "2025-11-07T14:30:00Z"
}
```

## Error Scenarios

### 409 Conflict
User with email already exists. No event published.

### 400 Bad Request
Invalid email format. No event published.
```

#### GraphQL Schema Generation

```graphql
# Generated from specs/001-user-management/contracts/graphql-schema.md

type User {
  id: ID!
  email: String!
  firstName: String!
  lastName: String!
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(limit: Int = 10, offset: Int = 0): [User!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

input CreateUserInput {
  email: String!
  firstName: String!
  lastName: String!
}

"""
Events published by this mutation
- user.registered
"""
directive @publishesEvents(events: [String!]!) on FIELD_DEFINITION
```

### Priority
**Tier 2** - Valuable for teams with both synchronous and asynchronous APIs.

---

## Feature 8.2: Onboarding Guide Generator

### Description
Automatically generate developer onboarding materials from domain models, events, and architecture documentation.

### Problem Statement
New team members struggle to understand the event-driven architecture due to lack of comprehensive, up-to-date onboarding documentation.

### Key Capabilities

#### Auto-Generated Onboarding Guide

```markdown
# Developer Onboarding Guide

## Welcome to Event-Driven Order Management System

This guide will help you understand our event-driven architecture and get started with development.

## Architecture Overview

Our system consists of 8 bounded contexts:
- User Management (15 events)
- Order Management (23 events)
- Payment Processing (12 events)
- Inventory Management (18 events)
- Shipping & Fulfillment (14 events)
- Notifications (8 events)
- Analytics (6 events)
- Customer Support (10 events)

## Domain Glossary

### Key Concepts

**Aggregate**
A cluster of domain objects treated as a single unit. In our system:
- Order (root: Order ID)
- User (root: User ID)
- Product (root: Product ID)

**Domain Event**
A record of something that happened in the domain. Examples:
- order.placed - Customer places an order
- payment.authorized - Payment successfully authorized
- shipment.created - Shipping label created

**Saga**
A sequence of local transactions coordinated through events:
- Order Fulfillment Saga
- Refund Processing Saga
- Subscription Renewal Saga

## Core Event Flows

### 1. User Registration
```
User → POST /register
  ↓
user.registered event
  ↓
├─→ Email Service (sends verification)
├─→ Analytics (tracks signup)
└─→ CRM (creates contact)
```

### 2. Order Placement
```
Customer → POST /orders
  ↓
order.placed event
  ↓
Order Fulfillment Saga:
  ├─→ Reserve Inventory
  ├─→ Authorize Payment
  ├─→ Create Shipment
  └─→ Confirm Order
```

## Getting Started

### 1. Set Up Local Environment
```bash
git clone https://github.com/yourorg/order-system
cd order-system
docker-compose up -d  # Starts Kafka, Postgres, etc.
npm install
npm run dev
```

### 2. Explore EventCatalog
Visit http://localhost:3000/eventcatalog to browse:
- All events and their schemas
- Service dependencies
- Domain models
- API documentation

### 3. Your First Event

Create a new event consumer:
```typescript
import { UserRegisteredConsumer } from './generated/consumers';

export class WelcomeEmailConsumer extends UserRegisteredConsumer {
  async handleUserRegistered(event: UserRegistered): Promise<void> {
    // Send welcome email
    await this.emailService.send({
      to: event.email,
      template: 'welcome',
      data: { firstName: event.firstName }
    });
  }
}
```

### 4. Common Patterns

**Event Sourcing:** Not used in our system
**CQRS:** Used in Order and Inventory services
**Saga:** Used for distributed transactions
**Event Versioning:** Parallel topics strategy

## Useful Links

- [EventCatalog](http://localhost:3000/eventcatalog)
- [Kafka UI](http://localhost:8080)
- [API Documentation](http://localhost:3000/api-docs)
- [Architecture Decision Records](./decisions/)
- [Runbooks](./runbooks/)

## Need Help?

- Slack: #architecture-help
- Team: architecture-team@company.com
- Office Hours: Tuesdays 2-3 PM
```

### Priority
**Tier 2** - Accelerates team onboarding.

---

## Feature 8.3: Migration Guide Generator

### Description
Create detailed migration guides for breaking schema changes, including code examples, checklists, and rollback procedures.

### Problem Statement
Teams struggle with schema migrations due to lack of clear, step-by-step migration documentation.

### Key Capabilities

#### Auto-Generated Migration Guide

```markdown
# Migration Guide: user.registered v1.0 → v2.0

## Overview
This guide helps you migrate from v1.0 to v2.0 of the user.registered event.

**Migration Deadline:** 2026-01-15
**Support Contact:** identity-team@company.com

## What Changed?

### Breaking Changes
1. **Removed field:** `middleName`
   - **Reason:** Low usage (<2% of events populated this field)
   - **Migration:** Drop field, no replacement

2. **Type change:** `age` (integer → string)
   - **Reason:** Support age ranges (e.g., "25-34", "unknown")
   - **Migration:** Convert integer to string: `String(age)`

3. **New required field:** `registrationSource`
   - **Reason:** Track user acquisition channels
   - **Migration:** Default to "unknown" for existing consumers

### Non-Breaking Changes
4. **Added optional field:** `preferences`
   - New field with default value
   - No action required

## Migration Steps

### Step 1: Update Schema Dependencies
```bash
npm update @company/user-events@2.0.0
```

### Step 2: Update Type Definitions
**Before (v1.0):**
```typescript
interface UserRegisteredV1 {
  userId: string;
  email: string;
  firstName: string;
  middleName?: string;  // REMOVED
  lastName: string;
  age: number;          // NOW STRING
}
```

**After (v2.0):**
```typescript
interface UserRegisteredV2 {
  userId: string;
  email: string;
  firstName: string;
  lastName: string;
  age: string;                    // Changed from number
  registrationSource: string;     // NEW REQUIRED
  preferences?: UserPreferences;  // NEW OPTIONAL
}
```

### Step 3: Update Event Handlers

**Before:**
```typescript
async handleUserRegistered(event: UserRegisteredV1) {
  const fullName = event.middleName
    ? `${event.firstName} ${event.middleName} ${event.lastName}`
    : `${event.firstName} ${event.lastName}`;

  await this.analytics.track({
    userId: event.userId,
    name: fullName,
    ageGroup: getAgeGroup(event.age)  // age was number
  });
}
```

**After:**
```typescript
async handleUserRegistered(event: UserRegisteredV2) {
  const fullName = `${event.firstName} ${event.lastName}`;
  // middleName no longer available

  await this.analytics.track({
    userId: event.userId,
    name: fullName,
    ageGroup: event.age,  // age is now string (already a group)
    source: event.registrationSource  // new field
  });
}
```

### Step 4: Handle Dual-Topic Subscription (Transition Period)

During migration, your service should support both versions:

```typescript
// Subscribe to both v1 and v2 topics
consumer.subscribe(['user.registered.v1', 'user.registered.v2']);

consumer.on('message', async (message) => {
  const version = message.headers['schema-version'];

  if (version === '1.0.0') {
    const eventV1 = deserialize<UserRegisteredV1>(message.value);
    const eventV2 = transformV1ToV2(eventV1);
    await handleUserRegistered(eventV2);
  } else if (version === '2.0.0') {
    const eventV2 = deserialize<UserRegisteredV2>(message.value);
    await handleUserRegistered(eventV2);
  }
});

function transformV1ToV2(v1: UserRegisteredV1): UserRegisteredV2 {
  return {
    ...v1,
    age: String(v1.age),
    registrationSource: 'unknown'  // Default for v1 events
    // middleName dropped
  };
}
```

### Step 5: Testing Checklist
- [ ] Unit tests updated with v2.0 schema
- [ ] Integration tests pass with v2.0 events
- [ ] Backward compatibility tested (v1 → v2 transformation)
- [ ] Performance regression tests pass
- [ ] Staging deployment successful
- [ ] Canary deployment (10% traffic) successful

### Step 6: Production Deployment
```bash
# Deploy your updated consumer
kubectl apply -f k8s/consumer-deployment.yml

# Monitor for errors
kubectl logs -f deployment/user-registered-consumer

# Verify metrics
# - Consumer lag should remain stable
# - Error rate should not increase
# - Processing time should be similar
```

### Step 7: Cleanup (After Migration Deadline)
After all consumers have migrated:
```bash
# Unsubscribe from v1 topic
consumer.unsubscribe('user.registered.v1');

# Remove transformation code
# Remove v1 type definitions
```

## Rollback Procedure

If you encounter issues after migration:

1. **Immediate Rollback:**
   ```bash
   kubectl rollback deployment/user-registered-consumer
   ```

2. **Revert to v1 Topic:**
   - Your service will automatically fall back to v1 topic
   - Dual subscription still active during transition period

3. **Report Issues:**
   - Slack: #identity-team
   - Create incident ticket with error logs

## Testing in Staging

1. **Generate Test Events:**
   ```bash
   speckit event mock user.registered.v2 --count 100 > test-events.json
   ```

2. **Publish to Staging:**
   ```bash
   kafka-console-producer --topic user.registered.v2 < test-events.json
   ```

3. **Verify Consumer Processing:**
   ```bash
   kubectl logs -f deployment/user-registered-consumer -n staging
   ```

## FAQ

**Q: What happens to old v1.0 events in the topic?**
A: They remain available. Your consumer should handle both versions during transition.

**Q: Can I continue using v1.0 after the deadline?**
A: No. The v1.0 topic will be deleted on 2026-01-15. Migration is mandatory.

**Q: What if I need the `middleName` field?**
A: Fetch from User API: `GET /users/{userId}` returns all profile fields.

**Q: How do I handle age conversion edge cases?**
A: Age in v2.0 can be:
- Numeric string: "25"
- Range: "25-34"
- Unknown: "unknown"

## Support

- **Slack:** #identity-team
- **Email:** identity-team@company.com
- **Office Hours:** Mon/Wed 2-3 PM
- **Escalation:** Page on-call via PagerDuty
```

### Priority
**Tier 2** - Critical for smooth schema evolution.

---

## Related Features
- **Feature 2.2:** Schema Evolution Planner (generates migration plans)
- **Feature 5.1:** AsyncAPI Code Generator (generates code examples)
- **Feature 6.3:** Event Deprecation Workflow (manages sunset timeline)

## Resources
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [GraphQL Schema Documentation](https://graphql.org/learn/schema/)
- [Technical Writing Best Practices](https://developers.google.com/tech-writing)

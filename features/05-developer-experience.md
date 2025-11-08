---
title: Developer Experience Features
category: Developer Productivity
priority: Tier 1-2
version: 1.0.0
date: 2025-11-07
---

# Developer Experience Features

Features that improve developer productivity, reduce manual work, and accelerate development cycles.

## Feature 5.1: AsyncAPI Code Generator Integration

### Description
Generate AsyncAPI specifications and production-ready code from SpecKit contracts, supporting multiple languages and frameworks.

### Problem Statement
Manually writing boilerplate code for event producers, consumers, and schema handling is time-consuming, error-prone, and inconsistent across teams.

### Key Capabilities

#### AsyncAPI Specification Generation
From SpecKit contract templates, auto-generate AsyncAPI 3.0 specs:

```yaml
# Generated from specs/001-user-management/contracts/events.md

asyncapi: 3.0.0
info:
  title: User Management Events API
  version: 1.0.0
  description: Events published by the user management service

channels:
  user.registered:
    address: user.registered.v2
    messages:
      UserRegistered:
        $ref: '#/components/messages/UserRegistered'
    bindings:
      kafka:
        topic: user.registered.v2
        partitions: 10
        replicas: 3

components:
  messages:
    UserRegistered:
      name: UserRegistered
      title: User Registered Event
      summary: Published when a new user completes registration
      contentType: application/avro
      payload:
        $ref: '#/components/schemas/UserRegistered'

  schemas:
    UserRegistered:
      type: object
      properties:
        eventId:
          type: string
          format: uuid
        userId:
          type: string
        email:
          type: string
          format: email
        occurredAt:
          type: string
          format: date-time
```

#### Code Generation for Multiple Languages

**TypeScript Producer:**
```typescript
// Auto-generated from AsyncAPI spec

import { KafkaProducer } from '@org/kafka-client';
import { UserRegistered } from './schemas/UserRegistered';

export class UserRegisteredPublisher {
  private producer: KafkaProducer;

  constructor(producer: KafkaProducer) {
    this.producer = producer;
  }

  async publish(event: UserRegistered): Promise<void> {
    await this.producer.send({
      topic: 'user.registered.v2',
      messages: [{
        key: event.userId,
        value: event,
        headers: {
          'event-id': event.eventId,
          'event-type': 'UserRegistered',
          'schema-version': '1.0.0'
        }
      }]
    });
  }
}
```

**TypeScript Consumer:**
```typescript
// Auto-generated from AsyncAPI spec

import { KafkaConsumer } from '@org/kafka-client';
import { UserRegistered } from './schemas/UserRegistered';

export abstract class UserRegisteredConsumer {
  private consumer: KafkaConsumer;

  constructor(consumer: KafkaConsumer) {
    this.consumer = consumer;
  }

  async start(): Promise<void> {
    await this.consumer.subscribe({
      topic: 'user.registered.v2',
      fromBeginning: false
    });

    await this.consumer.run({
      eachMessage: async ({ message }) => {
        const event = this.deserialize(message.value);
        await this.handleUserRegistered(event);
      }
    });
  }

  // Implement this method in your consumer
  abstract handleUserRegistered(event: UserRegistered): Promise<void>;

  private deserialize(buffer: Buffer): UserRegistered {
    // Auto-generated deserialization logic
  }
}
```

**Java Producer:**
```java
// Auto-generated from AsyncAPI spec

package com.yourcompany.events.producers;

import com.yourcompany.events.schemas.UserRegistered;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class UserRegisteredPublisher {
    private final KafkaTemplate<String, UserRegistered> kafkaTemplate;
    private static final String TOPIC = "user.registered.v2";

    public UserRegisteredPublisher(KafkaTemplate<String, UserRegistered> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publish(UserRegistered event) {
        kafkaTemplate.send(TOPIC, event.getUserId(), event);
    }
}
```

#### Supported Languages & Frameworks
- **TypeScript:** Plain Node.js, NestJS, Express
- **Java:** Spring Boot, Micronaut, Quarkus
- **Go:** Standard library, sarama
- **Python:** asyncio, Faust
- **C#:** .NET Core, MassTransit

### Usage
```bash
/speckit.codegen asyncapi
→ Generates AsyncAPI specs from contracts
→ Prompts for target language
→ Generates producer/consumer code
→ Updates EventCatalog documentation
```

### Priority
**Tier 1** - High impact on developer productivity.

---

## Feature 5.2: Event Contract Testing Framework

### Description
Automatically generate contract tests to validate that producers and consumers adhere to event schemas and compatibility rules.

### Problem Statement
Breaking changes slip into production because contract validation happens too late or not at all. Teams need automated testing to catch issues early.

### Key Capabilities

#### Producer Contract Tests
```typescript
// Auto-generated producer tests

describe('UserRegisteredPublisher Contract Tests', () => {
  it('should publish events matching schema v2.0.0', async () => {
    const publisher = new UserRegisteredPublisher(mockProducer);

    const event: UserRegistered = {
      eventId: 'uuid-here',
      userId: 'user123',
      email: 'test@example.com',
      occurredAt: new Date().toISOString()
    };

    await publisher.publish(event);

    // Verify published event matches schema
    expect(mockProducer.lastSent).toMatchSchema('UserRegistered', '2.0.0');
  });

  it('should include required headers', async () => {
    // Auto-generated header validation
  });

  it('should use correct partition key', async () => {
    // Auto-generated partitioning test
  });
});
```

#### Consumer Contract Tests
```typescript
// Auto-generated consumer tests

describe('EmailService UserRegistered Consumer Contract', () => {
  it('should handle current schema version v2.0.0', async () => {
    const consumer = new EmailServiceUserRegisteredConsumer();

    const event = generateValidEvent('UserRegistered', '2.0.0');

    await expect(consumer.handleUserRegistered(event)).resolves.not.toThrow();
  });

  it('should handle schema v1.0.0 (backward compatibility)', async () => {
    const consumer = new EmailServiceUserRegisteredConsumer();

    const eventV1 = generateValidEvent('UserRegistered', '1.0.0');

    await expect(consumer.handleUserRegistered(eventV1)).resolves.not.toThrow();
  });

  it('should reject invalid events', async () => {
    const consumer = new EmailServiceUserRegisteredConsumer();

    const invalidEvent = { userId: '123' }; // Missing required fields

    await expect(consumer.handleUserRegistered(invalidEvent)).rejects.toThrow();
  });
});
```

#### CI/CD Integration
```yaml
# .github/workflows/contract-tests.yml

name: Event Contract Tests

on: [push, pull_request]

jobs:
  contract-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Producer Contract Tests
        run: npm run test:contracts:producer

      - name: Run Consumer Contract Tests
        run: npm run test:contracts:consumer

      - name: Validate Schema Compatibility
        run: |
          .specify/scripts/bash/validate-eventcatalog.sh

      - name: Upload Contract Test Results
        uses: actions/upload-artifact@v3
        with:
          name: contract-test-results
          path: contract-test-results.json
```

### Priority
**Tier 2** - Essential for preventing breaking changes.

---

## Feature 5.3: Event Mocking and Simulation

### Description
Generate realistic mock events for testing, with support for event sequences, correlation, and replay of production events.

### Problem Statement
Testing event-driven systems requires realistic test data. Manually creating mock events is tedious and doesn't cover edge cases.

### Key Capabilities

#### Mock Event Generation
```typescript
// Auto-generated from schema

import { generateMockEvent } from '@speckit/event-mocking';

// Generate single event
const mockEvent = generateMockEvent('UserRegistered', {
  userId: 'test-user-123',
  email: 'test@example.com'
  // Other fields auto-generated with realistic values
});

// Generate multiple related events (correlation)
const eventSequence = generateEventSequence([
  { type: 'UserRegistered', userId: 'user-123' },
  { type: 'EmailVerified', userId: 'user-123' },
  { type: 'ProfileCompleted', userId: 'user-123' }
]);

// Generate edge cases
const edgeCases = generateEdgeCases('UserRegistered');
// Returns: empty strings, max lengths, special characters, etc.
```

#### Event Replay from Production
```bash
# Replay production events (sanitized)

speckit event replay \
  --topic user.registered.v2 \
  --from 2025-11-01 \
  --to 2025-11-07 \
  --sanitize-pii \
  --output test/fixtures/
```

#### Test Fixture Management
```typescript
// fixtures/user-registration-flow.ts

export const userRegistrationFlow = [
  {
    type: 'UserRegistered',
    timestamp: '2025-11-07T10:00:00Z',
    data: { userId: 'user-123', email: 'test@example.com' }
  },
  {
    type: 'EmailVerificationSent',
    timestamp: '2025-11-07T10:00:01Z',
    data: { userId: 'user-123', verificationToken: 'token-abc' }
  },
  {
    type: 'EmailVerified',
    timestamp: '2025-11-07T10:05:00Z',
    data: { userId: 'user-123' }
  }
];
```

### Priority
**Tier 2** - Valuable for testing complex event flows.

---

## Related Features
- **Feature 1.1:** EventCatalog Generator (uses generated code)
- **Feature 2.1:** Schema-First Workflow (schemas used for code gen)
- **Feature 3.2:** Saga Pattern Generator (similar code generation)

## Resources
- [AsyncAPI Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- [AsyncAPI Generator](https://github.com/asyncapi/generator)
- [Contract Testing](https://martinfowler.com/bliki/ContractTest.html)

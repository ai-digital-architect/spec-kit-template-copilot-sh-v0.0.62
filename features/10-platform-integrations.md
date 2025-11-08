---
title: Platform Integration Features
category: Platform Integrations
priority: Tier 2-3
version: 1.0.0
date: 2025-11-07
---

# Platform Integration Features

Platform-specific integrations for popular event streaming and messaging technologies.

## Feature 10.1: Kafka/Confluent Integration

### Description
Deep integration with Apache Kafka and Confluent Platform, including topic management, schema registry, and Kafka-specific configurations.

### Problem Statement
Kafka is the dominant event streaming platform, but teams manually configure topics, partitions, and Kafka-specific settings without standardization.

### Key Capabilities

#### Topic Configuration Templates

```yaml
# specs/001-user-management/kafka/user-registered-topic.yml

topic:
  name: user.registered.v2
  partitions: 12
  replication_factor: 3
  retention_ms: 604800000  # 7 days

  configs:
    # Kafka topic configs
    cleanup.policy: delete
    compression.type: snappy
    min.insync.replicas: 2
    segment.ms: 3600000
    max.message.bytes: 1048576

  # Partitioning strategy
  partitioning:
    key_field: userId
    strategy: hash
    reason: "Maintain order per user"

  # Schema registry integration
  schema:
    subject: user.registered-value
    format: avro
    compatibility: FULL
    normalize: true

  # Access control
  acls:
    producers:
      - principal: User:user-service
        operations: [WRITE, DESCRIBE]

    consumers:
      - principal: User:email-service
        operations: [READ, DESCRIBE]
      - principal: User:analytics-pipeline
        operations: [READ, DESCRIBE]
```

#### Auto-Provisioning Script

```bash
#!/bin/bash
# .specify/scripts/bash/kafka-provision.sh

provision_kafka_topic() {
  local topic_config=$1

  # Extract configuration
  topic_name=$(yq eval '.topic.name' "$topic_config")
  partitions=$(yq eval '.topic.partitions' "$topic_config")
  replication=$(yq eval '.topic.replication_factor' "$topic_config")

  # Create topic
  kafka-topics --create \
    --bootstrap-server "${KAFKA_BOOTSTRAP_SERVERS}" \
    --topic "$topic_name" \
    --partitions "$partitions" \
    --replication-factor "$replication" \
    --config $(generate_topic_configs "$topic_config")

  # Register schema
  schema_file="specs/*/schemas/${topic_name}.avro"
  if [ -f "$schema_file" ]; then
    confluent schema-registry register \
      --subject "${topic_name}-value" \
      --schema-file "$schema_file"
  fi

  # Set up ACLs
  setup_acls "$topic_name" "$topic_config"
}
```

#### Kafka Consumer Groups Configuration

```yaml
# Consumer group configuration
consumer_groups:
  - name: email-service-user-events
    topics:
      - user.registered.v2
      - user.verified.v1
    configs:
      enable.auto.commit: false
      auto.offset.reset: earliest
      max.poll.records: 500
      session.timeout.ms: 30000

  - name: analytics-pipeline
    topics:
      - user.registered.v2
    configs:
      enable.auto.commit: true
      auto.offset.reset: latest
      max.poll.records: 1000
```

#### Kafka Streams Topology

```yaml
# Kafka Streams topology definition
streams_topology:
  application_id: user-event-enrichment
  input_topics:
    - user.registered.v2
  output_topics:
    - user.enriched.v1

  processors:
    - name: lookup-profile
      type: transform
      operation: join
      join_table: user-profiles
      key_field: userId

    - name: filter-test-users
      type: filter
      condition: "email not like '%@test.com'"

    - name: enrich-location
      type: transform
      operation: http-call
      endpoint: https://api.ipgeolocation.io
      cache_ttl: 3600
```

### Priority
**Tier 2** - Important for Kafka users (majority of event-driven systems).

---

## Feature 10.2: AWS EventBridge Integration

### Description
Integration with AWS EventBridge for serverless event-driven architectures, including rule definitions, schema registry, and event bus configuration.

### Problem Statement
Teams using AWS EventBridge manually configure event patterns, rules, and targets without proper documentation or version control.

### Key Capabilities

#### EventBridge Event Pattern Template

```yaml
# specs/001-user-management/eventbridge/user-registered-pattern.yml

eventbridge:
  event_bus: user-management-events
  rule_name: user-registered-to-email-service

  event_pattern:
    source:
      - user.service
    detail-type:
      - User Registered
    detail:
      email:
        - exists: true
      # Pattern matching
      registrationSource:
        - anything-but: ["test", "demo"]

  targets:
    - arn: arn:aws:lambda:us-east-1:123456789:function:send-welcome-email
      input_transformer:
        input_paths:
          userId: "$.detail.userId"
          email: "$.detail.email"
        input_template: |
          {
            "action": "send_welcome_email",
            "userId": "<userId>",
            "email": "<email>"
          }

    - arn: arn:aws:sqs:us-east-1:123456789:queue/user-events-dlq
      dead_letter_config:
        arn: arn:aws:sqs:us-east-1:123456789:queue/dlq

  # Schema registry integration
  schema:
    registry: user-events-registry
    name: user.registered@UserRegistered
    format: OpenAPI3
```

#### CloudFormation/Terraform Generation

```hcl
# Auto-generated Terraform

resource "aws_cloudwatch_event_rule" "user_registered" {
  name           = "user-registered-to-email-service"
  event_bus_name = "user-management-events"

  event_pattern = jsonencode({
    source      = ["user.service"]
    detail-type = ["User Registered"]
    detail = {
      email = [{ exists = true }]
      registrationSource = [{ "anything-but" = ["test", "demo"] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "email_lambda" {
  rule           = aws_cloudwatch_event_rule.user_registered.name
  event_bus_name = "user-management-events"
  arn            = "arn:aws:lambda:us-east-1:123456789:function:send-welcome-email"

  input_transformer {
    input_paths = {
      userId = "$.detail.userId"
      email  = "$.detail.email"
    }

    input_template = <<EOF
{
  "action": "send_welcome_email",
  "userId": <userId>,
  "email": <email>
}
EOF
  }

  dead_letter_config {
    arn = "arn:aws:sqs:us-east-1:123456789:queue/dlq"
  }
}
```

#### EventBridge Archive & Replay

```yaml
# Event archive configuration
archive:
  name: user-events-archive
  event_bus: user-management-events
  retention_days: 90

  event_pattern:
    source:
      - user.service
    detail-type:
      - User Registered
      - User Verified
      - User Deleted

# Replay configuration
replay:
  name: replay-user-events-nov-2025
  archive: user-events-archive
  start_time: "2025-11-01T00:00:00Z"
  end_time: "2025-11-07T23:59:59Z"
  destination: user-management-events-replay
```

### Priority
**Tier 3** - Important for AWS serverless users.

---

## Feature 10.3: Azure Event Grid/Service Bus Integration

### Description
Integration with Azure Event Grid and Service Bus for event-driven architectures on Azure.

### Problem Statement
Azure users lack standardized templates and tooling for Event Grid topics, subscriptions, and Service Bus configuration.

### Key Capabilities

#### Azure Event Grid Topic Configuration

```yaml
# specs/001-user-management/azure/user-registered-topic.yml

event_grid:
  topic:
    name: user-events
    location: eastus
    resource_group: event-driven-rg

  event_type: UserRegistered
  schema: CloudEventSchemaV1_0

  # Event Grid subscription
  subscriptions:
    - name: email-service-subscription
      endpoint_type: webhook
      endpoint_url: https://email-service.company.com/webhooks/events

      filter:
        subject_begins_with: /users/
        subject_ends_with: /registered
        included_event_types:
          - UserRegistered
        advanced_filters:
          - operator: StringIn
            key: data.registrationSource
            values: ["web", "mobile"]

      retry_policy:
        max_delivery_attempts: 30
        event_time_to_live_minutes: 1440

      dead_letter_destination:
        endpoint_type: storage_blob
        resource_id: /subscriptions/.../storageAccounts/eventsdlq

    - name: analytics-subscription
      endpoint_type: event_hub
      endpoint_url: /subscriptions/.../eventHubs/analytics-events
```

#### Azure Service Bus Queue Configuration

```yaml
# Azure Service Bus configuration
service_bus:
  namespace: company-events
  location: eastus

  queues:
    - name: user-registered-queue
      max_size_mb: 5120
      default_message_ttl: P14D  # 14 days
      lock_duration: PT5M         # 5 minutes
      dead_lettering_on_message_expiration: true
      max_delivery_count: 10

      # Auto-forwarding
      forward_to: user-events-all

      # Partitioning
      enable_partitioning: true

  topics:
    - name: user-events
      max_size_mb: 5120
      enable_partitioning: true

      subscriptions:
        - name: email-service
          max_delivery_count: 10
          lock_duration: PT5M

          rules:
            - name: registration-filter
              filter_type: sql
              sql_expression: "eventType = 'UserRegistered'"

        - name: analytics
          max_delivery_count: 5
```

#### ARM Template Generation

```json
// Auto-generated ARM template
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.EventGrid/topics",
      "apiVersion": "2021-12-01",
      "name": "user-events",
      "location": "eastus",
      "properties": {
        "inputSchema": "CloudEventSchemaV1_0"
      }
    },
    {
      "type": "Microsoft.EventGrid/eventSubscriptions",
      "apiVersion": "2021-12-01",
      "name": "email-service-subscription",
      "properties": {
        "destination": {
          "endpointType": "WebHook",
          "properties": {
            "endpointUrl": "https://email-service.company.com/webhooks/events"
          }
        },
        "filter": {
          "includedEventTypes": ["UserRegistered"],
          "advancedFilters": [
            {
              "operatorType": "StringIn",
              "key": "data.registrationSource",
              "values": ["web", "mobile"]
            }
          ]
        },
        "retryPolicy": {
          "maxDeliveryAttempts": 30,
          "eventTimeToLiveInMinutes": 1440
        }
      }
    }
  ]
}
```

### Priority
**Tier 3** - Important for Azure users.

---

## Common Features Across Platforms

### Multi-Cloud Event Format

```yaml
# Cloud-agnostic event format with platform-specific adapters

event:
  id: evt-12345
  type: user.registered
  version: 2.0.0
  source: user-service
  time: 2025-11-07T14:30:00Z

  data:
    userId: user-123
    email: user@example.com

  # Platform-specific metadata
  platforms:
    kafka:
      topic: user.registered.v2
      partition_key: userId
      headers:
        schema-version: "2.0.0"

    eventbridge:
      detail_type: User Registered
      event_bus: user-management-events
      source: user.service

    azure_event_grid:
      subject: /users/user-123/registered
      event_type: UserRegistered
      data_version: "2.0.0"
```

### Platform Abstraction Layer

```typescript
// Auto-generated platform-agnostic publisher

interface EventPublisher {
  publish(event: DomainEvent): Promise<void>;
}

// Kafka implementation
class KafkaEventPublisher implements EventPublisher {
  async publish(event: DomainEvent): Promise<void> {
    await this.kafka.send({
      topic: event.platformConfig.kafka.topic,
      key: event.data[event.platformConfig.kafka.partition_key],
      value: event.data
    });
  }
}

// EventBridge implementation
class EventBridgePublisher implements EventPublisher {
  async publish(event: DomainEvent): Promise<void> {
    await this.eventBridge.putEvents({
      Entries: [{
        EventBusName: event.platformConfig.eventbridge.event_bus,
        Source: event.platformConfig.eventbridge.source,
        DetailType: event.platformConfig.eventbridge.detail_type,
        Detail: JSON.stringify(event.data)
      }]
    });
  }
}
```

---

## Related Features
- **Feature 5.1:** AsyncAPI Code Generator (generates platform-specific code)
- **Feature 9.1:** Event Schema Registry Integration (Confluent integration)
- **Feature 2.1:** Schema-First Workflow (platform-agnostic schemas)

## Resources
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [AWS EventBridge](https://docs.aws.amazon.com/eventbridge/)
- [Azure Event Grid](https://docs.microsoft.com/azure/event-grid/)
- [Azure Service Bus](https://docs.microsoft.com/azure/service-bus-messaging/)

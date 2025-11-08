---
title: Monitoring & Observability Features
category: Observability
priority: Tier 2-3
version: 1.0.0
date: 2025-11-07
---

# Monitoring & Observability Features

Runtime monitoring and drift detection between design-time specifications and production reality.

## Feature 9.1: Event Schema Registry Integration

### Description
Bidirectional integration with schema registries (Confluent, AWS Glue, Apicurio) to synchronize design-time schemas with runtime registries.

### Problem Statement
Design-time schemas in SpecKit and runtime schemas in registries diverge, causing production issues and documentation drift.

### Key Capabilities

#### Schema Registry Sync

**Push Schemas to Registry:**
```bash
# Publish SpecKit schemas to Confluent Schema Registry
speckit schema publish user.registered --registry confluent

Publishing to Confluent Schema Registry...
✓ Schema user.registered v2.0.0 registered
  Subject: user.registered-value
  Schema ID: 12345
  Version: 3
  Compatibility: FULL
```

**Pull Schemas from Registry:**
```bash
# Import production schemas to SpecKit
speckit schema import --registry confluent --subject "user.registered-value"

Importing from Confluent Schema Registry...
✓ Downloaded schema user.registered v2.0.0
✓ Created specs/user-events/schemas/user-registered.v2.0.0.avro
✓ Updated EventCatalog documentation
```

#### Compatibility Validation

```bash
# Validate local schema against registry compatibility rules
speckit schema validate user.registered --check-compatibility

Checking compatibility with registry...

Subject: user.registered-value
Local version: 2.1.0
Registry version: 2.0.0
Compatibility mode: FULL

Compatibility Check: PASSED ✓
  ✓ Backward compatible (consumers using v2.0.0 can read v2.1.0)
  ✓ Forward compatible (consumers using v2.1.0 can read v2.0.0)

Safe to publish.
```

#### Registry Configuration

```yaml
# .specify/config/schema-registry.yml

registries:
  confluent:
    type: confluent
    url: https://schema-registry.company.com
    auth:
      type: basic
      username: ${SCHEMA_REGISTRY_USER}
      password: ${SCHEMA_REGISTRY_PASSWORD}

  aws-glue:
    type: aws-glue
    region: us-east-1
    registry_name: event-schemas
    auth:
      type: iam
      profile: production

sync:
  auto_publish: false  # Require manual publish
  auto_import: true    # Import new registry schemas daily

  compatibility:
    enforce: true
    default_mode: FULL
```

### Priority
**Tier 2** - Important for runtime schema management.

---

## Feature 9.2: Event Telemetry Template

### Description
Standardized templates for event observability metadata, including tracing, metrics, and logging correlation.

### Problem Statement
Inconsistent telemetry across events makes debugging distributed systems difficult.

### Key Capabilities

#### Telemetry Metadata Template

```json
{
  "eventId": "evt-12345",
  "eventType": "user.registered",
  "eventVersion": "2.0.0",
  "occurredAt": "2025-11-07T14:30:00.000Z",

  "tracing": {
    "traceId": "trace-abc-123",
    "spanId": "span-xyz-789",
    "parentSpanId": "span-parent-456",
    "sampled": true
  },

  "correlation": {
    "correlationId": "corr-user-reg-12345",
    "causationId": "evt-00001",
    "conversationId": "conv-signup-flow-789"
  },

  "metadata": {
    "source": "user-service",
    "sourceVersion": "1.5.2",
    "sourceHost": "pod-user-svc-3",
    "environment": "production",
    "region": "us-east-1"
  },

  "metrics": {
    "processingTimeMs": 145,
    "queuedTimeMs": 23
  },

  "payload": {
    "userId": "user-123",
    "email": "user@example.com"
  }
}
```

#### OpenTelemetry Integration

```typescript
// Auto-generated telemetry wrapper

import { trace, context, SpanStatusCode } from '@opentelemetry/api';

export class UserRegisteredPublisherWithTelemetry {
  private tracer = trace.getTracer('user-service');

  async publish(event: UserRegistered): Promise<void> {
    const span = this.tracer.startSpan('publish.user.registered', {
      attributes: {
        'event.type': 'user.registered',
        'event.version': '2.0.0',
        'event.id': event.eventId,
        'user.id': event.userId
      }
    });

    try {
      // Inject trace context into event headers
      const headers = this.injectTraceContext();

      await this.eventBus.publish({
        topic: 'user.registered.v2',
        value: event,
        headers: {
          ...headers,
          'event-type': 'user.registered',
          'event-version': '2.0.0'
        }
      });

      span.setStatus({ code: SpanStatusCode.OK });
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error.message
      });
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  }
}
```

#### Metrics Template

```yaml
# Auto-generated Prometheus metrics

# Event publication metrics
event_published_total{
  event_type="user.registered",
  event_version="2.0.0",
  source="user-service"
} 12450

event_publish_duration_seconds{
  event_type="user.registered",
  quantile="0.5"
} 0.145

event_publish_duration_seconds{
  event_type="user.registered",
  quantile="0.95"
} 0.523

event_publish_duration_seconds{
  event_type="user.registered",
  quantile="0.99"
} 1.234

# Event consumption metrics
event_consumed_total{
  event_type="user.registered",
  consumer="email-service"
} 12448

event_consume_duration_seconds{
  event_type="user.registered",
  consumer="email-service",
  quantile="0.95"
} 0.234

event_consume_errors_total{
  event_type="user.registered",
  consumer="email-service",
  error_type="validation_error"
} 2
```

#### Structured Logging Template

```typescript
// Auto-generated structured logging

logger.info('Event published', {
  eventId: event.eventId,
  eventType: 'user.registered',
  eventVersion: '2.0.0',
  correlationId: event.correlationId,
  userId: event.userId,
  processingTime: 145,
  timestamp: new Date().toISOString(),

  // Standardized fields for log aggregation
  service: 'user-service',
  environment: 'production',
  logLevel: 'info',
  traceId: getCurrentTraceId()
});
```

### Priority
**Tier 2-3** - Important for production observability.

---

## Feature 9.3: Event Catalog Drift Detection

### Description
Detect and report divergence between EventCatalog documentation, SpecKit specifications, and production runtime.

### Problem Statement
Documentation becomes stale as production systems evolve independently from design specifications.

### Key Capabilities

#### Multi-Source Drift Detection

```
Drift Detection Report
======================
Generated: 2025-11-07 14:30:00

Sources Compared:
- SpecKit Specs (local)
- EventCatalog (catalog.company.com)
- Confluent Schema Registry (production)
- Kafka Topics (production cluster)

CRITICAL DRIFTS (5):
==================

1. user.registered
   SpecKit:         v2.1.0 (has field: preferences)
   EventCatalog:    v2.0.0 (missing field: preferences)
   Schema Registry: v2.1.0 (matches SpecKit)
   Production:      Publishing v2.1.0 (75%), v2.0.0 (25%)

   → Action: Update EventCatalog to v2.1.0

2. order.placed
   SpecKit:         v3.0.0 (field 'total' type: decimal)
   EventCatalog:    v3.0.0 (field 'total' type: decimal)
   Schema Registry: v3.0.0 (field 'total' type: decimal)
   Production:      Publishing v2.5.0 (100%)

   → Action: Production not using latest schema! Investigate.

3. payment.authorized
   SpecKit:         Not found
   EventCatalog:    v1.0.0
   Schema Registry: v1.0.0
   Production:      Publishing v1.0.0

   → Action: Add SpecKit spec for existing event

WARNINGS (8):
=============

4. inventory.reserved
   SpecKit:         v1.5.0
   EventCatalog:    v1.5.0
   Schema Registry: v1.4.0 (older version)
   Production:      Publishing v1.5.0

   → Action: Update schema registry (or revert production)

5. shipment.created
   SpecKit:         Last updated 90 days ago
   EventCatalog:    Last updated 90 days ago
   Schema Registry: v1.0.0
   Production:      No messages in last 7 days

   → Action: Possible dead event, consider deprecation
```

#### Automated Drift Checks

```bash
#!/bin/bash
# .specify/scripts/bash/drift-detection.sh

detect_drift() {
  echo "=== Drift Detection ==="

  # Compare SpecKit vs Schema Registry
  drift_spec_registry=$(compare_specs_to_registry)

  # Compare SpecKit vs EventCatalog
  drift_spec_catalog=$(compare_specs_to_catalog)

  # Compare Schema Registry vs Production
  drift_registry_production=$(compare_registry_to_production)

  # Generate report
  generate_drift_report "$drift_spec_registry" "$drift_spec_catalog" "$drift_registry_production"
}

# Compare local specs with schema registry
compare_specs_to_registry() {
  for spec_file in specs/*/schemas/*.avro; do
    event_name=$(extract_event_name "$spec_file")
    local_version=$(extract_version "$spec_file")

    # Query schema registry
    registry_version=$(curl -s "https://schema-registry/subjects/${event_name}-value/versions/latest" | jq -r '.version')

    if [ "$local_version" != "$registry_version" ]; then
      echo "DRIFT: $event_name (spec: $local_version, registry: $registry_version)"
    fi
  done
}
```

#### CI/CD Integration

```yaml
# .github/workflows/drift-detection.yml

name: Drift Detection

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Drift Detection
        run: |
          .specify/scripts/bash/drift-detection.sh > drift-report.txt

      - name: Check for Critical Drift
        run: |
          if grep -q "CRITICAL" drift-report.txt; then
            echo "::error::Critical drift detected!"
            exit 1
          fi

      - name: Post to Slack
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "⚠️ Critical schema drift detected!",
              "attachments": [{
                "color": "danger",
                "text": "Check drift report for details."
              }]
            }
```

#### Auto-Remediation Suggestions

```
Drift Remediation Suggestions
==============================

For: user.registered drift (SpecKit v2.1.0 ≠ EventCatalog v2.0.0)

Option 1: Update EventCatalog (Recommended)
  $ speckit eventcatalog generate user.registered

Option 2: Revert SpecKit to v2.0.0
  $ git checkout HEAD~3 specs/user-events/schemas/user-registered.avro

Option 3: Manual reconciliation
  Review changes and decide which version is source of truth

Automated fix available: Yes
Run: $ speckit drift fix user.registered --auto
```

### Priority
**Tier 2-3** - Important for maintaining documentation accuracy.

---

## Related Features
- **Feature 1.3:** Bi-Directional Sync (prevents drift)
- **Feature 2.2:** Schema Evolution Planner (manages schema changes)
- **Feature 4.3:** Event Catalog Health Dashboard (visualizes drift)

## Resources
- [Confluent Schema Registry](https://docs.confluent.io/platform/current/schema-registry/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Prometheus Metrics](https://prometheus.io/docs/practices/naming/)

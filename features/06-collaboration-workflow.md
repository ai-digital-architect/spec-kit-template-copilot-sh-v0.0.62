---
title: Collaboration & Workflow Features
category: Team Collaboration
priority: Tier 2
version: 1.0.0
date: 2025-11-07
---

# Collaboration & Workflow Features

Structured processes for team collaboration on event design, evolution, and lifecycle management.

## Feature 6.1: Event Proposal Workflow

### Description
A structured process for proposing new events that includes stakeholder identification, review cycles, and approval tracking.

### Problem Statement
New events are created ad-hoc without proper review, leading to inconsistent design, duplicate events, and poor communication across teams.

### Key Capabilities

#### Event Proposal Template
```markdown
---
type: event-proposal
status: draft
proposer: alice@company.com
created: 2025-11-07
---

# Event Proposal: Order Refund Requested

## Business Context
When a customer requests a refund for an order, we need to notify multiple systems (finance, inventory, customer service) to coordinate the refund process.

## Proposed Event Name
`order.refund.requested`

## Domain
order-management

## Stakeholders
- **Proposer:** Alice (Order Service Team)
- **Reviewers Required:**
  - Finance Team (payment processing impact)
  - Inventory Team (restocking coordination)
  - Customer Service (refund status tracking)
- **Informed:**
  - Analytics Team
  - Fraud Detection Team

## Proposed Schema
```avro
{
  "type": "record",
  "name": "OrderRefundRequested",
  "fields": [
    {"name": "orderId", "type": "string"},
    {"name": "customerId", "type": "string"},
    {"name": "refundAmount", "type": "decimal"},
    {"name": "reason", "type": "string"},
    {"name": "requestedAt", "type": "long", "logicalType": "timestamp-millis"}
  ]
}
```

## Expected Consumers
1. Finance Service - Process refund
2. Inventory Service - Update stock levels
3. Customer Service Dashboard - Track refund status
4. Analytics Pipeline - Refund metrics

## Alternatives Considered
1. **HTTP API call instead of event** - Rejected because multiple systems need to react
2. **Reuse existing order.cancelled event** - Rejected because semantics are different

## Questions for Review
1. Should we include line items in the event or let consumers fetch from Order API?
2. What's the retention policy for refund events (compliance requirement)?
3. Should we emit separate events for partial vs full refunds?

## Approval Checklist
- [ ] Finance Team approval
- [ ] Inventory Team approval
- [ ] Customer Service approval
- [ ] Schema validated against governance rules
- [ ] EventCatalog documentation created
- [ ] No duplicate events found
```

#### Workflow States
```
Draft → Under Review → Approved → Implemented → Deprecated

Transitions:
- Draft → Under Review: When proposer submits for review
- Under Review → Approved: When all required approvals received
- Under Review → Draft: When changes requested
- Approved → Implemented: When event is deployed to production
- Implemented → Deprecated: When event lifecycle ends
```

#### Review & Approval Tracking
```bash
# .specify/scripts/bash/event-proposal.sh

submit_for_review() {
  local proposal_file=$1

  # Extract stakeholders
  reviewers=$(extract_required_reviewers "$proposal_file")

  # Create review requests
  for reviewer in $reviewers; do
    create_review_request "$reviewer" "$proposal_file"
  done

  # Update status
  update_proposal_status "$proposal_file" "under_review"

  # Send notifications
  notify_stakeholders "$reviewers" "$proposal_file"
}

check_approval_status() {
  local proposal_file=$1

  required_approvals=$(extract_required_reviewers "$proposal_file")
  received_approvals=$(count_approvals "$proposal_file")

  if [ "$required_approvals" -eq "$received_approvals" ]; then
    update_proposal_status "$proposal_file" "approved"
    notify_proposer "All approvals received. Ready to implement."
  fi
}
```

### Success Metrics
- **Review Cycle Time:** <3 days average from submission to approval
- **Duplicate Prevention:** 95% reduction in duplicate event creation
- **Stakeholder Alignment:** 100% of required approvals before implementation

### Priority
**Tier 2** - Important for large organizations with multiple teams.

---

## Feature 6.2: Cross-Team Event Discovery

### Description
Search and discover events across teams, with similarity detection to prevent duplicates and encourage reuse.

### Problem Statement
Teams create duplicate events because they don't know what events already exist across the organization.

### Key Capabilities

#### Semantic Search
```bash
speckit event search "user completed registration"

Results:
1. user.registered (user-management domain)
   Similarity: 95%
   Published by: Identity Team
   Description: Fired when user completes registration process

2. account.created (account-management domain)
   Similarity: 78%
   Published by: Account Team
   Description: Fired when new account is created

3. signup.completed (marketing domain)
   Similarity: 72%
   Published by: Marketing Team
   Description: Fired when signup funnel is completed
```

#### Duplicate Detection
```
⚠️  Similar Event Detected

You are creating: user.registration.completed

Existing similar events:
┌───────────────────────┬────────────┬──────────────┬───────────┐
│ Event Name            │ Similarity │ Domain       │ Owner     │
├───────────────────────┼────────────┼──────────────┼───────────┤
│ user.registered       │ 92%        │ user-mgmt    │ Identity  │
│ signup.completed      │ 75%        │ marketing    │ Marketing │
└───────────────────────┴────────────┴──────────────┴───────────┘

Recommendations:
1. Reuse 'user.registered' if semantics match
2. Consume existing event instead of creating new one
3. If truly different, justify uniqueness in proposal
```

#### Event Catalog Browser
```markdown
# Event Catalog by Domain

## User Management (15 events)
- user.registered - User completes registration
- user.verified - Email/phone verification completed
- user.login - User authentication successful
- user.logout - User session ended
- ...

## Order Management (23 events)
- order.placed - Customer places order
- order.confirmed - Order confirmation received
- order.shipped - Order dispatched from warehouse
- ...

## Payment (12 events)
...
```

#### Usage Analytics
```
Event: user.registered

Producers (1):
- user-service (primary)

Consumers (12):
- email-service (active, 10K msgs/day)
- analytics-pipeline (active, 10K msgs/day)
- crm-sync (active, 500 msgs/day)
- fraud-detection (active, 10K msgs/day)
- marketing-automation (deprecated, 0 msgs/day)
- ...

Consumer health:
✓ 11 healthy consumers
✗ 1 deprecated consumer (should be removed)

Recommendations:
- Popular event (12 consumers)
- Good candidate for reuse
- Consider creating consumer group best practices doc
```

### Priority
**Tier 2** - Prevents duplication and encourages reuse.

---

## Feature 6.3: Event Deprecation Workflow

### Description
Managed process for safely retiring events, including consumer notification, migration support, and sunset enforcement.

### Problem Statement
Events are never retired, leading to accumulation of unused events, maintenance burden, and technical debt.

### Key Capabilities

#### Deprecation Notice
```markdown
---
type: deprecation-notice
event: user.login.v1
deprecated_date: 2025-11-07
sunset_date: 2026-02-07
replacement: user.login.v2
---

# Deprecation Notice: user.login.v1

## Reason for Deprecation
Schema lacks required security fields (IP address, user agent) needed for fraud detection.

## Replacement Event
`user.login.v2` - Includes additional security context

## Migration Timeline
- **2025-11-07:** Deprecation announced (Today)
- **2025-12-07:** Stop publishing to v1 (30 days)
- **2026-01-07:** Consumer migration deadline (60 days)
- **2026-02-07:** Topic deletion (90 days)

## Affected Consumers (8)
1. session-manager ✓ Migrated (2025-11-10)
2. analytics-pipeline ⏳ In Progress
3. audit-logger ⏳ Scheduled (2025-11-20)
4. fraud-detection ⏳ Scheduled (2025-11-25)
5. user-activity-tracker ❌ Not Started
6. login-metrics ❌ Not Started
7. security-dashboard ❌ Not Started
8. compliance-reporter ❌ Not Started

## Migration Guide
See [migration-guide.md](./migration-guide.md)

## Support
Contact: identity-team@company.com
Slack: #identity-team-support
```

#### Consumer Migration Tracker
```bash
# Track consumer migration progress

speckit event deprecation status user.login.v1

Deprecation Status: user.login.v1
===================================

Timeline:
├─ 2025-11-07 ✓ Deprecation announced
├─ 2025-12-07 ⏳ Stop publishing (23 days remaining)
├─ 2026-01-07 ⏳ Migration deadline (61 days remaining)
└─ 2026-02-07 ⏳ Topic deletion (92 days remaining)

Migration Progress: 1/8 (12.5%)
████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 12.5%

Consumer Status:
✓ session-manager (migrated 3 days ago)
⏳ analytics-pipeline (in progress, ETA: 2025-11-15)
⏳ audit-logger (scheduled: 2025-11-20)
⏳ fraud-detection (scheduled: 2025-11-25)
❌ user-activity-tracker (not started, at risk)
❌ login-metrics (not started, at risk)
❌ security-dashboard (not started, at risk)
❌ compliance-reporter (not started, at risk)

⚠️  WARNING: 4 consumers have not started migration with 23 days until cutoff
```

#### Automated Sunset Enforcement
```bash
# Automatically enforce sunset timeline

# Phase 1: Warning period (deprecation + 30 days)
# - Add deprecation header to all events
# - Log warnings when event is produced/consumed

# Phase 2: Stop publishing (deprecation + 30 days)
# - Producer automatically stops publishing
# - Consumers still can read existing messages

# Phase 3: Read-only (deprecation + 60 days)
# - Topic marked read-only
# - No new messages accepted

# Phase 4: Topic deletion (deprecation + 90 days)
# - Topic automatically deleted
# - Final backup created
```

#### Migration Guide Generator
```markdown
# Migration Guide: user.login.v1 → user.login.v2

## Schema Changes

### Added Fields (Non-Breaking)
- `ipAddress` (string) - Client IP address
- `userAgent` (string) - Client user agent
- `sessionId` (string) - Session identifier

### Changed Fields
None

### Removed Fields
None

## Code Changes

### Before (v1)
```typescript
await eventBus.publish('user.login.v1', {
  userId: user.id,
  timestamp: Date.now()
});
```

### After (v2)
```typescript
await eventBus.publish('user.login.v2', {
  userId: user.id,
  timestamp: Date.now(),
  ipAddress: request.ip,
  userAgent: request.headers['user-agent'],
  sessionId: session.id
});
```

## Consumer Updates

### Before
```typescript
consumer.on('user.login.v1', (event) => {
  trackLogin(event.userId, event.timestamp);
});
```

### After
```typescript
consumer.on('user.login.v2', (event) => {
  trackLogin({
    userId: event.userId,
    timestamp: event.timestamp,
    ipAddress: event.ipAddress,
    userAgent: event.userAgent,
    sessionId: event.sessionId
  });
});
```

## Testing Checklist
- [ ] Unit tests updated for new schema
- [ ] Integration tests pass with v2 events
- [ ] Backward compatibility verified (if needed)
- [ ] Performance testing completed
- [ ] Staging deployment successful

## Rollback Plan
If issues arise after migration:
1. Revert to v1 topic consumption
2. Producer continues dual publishing (if enabled)
3. Debug issues in v2 consumer
4. Re-deploy when fixed
```

### Success Metrics
- **Sunset Compliance:** 95%+ consumers migrate before deadline
- **Cleanup Rate:** 90% of deprecated events removed within 90 days
- **Technical Debt:** 30% reduction in unused events

### Priority
**Tier 2** - Important for maintaining catalog health.

---

## Related Features
- **Feature 1.1:** EventCatalog Generator (documents proposals)
- **Feature 2.2:** Schema Evolution Planner (migration support)
- **Feature 4.3:** Event Catalog Health Dashboard (tracks orphaned events)

## Resources
- [Semantic Versioning](https://semver.org/)
- [Deprecation Best Practices](https://www.ietf.org/rfc/rfc8594.txt)

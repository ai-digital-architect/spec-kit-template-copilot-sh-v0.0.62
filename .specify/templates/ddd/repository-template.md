# ============================================================
# FILE: repository-template.md
# ============================================================
---
title: "Repository: [Repository Name]"
context: "[Bounded Context Name]"
aggregate: "[Aggregate Root Name]"
version: "1.0.0"
---

# Repository: [Repository Name]

## Purpose

[Abstract persistence for [Aggregate] - provides collection-like interface]

## Aggregate Root

**Manages**: [Aggregate Root Entity Name]

**Scope**: This repository persists and retrieves entire aggregate (root + all child entities/value objects)

## Interface (Port)

Define as interface in **domain layer**; implement in **infrastructure layer**.

```typescript
interface [RepositoryName] {
  // Required methods
  findById(id: AggregateId): Promise;
  save(aggregate: Aggregate): Promise;
  delete(id: AggregateId): Promise;
  
  // Optional query methods
  findByX(x: Type): Promise;
  existsById(id: AggregateId): Promise;
  count(): Promise;
}
```

## Methods

### findById
```
findById(id: AggregateId): Promise<Aggregate | null>
```
- **Purpose**: Retrieve aggregate by unique identifier
- **Returns**: Full aggregate instance or null if not found
- **Includes**: All child entities and value objects
- **Caching**: [Strategy, if applicable]

### save
```
save(aggregate: Aggregate): Promise<void>
```
- **Purpose**: Persist aggregate state
- **Behavior**: Upsert (insert if new, update if exists)
- **Atomicity**: All aggregate parts saved in single transaction
- **Versioning**: [Optimistic locking? Version field?]
- **Events**: Does NOT publish events (application service does)

### delete
```
delete(id: AggregateId): Promise<void>
```
- **Purpose**: Remove aggregate from persistence
- **Type**: Hard delete | Soft delete (set deleted flag)
- **Cascades**: [Child entities deleted automatically]

### Custom Query Methods

#### [findByCustomCriteria]
```
findByX(x: Type): Promise<Aggregate[]>
```
- **Purpose**: [Why this query is needed]
- **Performance**: [Indexed? Pagination?]
- **Returns**: Collection of aggregates

**⚠️ Repository Anti-Patterns to Avoid**:
- ❌ Don't return partial aggregates (always full aggregate or nothing)
- ❌ Don't have methods that update single properties (use save with full aggregate)
- ❌ Don't put business logic in repository (keep it pure persistence)

## Persistence Mapping

### Technology
- **Database**: [PostgreSQL, MongoDB, DynamoDB, etc.]
- **ORM/ODM**: [Prisma, TypeORM, Mongoose, etc.]

### Schema

#### Main Table/Collection: `[table_name]`
| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | UUID | PK | Aggregate ID |
| [field1] | [type] | [NOT NULL, etc.] | [Notes] |
| version | INT | NOT NULL | Optimistic locking |
| created_at | TIMESTAMP | NOT NULL | Audit |
| updated_at | TIMESTAMP | NOT NULL | Audit |

#### Related Tables (if applicable)
- **[child_table]**: [Description of relationship]

### Mapping Strategy
- **Aggregate Root**: → Main table
- **Child Entities**: → Related tables with FK to root OR embedded JSON
- **Value Objects**: → Embedded columns OR JSON field
- **Collections**: → Separate table with FK OR JSON array

## Transactional Consistency

**Transaction Scope**: Entire aggregate

**Concurrency Control**:
- **Optimistic Locking**: Use version field
- **Conflict Resolution**: [Strategy when version mismatch occurs]

**Isolation Level**: [READ_COMMITTED, REPEATABLE_READ, etc.]

## Caching Strategy

**Cache**: Yes | No

**If Yes**:
- **Technology**: [Redis, in-memory, etc.]
- **TTL**: [Duration]
- **Invalidation**: [On save/delete]
- **Cache Key**: [Strategy, e.g., "aggregate:{id}"]

## Performance Considerations

### Lazy Loading
[Which associations are lazy-loaded vs eager-loaded]

### Indexing
- Index on: [field1, field2, etc.]
- Rationale: [Why these indexes]

### Pagination
[Support for paginated queries? Cursor-based or offset-based?]

### N+1 Query Prevention
[Strategy to avoid N+1 problems]

## Implementation Example

```typescript
// Infrastructure layer implementation
class PostgresOrderRepository implements OrderRepository {
  constructor(private db: Database) {}
  
  async findById(id: OrderId): Promise {
    const row = await this.db.query(
      'SELECT * FROM orders WHERE id = $1',
      [id.value]
    );
    if (!row) return null;
    return this.mapToAggregate(row);
  }
  
  async save(order: Order): Promise {
    const data = this.mapToData(order);
    await this.db.query(
      'INSERT INTO orders (...) VALUES (...) ON CONFLICT (id) DO UPDATE SET ...',
      [...data]
    );
  }
  
  async delete(id: OrderId): Promise {
    await this.db.query('DELETE FROM orders WHERE id = $1', [id.value]);
  }
  
  private mapToAggregate(row: any): Order {
    // Map database row to domain aggregate
  }
  
  private mapToData(order: Order): any {
    // Map domain aggregate to database row
  }
}
```

## Testing Strategy

### Unit Tests (with Mock Repository)
- Test domain logic without real database
- Mock repository returns test aggregates

### Integration Tests (with Real Database)
- Test actual persistence and retrieval
- Verify mapping correctness
- Test concurrency scenarios (optimistic locking)

### Test Data Builder
```typescript
// Helper for tests
class OrderTestBuilder {
  build(): Order {
    return Order.create(...);
  }
}
```

## Design Decisions

**Why This Repository Abstraction?**
- Decouples domain from persistence technology
- Allows swapping database implementations
- Simplifies testing (mock repositories)

**ORM vs Raw SQL?**
[Rationale for choice]

## References

- [Link to aggregate]
- [Link to bounded context]
- [Database schema documentation]

---

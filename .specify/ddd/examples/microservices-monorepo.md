
# Input

Analyze: https://github.com/example/ecommerce-platform
Monorepo with:
- services/catalog (Node.js/Express, Prisma ORM, PostgreSQL)
- services/orders (Java/Spring Boot, JPA, MySQL)
- services/payments (Python/FastAPI, SQLAlchemy, PostgreSQL)
- shared-lib/events (TypeScript event definitions)
- infrastructure/kubernetes (K8s manifests, Helm charts)

# Analysis Process

## Repository Scan Results

### Detected Contexts (by service boundaries)
#### Catalog (Node.js service)
#### Orders (Java service)
#### Payments (Python service)

### Data Models Extracted

#### Catalog: Product, Category, ProductImage entities (from Prisma schema)
#### Orders: Order, OrderLine, Customer, Address entities (from JPA annotations)
#### Payments: Transaction, PaymentMethod, Refund entities (from SQLAlchemy models)

### Events Discovered (from shared-lib/events)
#### ProductPublished, OrderPlaced, PaymentProcessed, InventoryUpdated

### Integration Points
#### Orders service imports @shared/events → Conformist pattern
#### Payments service has stripe-adapter.py → ACL pattern identified
#### Catalog service has no direct dependencies → potential upstream

### Inferred Relationships
#### Catalog → Orders: Published Language (Catalog publishes ProductPublished; Orders subscribes)
#### Orders → Payments: Customer-Supplier (Orders calls Payments API to process transactions)
#### Payments → Stripe: ACL (Payments translates domain model to Stripe API via adapter)

### Aggregates Inferred
#### Order Aggregate (from Orders Service)
   - Root: Order entity
   - Entities: OrderLine
   - Invariants detected: Order.total == sum(OrderLine.subtotals) (from validation code)
   - Transaction boundary: Single Order + all OrderLines updated atomically

## Artifacts Generated

### *model.json* with 3 bounded context, 4 aggregates, 8 domain events
### *context-map.cml* with inferred relationships
### Validation checklist with findings .
   - ✅ Aggregates enforce invariants within transaction boundaries
   - ⚠️ Open Question: Is Customer a separate aggregate or entity within Order? (no transactions found that update Customer independently)
   - ✅ Events include correlation metadata

### assumptions.md : "Assumed Payments context owns Transaction aggregate; confirm with team"
### open-questions.md : "Should Catalog and Inventory be separate contexts? Currently, stock levels are in Catalog database."



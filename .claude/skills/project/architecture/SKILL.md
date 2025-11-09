# Project Architecture Skill

## Description
Deep knowledge of this project's architecture, design patterns, and structural decisions. Use this skill when discussing system design, adding new features, or refactoring major components.

## When to Use This Skill
- User asks about system architecture or design decisions
- Planning new features that span multiple components
- Refactoring or restructuring code
- Debugging complex cross-component issues
- Explaining how different parts of the system interact

## Architecture Overview

### System Design
This is a microservices-based e-commerce platform with:
- **Frontend**: Next.js 14 with React Server Components
- **API Gateway**: Next.js API routes + tRPC
- **Services**: 
  - Auth Service (NextAuth.js)
  - Product Service
  - Order Service
  - Payment Service (Stripe integration)
- **Database**: PostgreSQL (single DB with schema separation)
- **Cache**: Redis for session and query caching
- **Storage**: S3-compatible object storage

### Key Design Patterns

#### 1. Repository Pattern
All database access goes through repository classes:
```typescript
// lib/repositories/productRepository.ts
export class ProductRepository {
  async findById(id: string): Promise<Product | null>
  async findAll(filters: ProductFilters): Promise<Product[]>
  async create(data: CreateProductDTO): Promise<Product>
  async update(id: string, data: UpdateProductDTO): Promise<Product>
}
```

#### 2. Service Layer
Business logic isolated in service classes:
```typescript
// lib/services/orderService.ts
export class OrderService {
  constructor(
    private orderRepo: OrderRepository,
    private paymentService: PaymentService,
    private inventoryService: InventoryService
  ) {}
  
  async createOrder(input: CreateOrderInput): Promise<Order>
}
```

#### 3. Error Handling
Centralized error handling with custom error classes:
- `ValidationError` - Input validation failures
- `NotFoundError` - Resource not found
- `AuthorizationError` - Permission issues
- `BusinessLogicError` - Domain-specific errors

### Component Structure
```
components/
├── ui/              # Shadcn UI components (no business logic)
├── features/        # Feature-specific components
│   ├── auth/
│   ├── products/
│   └── checkout/
└── layouts/         # Page layouts
```

### Data Flow
1. User action → Event handler in component
2. Component calls tRPC mutation/query
3. API route validates input with Zod
4. Service layer executes business logic
5. Repository performs database operations
6. Response transformed via DTO
7. Component receives typed response

### Important Constraints
- No direct Prisma calls from components
- All API inputs validated with Zod schemas
- Authentication required for all `/app/dashboard/*` routes
- File uploads limited to 10MB
- Rate limiting: 100 requests/minute per user

## Examples

### Example 1: Adding a New Feature
**User**: "I want to add a wishlist feature"
**Claude should**:
1. Reference the repository pattern
2. Suggest creating WishlistRepository
3. Create WishlistService with business logic
4. Add tRPC routes following existing patterns
5. Create UI components in features/wishlist/
6. Mention database migration needs

### Example 2: Debugging
**User**: "Orders aren't updating inventory"
**Claude should**:
1. Check OrderService.createOrder() method
2. Verify InventoryService is being called
3. Check transaction boundaries
4. Look for error handling gaps
5. Review the data flow diagram

## Related Files
- `/docs/architecture.md` - Detailed architecture docs
- `/prisma/schema.prisma` - Database schema
- `/docs/api-design.md` - API conventions
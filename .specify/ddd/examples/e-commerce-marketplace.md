
# Input
Build a marketplace where sellers list products, buyers browse and purchase via shopping carts and checkout. Include inventory management to prevent overselling, payment processing with multiple gateways, order fulfillment tracking, and notifications for order status changes.

# Expected Outputs:
## Domains Identified

### Commerce (Core): Competitive advantage in marketplace orchestration
### Payments (Supporting): Necessary but not differentiating; integrate external gateways
### Notifications (Generic): Commodity service; use email/SMS provider

## Bounded Contexts

### Catalog Context

#### Purpose: Manage product listings, categories, and search
#### Aggregates: Product (root: Product, attributes: SKU, title, description, price, images, category)
#### Events: ProductListed, ProductUpdated, ProductDelisted
#### APIs: REST (OpenAPI) for product CRUD and search


### Shopping Context

#### Purpose: Manage buyer shopping experience and cart
#### Aggregates: Cart (root: Cart, entities: CartItem, value objects: Money)
#### Commands: AddToCart, RemoveFromCart, UpdateQuantity
#### Events: ItemAddedToCart, ItemRemovedFromCart
#### Invariants: Cart total ≥ 0, item quantities > 0


### Ordering Context

#### Purpose: Process and manage customer orders
#### Aggregates: Order (root: Order, entities: OrderLine, value objects: Address, OrderStatus)
#### Commands: PlaceOrder, CancelOrder, ShipOrder
#### Events: OrderPlaced, OrderCancelled, OrderShipped, OrderDelivered
#### Invariants: Order total matches sum of lines, valid status transitions
#### Sagas: CheckoutSaga (coordinates inventory, payment, order confirmation)


### Inventory Context

#### Purpose: Track and manage stock levels
#### Aggregates: StockItem (root: StockItem, attributes: SKU, quantityOnHand, quantityReserved)
#### Commands: ReserveStock, ReleaseStock, AdjustStock
#### Events: StockReserved, StockReleased, StockDepleted
#### Invariants: quantityOnHand ≥ quantityReserved, no negative quantities


### Payment Context

#### Purpose: Process payments via external gateways
#### Aggregates: Payment (root: Payment, value objects: PaymentMethod, Amount)
#### Commands: AuthorizePayment, CapturePayment, RefundPayment
#### Events: PaymentAuthorized, PaymentCaptured, PaymentFailed, PaymentRefunded
#### Integration: ACL to translate between internal model and Stripe/PayPal APIs


### Notification Context

#### Purpose: Send transactional notifications
#### Commands: SendEmail, SendSMS
#### Events consumed: OrderPlaced, OrderShipped, PaymentFailed
#### Integration: OHS (Open Host Service) - other contexts publish events; notifications subscribes



## Context Relationships

### Ordering → Inventory: Customer-Supplier (Inventory provides stock reservation API; Ordering depends on it)
### Ordering → Payment: Conformist (Ordering consumes Payment events; no negotiation)
### Ordering → Notification: OHS/Published Language (Ordering publishes OrderPlaced event; Notification subscribes)
###  Payment → External Gateways: ACL (Payment context translates internal domain to Stripe/PayPal APIs)

### Checkout Saga (Cross - Context Workflow)
``` markdown
Trigger: CartCheckoutRequested event

Steps:
1. ReserveStock command → Inventory context
   - Success: Wait for StockReserved event → Step 2
   - Failure: Emit CheckoutFailed event; end
   
2. AuthorizePayment command → Payment context
   - Success: Wait for PaymentAuthorized event → Step 3
   - Failure: Compensate: ReleaseStock → Emit CheckoutFailed; end
   
3. PlaceOrder command → Ordering context
   - Success: Emit CheckoutCompleted event; end
   - Failure: Compensate: RefundPayment, ReleaseStock → Emit CheckoutFailed; end

Timeout: 30 seconds per step

```

## Artifacts Generated

### *model.json* with full strategic + tactical model
### *context-map.cml* with 6 bounded contexts and 5 relationships
### *catalog-context.cml, ordering-context.cml* 
### OpenAPI specs for Catalog, Shopping, Ordering, Inventory REST APIs
### AsyncAPI spec for domain events
### checkout-saga.md workflow diagram
### Validation checklist (all checks passed)

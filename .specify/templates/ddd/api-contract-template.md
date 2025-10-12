# ============================================================
# FILE: api-contract-template.md
# ============================================================
---
title: "API Contract: [Context Name] API"
context: "[Bounded Context Name]"
style: "REST | gRPC | GraphQL | Event-Driven"
version: "1.0.0"
status: "draft | review | approved"
---

# API Contract: [Context Name] API

## Overview

[High-level description of what this API provides]

## API Style

**Type**: REST | gRPC | GraphQL | Event-Driven (AsyncAPI)

**Base URL**: `https://api.example.com/[context]`

**Protocol**: HTTP/1.1 | HTTP/2 | HTTPS

## Authentication

**Method**: API Key | OAuth 2.0 | JWT | mTLS | None

**Header**: `Authorization: Bearer <token>`

**Scopes** (if OAuth):
- `[scope1]`: [Description]
- `[scope2]`: [Description]

## Versioning

**Strategy**: URL versioning | Header versioning | Content negotiation

**Current Version**: v1

**URL Pattern**: `/v1/[resource]`

**Deprecation Policy**: [How old versions are sunset]

## Endpoints

### [Endpoint 1 Name]

**Operation**: [Create | Read | Update | Delete | Action]

**HTTP Method**: `POST | GET | PUT | PATCH | DELETE`

**Path**: `/v1/[resource]`

**Intent**: [What business operation this enables]

**Request**:
```http
POST /v1/orders HTTP/1.1
Content-Type: application/json
Authorization: Bearer 

{
  "customerId": "string",
  "lineItems": [
    {
      "productId": "string",
      "quantity": 1
    }
  ]
}
```

**Response (Success)**:
```http
HTTP/1.1 201 Created
Location: /v1/orders/550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "orderId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "PENDING",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

**Response (Failure)**:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Line items cannot be empty",
    "field": "lineItems"
  }
}
```

**Status Codes**:
- `200 OK`: Success (for GET, PUT, PATCH)
- `201 Created`: Resource created (for POST)
- `204 No Content`: Success with no body (for DELETE)
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource doesn't exist
- `409 Conflict`: State conflict (e.g., duplicate)
- `422 Unprocessable Entity`: Semantic error
- `500 Internal Server Error`: Server failure

**Idempotency**: [Key: idempotency-key header | command ID in payload]

[Repeat for all endpoints]

## Resources

### [Resource Name 1]
```json
{
  "id": "uuid",
  "field1": "string",
  "field2": 42,
  "createdAt": "ISO 8601",
  "updatedAt": "ISO 8601"
}
```

**Fields**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Unique identifier |
| field1 | string | Yes | [Purpose] |

[Repeat for all resources]

## Error Handling

### Standard Error Response
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "field": "fieldName",
    "details": {}
  }
}
```

### Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| INVALID_REQUEST | 400 | Malformed request |
| UNAUTHORIZED | 401 | Authentication missing/invalid |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |

## Rate Limiting

**Strategy**: Token bucket | Fixed window | Sliding window

**Limits**: 
- Per User: 1000 requests/hour
- Per IP: 100 requests/minute

**Headers**:
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642262400
```

**Exceeded Response**:
```http
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
```

## Pagination

**Strategy**: Offset-based | Cursor-based

**Query Parameters**:
- `limit`: Number of items (default: 20, max: 100)
- `offset` or `cursor`: Position

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "total": 1000,
    "limit": 20,
    "offset": 0,
    "next": "/v1/resource?offset=20"
  }
}
```

## Filtering & Sorting

**Filtering**: `/v1/orders?status=PENDING&customerId=123`

**Sorting**: `/v1/orders?sort=createdAt:desc`

## Webhooks (if applicable)

**Event Subscription**: [How clients subscribe to events]

**Webhook URL**: [Client provides]

**Payload**:
```json
{
  "eventId": "uuid",
  "eventType": "order.placed",
  "data": {...},
  "timestamp": "ISO 8601"
}
```

**Retry Policy**: [Exponential backoff, max attempts]

## OpenAPI Specification

See: [Link to openapi.json or openapi.yaml]

## Client Libraries

**Official SDKs**:
- JavaScript/TypeScript: [Link]
- Python: [Link]
- Java: [Link]

## SLA

**Availability**: 99.9% uptime

**Response Time**:
- p50: < 100ms
- p95: < 300ms
- p99: < 1000ms

**Support**: [Support contact or ticketing system]

## Changelog

### v1.0.0 (2025-01-15)
- Initial release
- Endpoints: [List]

## Testing

**Sandbox Environment**: `https://sandbox.api.example.com`

**Test Credentials**: [How to obtain]

**Postman Collection**: [Link]

## References

- [Link to bounded context]
- [Link to commands]
- [Link to aggregates]

---

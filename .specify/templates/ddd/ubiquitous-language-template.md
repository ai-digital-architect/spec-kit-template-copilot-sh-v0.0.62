# ============================================================
# FILE: ubiquitous-language-template.md
# ============================================================
---
title: "Ubiquitous Language: [Bounded Context Name]"
context: "[Bounded Context Name]"
version: "1.0.0"
status: "living document"
---

# Ubiquitous Language: [Bounded Context Name]

## Purpose

This document defines the shared vocabulary for the [Context Name] bounded context. All team members (developers, domain experts, product owners) must use these terms consistently in code, conversations, and documentation.

## Core Concepts

### [Concept 1]
**Definition**: [Clear, domain-expert-approved definition]

**Aliases**: [Alternative names, if any]

**Usage**: [How this term is used in conversations and code]

**Examples**:
- "The [Concept 1] contains..."
- "When a [Concept 1] is created..."

**Code Representation**: [Class name, aggregate name, entity name]

**Related Terms**: [[Concept 2], [Concept 3]]

---

### [Concept 2]
**Definition**: [Clear definition]

**NOT to be confused with**: [Similar concept in different context]

**Usage**: [How this term is used]

**Examples**: [Real usage examples]

**Code Representation**: [Class name]

---

[Repeat for all core concepts]

## Verbs & Actions

### [Action 1]
**Definition**: [What this action means in the domain]

**Who Performs**: [Actor or system]

**Triggers**: [What causes this action]

**Outcome**: [What happens as a result]

**Code**: [Command or method name]

**Example**: "Customer [Action 1]s an order..."

---

[Repeat for all actions]

## States & Lifecycle

### [Entity] Lifecycle
```
[State 1] → [State 2] → [State 3]
```

**State Definitions**:
- **[State 1]**: [What this state means]
- **[State 2]**: [What this state means]
- **[State 3]**: [What this state means]

**Transitions**:
- [State 1] → [State 2]: [When/why this happens]
- [State 2] → [State 3]: [When/why this happens]

---

## Business Rules

### Rule: [Rule Name]
**Statement**: [Natural language business rule]

**Example**: "An order cannot be shipped if payment has not been authorized"

**Invariant**: [Formal statement]

**Enforced By**: [Aggregate, policy, or domain service]

---

[Repeat for key business rules]

## Value Objects

### [Value Object Name]
**Definition**: [What this represents]

**Attributes**: [Fields]

**Immutable**: Yes

**Examples**: 
- Money(100, "USD")
- Address("123 Main St", "Springfield", "IL", "62701")

---

## Domain Events

### [EventName]
**Definition**: [What happened - past tense]

**Triggered By**: [Command or action]

**Significance**: [Why this event matters]

**Usage**: "When [EventName] occurs, then..."

---

[Repeat for key events]

## Context-Specific Meanings

Sometimes terms have different meanings in different contexts. Clarify here:

| Term | In This Context | In [Other Context] |
|------|-----------------|---------------------|
| [Term1] | [Meaning A] | [Meaning B] |

## Glossary

| Term | Type | Definition | Code |
|------|------|------------|------|
| [Term 1] | Entity | [Definition] | [ClassName] |
| [Term 2] | Value Object | [Definition] | [ClassName] |
| [Term 3] | Aggregate | [Definition] | [ClassName] |
| [Term 4] | Command | [Definition] | [CommandName] |
| [Term 5] | Event | [Definition] | [EventName] |

## Forbidden Terms

Terms we intentionally avoid because they're ambiguous or from a different context:

- ❌ **[Term X]**: Use [Term Y] instead
- ❌ **[Term Z]**: This is from [Other Context]; not used here

## Evolution

**Last Updated**: 2025-01-15

**Recent Changes**:
- [Date]: Added [Term]
- [Date]: Clarified [Term]

**Open Discussions**:
- [Question about term or concept]

## References

- [Link to domain expert contact]
- [Link to bounded context documentation]
- [Link to code repository]

---

# Project Context for Claude Code

## Project Overview
[Brief description of the project, its purpose, and main functionality]

## Technology Stack
- **Framework**: Next.js 14
- **Language**: TypeScript 5.x
- **Database**: PostgreSQL with Prisma ORM
- **Styling**: Tailwind CSS
- **Testing**: Jest + React Testing Library

## Code Organization
```
src/
├── app/          # Next.js app router
├── components/   # React components
├── lib/          # Utilities and helpers
├── hooks/        # Custom React hooks
└── types/        # TypeScript type definitions
```

## Coding Standards
1. Use functional components with hooks
2. Prefer composition over inheritance
3. All functions must have TypeScript types
4. Follow ESLint configuration strictly
5. Write tests for all business logic

## Key Patterns
- Use server components by default
- Client components marked with 'use client'
- API routes in app/api/
- Shared types in types/index.ts

## Common Tasks
- Run dev server: `npm run dev`
- Run tests: `npm test`
- Build: `npm run build`
- Lint: `npm run lint`

## Important Notes
- Always update documentation when changing APIs
- Never commit directly to main branch
- All PRs require code review
- Use conventional commits
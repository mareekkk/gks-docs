# PronterLabs Platform Documentation

This is the central system documentation repository for the PronterLabs Platform. It documents the integrated platform architecture, cross-service contracts, and deployment procedures.

> **Note**: For component-specific documentation, refer to individual pillar repositories.

## Platform Overview

PronterLabs is an AI agent platform that provides governed, evidence-backed AI operations with memory persistence and trust-aware execution.

## Architecture

- [Platform Architecture Overview](architecture_overview.md)
- [Unified Memory Architecture](architecture/unified-memory-architecture.md)
- [Data Flow](architecture/data-flow.md)
- [Component Overview](architecture/overview.md)
- [Contracts & Interfaces](architecture/contracts.md)

## Pillar Repositories

| Pillar | Purpose | Repository |
|--------|---------|------------|
| **Memlink** | Memory Authority Service | [memlink](../memlink) |
| **Bifrost** | Intent Router & Policy Engine | [bifrost](../bifrost) |
| **Dispatcher** | API Gateway | [dispatcher](../dispatcher) |
| **Einbroch** | Stateless Executor | [einbroch](../einbroch) |
| **Trust Kernel** | Authentication & Authorization Authority | [trust-kernel](../trust-kernel) |
| **Auth-Pront** | Authentication Infrastructure | [auth-pront](../auth-pront) |
| **PronterLabs Chat** | Frontend Chat UI | [pronterlabs-chat](../pronterlabs-chat) |
| **PronterLabs** | Dashboard/Website | [pronterlabs](../pronterlabs) |

## Request Flow

```
User → PronterLabs Chat → Dispatcher → Bifrost → Einbroch
                                ↓
                            Memlink
                                ↓
                          Trust Kernel
```

1. **User** sends message via PronterLabs Chat
2. **Dispatcher** receives OpenAI-compatible request, fetches Trust Token
3. **Bifrost** classifies intent, enforces policies, determines memory access
4. **Memlink** provides evidence (facts, summaries) for context
5. **Einbroch** executes the approved action with LLM
6. Response flows back through Dispatcher to User

## Deployment

- [Production Operations](production/)
- [Deployment Guides](deployment/)
- [Security Guidelines](security/)

## Operations

- [Platform Operations](operations/)

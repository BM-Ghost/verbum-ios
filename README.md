# Verbum iOS

Verbum iOS is a SwiftUI implementation of the Verbum app, aligned with the Android product experience and liturgical visual language. The codebase is structured for maintainability, clear feature boundaries, and production-oriented workflows.

## Product Scope

Verbum iOS includes:

- Home with seasonal theming and daily content surfaces
- Bible exploration and reader flows
- Missal content views and liturgical context
- Prayer library and detail experiences
- Community feed and post composition surfaces
- Verbum AI chat experience
- Profile and account surfaces
- Liturgical calendar and season-aware presentation

## Technical Direction

- Platform: iOS 17+
- Language: Swift 5.10
- UI: SwiftUI
- Concurrency: async/await
- Architecture: feature-oriented modules with shared core services
- State model: ObservableObject plus explicit loading/success/error view states

## Project Organization

- Verbum/App: app-level bootstrapping and shell concerns
- Verbum/Core: shared domain models, networking, persistence, DI, logging, theme, and reusable components
- Verbum/Features: feature-specific screens, view models, repositories, and models
- Verbum/Navigation: route definitions and navigation wiring
- Verbum/Previews: preview composition and preview data

## Quality and Delivery Standards

- Strongly typed API contracts via Codable DTOs and mapping layers
- Structured logging for diagnostics and operational visibility
- Reusable design tokens for spacing, typography, and seasonal color systems
- Build-safe asset catalog and Info.plist metadata suitable for simulator/device installation
- Predictable state transitions for reliable UX and easier testing

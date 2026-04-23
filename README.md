# verbum-ios

An iOS app for Catholic faith formation - Scripture, liturgy, prayer, community, and AI-assisted spiritual reflection.

Built with a local-first philosophy and designed for clarity, reverence, and performance on Apple platforms.

Started by Bwire and open to creative collaboration.

---

[![PR Validation](https://github.com/BM-Ghost/verbum-ios/actions/workflows/01-pr-validation.yml/badge.svg)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/01-pr-validation.yml)
[![CI - Dev](https://github.com/BM-Ghost/verbum-ios/actions/workflows/02-ci-dev.yml/badge.svg?branch=dev)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/02-ci-dev.yml)
[![Deploy - SIT](https://github.com/BM-Ghost/verbum-ios/actions/workflows/03-deploy-sit.yml/badge.svg?branch=sit)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/03-deploy-sit.yml)
[![Deploy - UAT](https://github.com/BM-Ghost/verbum-ios/actions/workflows/04-deploy-uat.yml/badge.svg?branch=uat)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/04-deploy-uat.yml)
[![Deploy - Production](https://github.com/BM-Ghost/verbum-ios/actions/workflows/05-deploy-production.yml/badge.svg?branch=main)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/05-deploy-production.yml)
[![Security Scan](https://github.com/BM-Ghost/verbum-ios/actions/workflows/06-security-scan.yml/badge.svg)](https://github.com/BM-Ghost/verbum-ios/actions/workflows/06-security-scan.yml)

---

## Core Product Areas

- Bible - multilingual Scripture reading (English + Latin Vulgate), paged, local-first.
- Liturgy - daily Missal readings and liturgical calendar, fully available offline.
- Prayer - curated prayer content accessible without network dependency.
- Community + AI Verbum - social features and AI-assisted reflection built on a modular foundation.

## Stack

- Swift + SwiftUI
- SwiftData (or Core Data fallback where needed)
- Combine / Async-Await (structured concurrency)
- URLSession for networking
- Codable for serialization
- Modular architecture using Swift Packages (SPM)

## Project Layout

- App/ -> App entry point, navigation, dependency wiring
- Core/ -> Shared infrastructure (UI, networking, persistence, utilities)
- Features/ -> Self-contained feature modules (Bible, Liturgy, Prayer, AI, etc.)
- Resources/ -> Assets (Bible, Missal, Prayers)

## Bible Implementation

### What Is Included

- English Bible source (pg1581) bundled in app resources.
- Latin Vulgate source (vulsearch_vulgate) bundled locally.
- Canonical mappings and metadata for all supported books.
- Locale-aware language resolution with user override.

### Data Flow

1. On first launch, Bible content is seeded into local storage (SwiftData/Core Data).
2. Language selection resolves in this order:
	- Explicit user selection
	- Compatible device locale
	- English fallback
	- Latin fallback (if English unavailable)
3. Scripture access is repository-driven, paginated, and cached.

### Performance / Architecture Notes

- Batch inserts used during initial seeding.
- Indexed storage for fast verse lookup.
- Lazy loading for chapters/verses.
- In-memory caching to reduce repeated disk access.

## Liturgy (Missal + Calendar) Implementation

### What Is Included

- Missal readings and liturgical calendar assets under Resources/Missal/.
- Multi-year static JSON datasets.
- Calendar logic implemented in feature domain layer.

### Data Strategy

Local-first with layered fallback:

1. Return cached local data when available.
2. Fall back to bundled assets when cache is missing.
3. Optionally refresh from network sources.
4. Persist refreshed data locally.

Ensures full offline usability with optional freshness when online.

## Assets and Seeding

- Bible: Verbum/Resources/Bible/
- Missal: Verbum/Resources/Missal/
- Prayers: Verbum/Resources/prayers.json

Seeding is orchestrated during app launch using a bootstrap coordinator to ensure early data availability.

## Build and Verification

### Build (Xcode)

1. Open Verbum.xcodeproj or Verbum.xcworkspace.
2. Select Verbum scheme.
3. Run (Cmd+R).

### CLI Build

xcodebuild -project Verbum.xcodeproj -scheme Verbum -configuration Debug -destination 'platform=iOS Simulator,OS=latest,name=iPhone 15' build CODE_SIGNING_ALLOWED=NO

### Tests

xcodebuild -project Verbum.xcodeproj -scheme Verbum -configuration Debug -destination 'platform=iOS Simulator,OS=latest,name=iPhone 15' test CODE_SIGNING_ALLOWED=NO

### Guideline Verification

bash Scripts/Verification/verify_verbum_guidelines.sh

## Contributing

### Your Role as a Contributor

Contributors work on feature branches and open PRs to dev. Promotion across environments and App Store distribution is handled by the maintainer.

Same philosophy applies: you focus on clean, complete work - deployment is centralized.

### Branch Naming - Required

All PRs to dev must originate from:

| Prefix | Example |
|---|---|
| feature-<description> | feature-bible-search |
| ft-<description> | ft-prayer-detail |

Non-compliant branches are rejected by CI.

### Before Opening a PR

Ensure:

- Project builds successfully in Xcode.
- No warnings or errors.
- Previews render correctly.
- Tests pass.

## Engineering Guidelines (iOS)

This is the contributor contract for verbum-ios.

### Architecture and Module Boundaries

- App: App lifecycle, navigation, dependency injection only.
- Core: Shared utilities (UI system, networking, persistence, helpers).
- Features/*: Feature-isolated modules (UI, ViewModel, domain, data).

Allowed dependency direction:

1. App -> Features, Core
2. Features -> Core
3. Core -> no Features

Forbidden:

- Feature -> Feature dependencies
- View layer -> direct persistence access
- View layer -> direct networking calls

### Do's (Technical)

1. Use FeatureView + FeatureContent pattern:
	- FeatureView: state + orchestration
	- FeatureContent: pure UI
2. Keep state in ObservableObject or @StateObject ViewModels.
3. Use @MainActor and structured concurrency correctly.
4. Route data through UseCase -> Repository layers.
5. Use strong typing (struct, enum, Result, etc.).
6. Centralize design via a theme system (colors, typography, spacing).
7. Provide SwiftUI previews for every screen.
8. Keep ViewModels focused and small.
9. Isolate AI logic inside Features/AI.
10. Validate inputs in UseCases before repository calls.
11. Write unit tests for domain and data layers.
12. Use dependency injection (protocol-based, constructor injection).

### Don'ts (Technical)

1. Do not access persistence directly from Views or ViewModels.
2. Do not use force unwraps (!).
3. Do not hardcode colors or fonts inside Views.
4. Do not place business logic inside SwiftUI views.
5. Do not create feature-to-feature dependencies.
6. Do not introduce UIKit unless absolutely necessary.
7. Do not create massive ViewModels handling multiple domains.
8. Do not use global mutable state.
9. Do not skip previews for UI work.
10. Do not bypass repository/use-case layers.
11. Do not mix async patterns inconsistently (Combine + async/await without reason).

### Naming Conventions

| Component | Convention |
|---|---|
| Screen | FeatureView.swift |
| UI Content | FeatureContent.swift |
| ViewModel | FeatureViewModel.swift |
| Use Case | ActionThingUseCase.swift |
| Repository | ThingRepository.swift / ThingRepositoryImpl.swift |
| UI State | FeatureUiState |

### SwiftUI Guidelines

- Prefer composition over inheritance.
- Keep Views declarative and side-effect free.
- Use @State, @StateObject, @ObservedObject correctly.
- Avoid deeply nested view hierarchies.
- Extract reusable components into Core/UI.

### Local Verification Before PR

- Build succeeds (Cmd+B)
- App runs (Cmd+R)
- Previews render
- Tests pass

## Philosophy

verbum-ios is built like a liturgy:

- Structured
- Intentional
- Minimal where necessary
- Rich where meaningful

Every line of code should serve clarity, not complexity.

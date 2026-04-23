# Verbum iOS Engineering Guidelines

This document is the contributor contract for verbum-ios.

## Architecture and Module Boundaries

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

## Do's (Technical)

1. Use FeatureView + FeatureContent pattern.
2. Keep state in ObservableObject or @StateObject ViewModels.
3. Use @MainActor and structured concurrency correctly.
4. Route data through UseCase -> Repository layers.
5. Use strong typing (struct, enum, Result, etc.).
6. Centralize design via theme (colors, typography, spacing).
7. Provide SwiftUI previews for every screen.
8. Keep ViewModels focused and small.
9. Isolate AI logic inside feature AI boundary.
10. Validate inputs in UseCases before repository calls.
11. Write unit tests for domain and data layers.
12. Use dependency injection (protocol-based, constructor injection).

## Don'ts (Technical)

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
11. Do not mix async patterns inconsistently.

## Naming Conventions

| Component | Convention |
|---|---|
| Screen | FeatureView.swift |
| UI Content | FeatureContent.swift |
| ViewModel | FeatureViewModel.swift |
| Use Case | ActionThingUseCase.swift |
| Repository | ThingRepository.swift / ThingRepositoryImpl.swift |
| UI State | FeatureUiState |

## SwiftUI Guidelines

- Prefer composition over inheritance.
- Keep Views declarative and side-effect free.
- Use @State, @StateObject, @ObservedObject correctly.
- Avoid deeply nested view hierarchies.
- Extract reusable components into Core.

## Local Verification Before PR

Run these from the repository root:

1. bash Scripts/Verification/verify_verbum_guidelines.sh
2. xcodebuild -project Verbum.xcodeproj -scheme Verbum -configuration Debug -destination 'platform=iOS Simulator,OS=latest,name=iPhone 15' build CODE_SIGNING_ALLOWED=NO
3. xcodebuild -project Verbum.xcodeproj -scheme Verbum -configuration Debug -destination 'platform=iOS Simulator,OS=latest,name=iPhone 15' test CODE_SIGNING_ALLOWED=NO

## Philosophy

verbum-ios is built like a liturgy:

- Structured
- Intentional
- Minimal where necessary
- Rich where meaningful

Every line of code should serve clarity, not complexity.

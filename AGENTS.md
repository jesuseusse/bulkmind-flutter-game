# BulkMind Agent Briefing

Welcome to BulkMind. This briefing orients new contributors ("agents") around the systems that keep the app focused, stable, and on-brand.

## Clean Architecture Protocol
- **Layered features** live under `lib/features/<domain>/{data,domain,presentation}`. Data sources talk to infrastructure (Firebase, local DB), domain exposes models/use cases, presentation holds widgets and notifiers.
- **Shared foundations** stay in `lib/core` for reusable models, services, theme, and utilities. Nothing in `core` depends on feature layers, keeping boundaries clean.
- **State orchestration** relies on `ChangeNotifier`-based providers (e.g. `lib/features/patterns/providers/patterns_provider.dart`) or Riverpod-style wrappers, so UI reacts only to domain signals.
- **Provider file structure** should follow a consistent order to keep state classes predictable:
  1. Imports grouped by Flutter SDK, third-party packages, then project files.
  2. Private properties for backing state (prefixed with `_`).
  3. Constructor with any initialization logic that primes the state.
  4. Public getters exposing read-only views of the state.
  5. Business logic methods that mutate state and call `notifyListeners()` (or equivalent) with clear side effects.
  6. Dispose method to release controllers, streams, or listeners.

## Firebase Foundation
- Credentials and initialization flow through `lib/firebase_options.dart` and the generated `Firebase.initializeApp` wiring in `lib/main.dart`.
- Authentication scenarios are abstracted behind `lib/features/auth/domain/auth_repository.dart`, with the concrete adapter `lib/features/auth/data/firebase_auth_repository.dart` delegating to `firebase_auth`. Presentation code consumes the repository interface to stay testable and Firebase-agnostic.
- Additional Firebase services (analytics, remote config, etc.) should follow the same pattern: define a domain contract, implement it in `data`, register the adapter in composition root.

## Game Timer System
- Cognitive games standardize time tracking so UX stays predictable:
  - Patterns: `lib/features/patterns/providers/patterns_provider.dart` stores the start timestamp and computes elapsed time on demand when the session ends.
  - Intuition: `lib/features/intuition/presentation/providers/intuition_game_provider.dart` restarts timers whenever a round resets to ensure fresh limits.
  - Logic: `lib/features/logic/presentation/providers/logic_provider.dart` mirrors the same cadence, enabling consistent pacing across games.
- Shared formatting lives in `lib/core/utils/time_utils.dart` so countdowns and scoreboards render uniformly. When introducing a new game, reuse the existing timing utilities instead of ad-hoc counters.

## Theme Consistency
- The single source of truth for colors and typography is `lib/core/theme/app_theme.dart`, backed by palettes in `lib/core/theme/color_palette.dart`.
- Feature widgets should derive styles from `Theme.of(context)` or custom theme extensions, never hard-coded values. When a new visual token is required, add it to the palette/theme before referencing it.
- Assets (icons, illustrations) follow the typography/color rules; ensure any additions harmonize with the base theme to keep the cognitive-training brand coherent.

## SOLID Commitments
- **Single Responsibility:** Providers handle UI-facing state; use cases (e.g. `lib/features/auth/domain/signup_usecase.dart`) encapsulate domain decisions; repositories isolate data access.
- **Open/Closed:** Domain contracts (repositories/use cases) accept new implementations without touching existing clients. Extend by adding new adapters or strategies rather than editing the abstractions.
- **Liskov Substitution:** Keep repository interfaces minimal and behaviorally consistent so test doubles and Firebase adapters can be swapped freely.
- **Interface Segregation:** Prefer narrow interfaces (e.g. split authentication flows into dedicated use cases) over god-objects that know too much.
- **Dependency Inversion:** High-level widgets depend on abstractions exposed by the domain layer, while concrete Firebase/database classes sit at the edge and are injected from the composition root.

## Agent Playbook
1. Start from the domain contract when adding a feature. Define the data model and use cases first.
2. Implement adapters in the `data` layer (Firebase, local storage, etc.) and cover them with integration tests where possible.
3. Compose presentation logic via providers and widgets that consume domain abstractions while leaning on the shared theme.
4. Reuse the existing timer utilities for new games to keep UX expectations aligned.
5. Document each public function, widget, and class following *Effective Dart: Documentation* so the API surface stays clear for future agents.
6. Before shipping, double-check theme coherence and run the relevant timers-driven flows end-to-end.

Stay aligned with these guardrails and BulkMind will remain scalable, testable, and consistent.

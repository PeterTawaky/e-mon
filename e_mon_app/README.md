# WattWise App

Flutter client for the WattWise power monitoring system.

## Architecture

Use MVVM grouped by feature:

```text
lib/features/<feature_name>/
  data/
    models/
    repositories/
      <feature_name>_repo.dart
      <feature_name>_repo_impl.dart
  presentation/
    managers/
    views/
      widgets/
        <feature_name>_view_body.dart
      <feature_name>_view.dart
```

Feature rules:

- `data/models` contains DTOs, entities, and JSON mapping.
- `data/repositories` contains repository contracts and implementations.
- `presentation/managers` contains Cubits, ViewModels, and other state managers.
- `presentation/views` contains screen widgets.
- `presentation/views/widgets` contains feature-specific child widgets.
- Shared services, routing, dependency injection, design system, themes, and utilities stay in `lib/core`.

## State Management

- Use `ValueNotifier` and `ValueListenableBuilder` for simple local UI state, such as navigation selection, hover state, color changes, expansion, and small toggles.
- Use Cubit for complex or business-critical flows, such as API calls, loading/success/failure states, validation, pagination, mutations, and state shared across multiple widgets.

Do not use Cubit for trivial UI interactions, and do not use `ValueNotifier` for API orchestration or complex business logic.

## Running

```bash
flutter pub get
flutter run
```

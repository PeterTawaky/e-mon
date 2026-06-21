# e-mon Project Guidance

## Flutter Architecture

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

- Keep feature-specific API mapping and persistence logic in `data`.
- Put DTOs and JSON parsing in `data/models`.
- Put repository contracts and implementations in `data/repositories`.
- Put ViewModels, Cubits, and other state managers in `presentation/managers`.
- Put screens in `presentation/views`.
- Put feature-specific child widgets in `presentation/views/widgets`.
- Keep shared networking, routing, dependency injection, design system, themes, and utilities in `lib/core`.

## State Management

- Use `ValueNotifier` / `ValueListenableBuilder` for simple local UI state: navigation selection, hover state, color changes, expanded/collapsed state, and small toggles.
- Use Cubit for multi-state or business-heavy flows: API calls, loading/success/failure, validation, mutations, pagination, derived business state, and cross-widget coordination.

Do not use Cubit for trivial UI state. Do not use `ValueNotifier` for API orchestration or complex business workflows.

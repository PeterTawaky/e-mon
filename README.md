# e-mon

Energy monitoring system with a Flutter client and FastAPI backend.

## Project Structure

- `e_mon_app/` - Flutter app
- `backend/` - FastAPI server
- `e-mon_db_script.sql` - SQL Server schema
- `e-mon.postman_collection.json` - Postman collection
- `CLAUDE.md` - project architecture and coding rules for AI-assisted work

## Flutter Architecture

The Flutter app uses MVVM grouped by feature:

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

Use `ValueNotifier` for simple local UI state such as navigation selection, hover state, color changes, and small toggles. Use Cubit for complex flows with many states, API logic, loading/success/failure handling, validation, and business logic.

## Backend

Run the API from `backend/`:

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

Set `DB_CONNECTION_STRING` when the default local SQL Server trusted connection is not suitable.

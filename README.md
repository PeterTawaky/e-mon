# WattWise

WattWise is an energy monitoring and SCADA-style dashboard with a Flutter desktop client and backend APIs for users, authentication, readings, and reports.

## Project Structure

- `e_mon_app/` - Flutter client.
- `backend/` - FastAPI backend used by the Flutter app for auth, users, readings, and reports data.
- `server/` - Node/Express SQL Server API prototype for user management.
- `db/` - Database assets.
- `e-mon_db_script.sql` - SQL Server schema script.
- `e-mon.postman_collection.json` - Root Postman collection.
- `backend/WattWise.postman_collection.json` - FastAPI Postman collection.
- `CLAUDE.md` - Project architecture and coding rules for AI-assisted work.

## Flutter App

The Flutter app is in `e_mon_app/` and uses a feature-first MVVM structure.

Current main modules:

- Dashboard: live simulated device readings with chart ranges for day, week, month, six months, and year.
- Devices: Winters BTU meter overview with 16 meter cards in a 4-column desktop grid.
- Reports: specific-period and monthly energy reports with PDF generation.
- Users: create, list, and delete system users.
- Sidebar modules reserved for future work: Live Monitoring, Landlords, Tenants, Billing, Alerts, and Settings.

The Devices module is implemented under `e_mon_app/lib/features/devices/`.

The Devices view displays Winters BTU meter readings using `assets/images/winters_btu_meter.png`. Clicking a meter opens a details dialog with:

- Flow Rate in L/min.
- Supply and Return Temperature with Delta T.
- BTU / Energy Consumption in kW.
- Totalizer / Accumulated Energy in kWh.

## Flutter Architecture

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

State management rules:

- Use `ValueNotifier` and `ValueListenableBuilder` for simple local UI state such as navigation selection, hover state, expansion, color changes, and small toggles.
- Use Cubit for API orchestration, loading/success/failure states, validation, mutations, reports, and shared business logic.

Shared services, routing, networking, design system, themes, and utilities live under `e_mon_app/lib/core`.

## Running The Flutter App

```bash
cd e_mon_app
flutter pub get
flutter run
```

Useful checks:

```bash
cd e_mon_app
dart format lib
flutter analyze
```

## FastAPI Backend

The primary backend lives in `backend/`.

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

Configuration is read from `.env`. Start from `backend/.env.example`:

```text
DB_CONNECTION_STRING=DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=e-mon;Trusted_Connection=yes;
```

Main routes:

- `POST /auth/login`
- `GET /users`
- `POST /users`
- `DELETE /users/{user_id}`
- `GET /readings`
- `GET /readings/range`
- `GET /readings/monthly`
- `POST /readings`
- `DELETE /readings`

The backend includes a simulation service that creates device readings while the API server is running.

## Node Server Prototype

The `server/` folder contains a smaller Express + SQL Server API prototype.

```bash
cd server
npm install
npm start
```

It reads SQL Server settings from `server/.env` and currently exposes user management routes.

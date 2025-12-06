# courses_task

This repo contains a Flutter app implementing the Course Manager challenge.

## What is included

- Full Flutter app source under `lib/`.
- `pubspec.yaml` with required dependencies.
- `db.json` for a local mock API (json-server).

## Setup steps

1. Install Flutter and Android/iOS tooling: https://flutter.dev/docs/get-started/install
2. Clone the repo.
3. Run a mock API server for categories (optional but recommended):
   - Install json-server: `npm i -g json-server`
   - From the project root: `json-server --watch db.json --port 3000`
   - For Android emulator use `http://10.0.2.2:3000/categories`. For iOS simulator use `http://localhost:3000/categories`.
4. Run `flutter pub get`.
5. Run the app: `flutter run`.

## Structure

- `lib/models/` — data models
- `lib/services/` — local DB (sqflite) service
- `lib/repositories/` — data repositories
- `lib/providers/` — state providers
- `lib/screens/` — UI screens

## Notes

- Offline: courses and categories are cached in local sqflite database. Categories are fetched from a mock API and cached. If network call fails, cached categories are used.
- Score: calculated as `title.length * numberOfLessons` when saving a course.
- UI: loading indicators, empty state, search box, category filter, confirmation before delete, smooth navigation.

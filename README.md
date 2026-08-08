# Expense Tracker

A production-quality, offline-first expense and income tracker built with Flutter. Track your daily spending, log income (including per-payer entries like tuition fees), and visualize your financial habits — all stored locally on your device.

## Features

### Expense Tracking
- Add, edit, and delete expenses with title, amount, category, date, and notes
- Swipe-to-delete with confirmation dialog and Undo
- Nine built-in categories (Food, Shopping, Transport, Bills, Education, Medical, Entertainment, Travel, Other)

### Income Ledger
- Log individual income entries (e.g. tuition fees from different students) with payer name, amount, date, and notes
- Running total automatically sums all entries
- Same edit/delete/undo flow as expenses

### Home Dashboard
- Total balance card (income − expenses) with animated count-up
- Live search across titles and notes
- Filter by category and by date range, with a removable active-filters row
- Empty states for "no expenses" and "no search matches"

### Statistics
- Pie chart of spending by category
- Category-wise breakdown with percentages
- Bar chart of spending over the last 6 months

### Settings
- Dark mode (persisted, applies instantly across the app)
- Currency selection (USD, EUR, GBP, PKR, INR, JPY, AUD, CAD)
- About screen

### Engineering
- Clean Architecture: UI → Riverpod providers → services → Hive
- Offline-first local storage via Hive — no account or internet required
- Smooth custom page transitions, staggered list animations
- Lazy-loaded (`SliverList`) expense list for smooth scrolling with large datasets
- Debounced search input
- Error handling throughout the data layer with user-facing messages
- Unit tests (services, formatters) and a widget smoke test

## Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter (Dart, null-safety) |
| State Management | Riverpod |
| Local Database | Hive |
| Navigation | go_router |
| Charts | fl_chart |
| Formatting | intl |
| IDs | uuid |
| Design | Material 3 |

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App-wide constants, categories, routes
│   ├── theme/         # Material 3 light/dark theme
│   └── utils/         # Formatters, router config
├── models/            # Hive data models (Expense, IncomeEntry)
├── services/          # Hive CRUD wrappers (data layer)
├── providers/         # Riverpod state management
├── screens/
│   ├── splash/
│   ├── home/
│   ├── add_expense/
│   ├── expense_detail/
│   ├── income/
│   ├── statistics/
│   └── settings/
├── widgets/            # Reusable UI components
└── main.dart
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- An emulator/simulator or physical device

### Installation

```bash
git clone https://github.com/syedarakhshan/expense_tracker_flutter.git
cd expense_tracker_flutter
flutter pub get
```

### Generate Hive Adapters

This project uses code generation for Hive type adapters. Run this after cloning and after any model change:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

### Test

```bash
flutter test
```

### Analyze

```bash
flutter analyze
```

## License

This project is available for personal and educational use.

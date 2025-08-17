# Contributing

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A device or emulator for running Flutter apps

### Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/linear_timekeeper.git
   cd linear_timekeeper 
   ```

2. Get dependencies:
   ```sh
   flutter pub get
   ```

3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure

- `lib/`
  - `main.dart` - App entry point
  - `model/` - Timer data, controller, and storage logic
  - `routes/` - App screens (home, settings, timer management)
  - `theme/` - Theme and color customization
  - `types/` - Custom data types (e.g., CustomTimer)
  - `utils/` - Utility functions
  - `widgets/` - Reusable UI components

- `test/` - Unit and widget tests

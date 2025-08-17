# linear timekeeper 

A customizable linear timekeeper built with Flutter.

Created based on the [reddit post by khajiitilito](https://www.reddit.com/r/adhdwomen/comments/1j4871j/visual_progress_barlinear_timer_for_free_in/)

The app has been primarily developed for web and linux

## Features

- Create, edit, and delete custom timers with unique titles and durations
- Set maximum duration and interval presets for each timer
- Visual dotted progress bar for active timers
- Color customization for timer appearance
- Persistent storage of your timers and settings
- Responsive UI for mobile devices

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A device or emulator for running Flutter apps

### Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/TimeStick.git
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

## Attribution

Alarm clock ringtone "marimba rising morning" by jerry.berumen  
[https://freesound.org/s/762108/](https://freesound.org/s/762108/)  
License: Attribution 4.0

## Known issues

- The timer setting screen flickers alot and has problems

## TODO

[_] Sort out license?

[_] GitHub actions - deployement

[_] Adapt for mobile devices

[_] Increase test coverate

[WIP] Restructure codebase for more consistency and testability


# card4k

![Flutter](https://img.shields.io/badge/Flutter-3.47.0-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android)

A clean, minimalist flashcard application built with Flutter. Master your learning with interactive pairing and selection modes, persistent local storage, and a beautiful, modern UI.

## Features

- **Interactive Learning Modes**: Practice with "Selection" (multiple choice) and "Pairing" (matching) game modes for effective memorization.
- **Local Database Storage**: Robust offline support using sqflite with pre-defined SQL schema scripts for managing groups and cards.
- **Real-time Progress Tracking**: Visual progress bars and detailed results pages showing correct pairs, mistakes, and performance metrics.
- **Group Management**: Create, edit, and delete custom flashcard groups with personalized color coding via flutter_colorpicker.
- **Persistent Settings**: Automatically saves your last used group and application preferences using shared_preferences.
- **Rich UI Components**: Custom SVG icons, smooth animations, and a modern dark-themed interface following Material Design principles.
- **Responsive Design**: Adapts beautifully to various screen sizes and orientations across mobile devices.

## Screenshots

No Groups
<p align="center">
	<img src="screenshots/001-no-groups.png" width="250" alt="Page without groups" />
	<img src="screenshots/002-no-groups-add.png" width="250" alt="Burger with adding initial group" />
</p>

Home
<p align="center">
	<img src="screenshots/home/001-home.png" width="250" alt="Main page" />
	<img src="screenshots/home/002-home-add-card.png" width="250" alt="Add new card at home page" />
	<img src="screenshots/home/003-home-edit-group.png" width="250" alt="Edit current group at home page" />
	<img src="screenshots/home/004-home-groups.png" width="250" alt="Groups at home page" />
	<img src="screenshots/home/005-home-add-group.png" width="250" alt="Add new group at home page" />
</p>

Cards
<p align="center">
	<img src="screenshots/cards/001-cards.png" width="250" alt="Cards page" />
	<img src="screenshots/cards/002-cards-hide.png" width="250" alt="Hide card's description at cards page" />
	<img src="screenshots/cards/003-cards-edit.png" width="250" alt="Edit card content at cards page" />
    <img src="screenshots/cards/004-no-cards.png" width="250" alt="No cards at cards page" />
</p>

Pairing
<p align="center">
	<img src="screenshots/pairing/001-pairing.png" width="250" alt="Pairing page" />
	<img src="screenshots/pairing/002-pairing-selection-correct.png" width="250" alt="Selection correct at pairing page" />
	<img src="screenshots/pairing/003-pairing-selection-incorrect.png" width="250" alt="Selection incorrect at pairing page" />
    <img src="screenshots/pairing/004-pairing-no-cards.png" width="250" alt="No cards at pairing page" />
</p>

Selection
<p align="center">
	<img src="screenshots/selection/001-selection.png" width="250" alt="Selection page" />
	<img src="screenshots/selection/002-selection-correct.png" width="250" alt="Selection correct at selection page" />
    <img src="screenshots/selection/003-selection-incorrect.png" width="250" alt="Selection incorrect at selection page" />
    <img src="screenshots/selection/004-selection-no-cards.png" width="250" alt="No cards at selection page" />
</p>

Results
<p align="center">
	<img src="screenshots/results/001-results-all-correct.png" width="250" alt="All correct results at results page" />
	<img src="screenshots/results/002-results-partly.png" width="250" alt="Partly correct results at results page" />
	<img src="screenshots/results/003-results-wrong.png" width="250" alt="All incorrect results at results page" />
</p>

## Tech Stack

- **Framework**: Flutter 3.47.0
- **State Management**: Riverpod (`flutter_riverpod` ^3.4.2)
- **UI**: Material Design, Custom SVGs (`flutter_svg`), Color Picker (`flutter_colorpicker`)
- **Architecture**: Clean, modular structure with dedicated Notifiers, Repositories, and UI components.
- **Database**: `sqflite` with raw SQL asset scripts for schema and queries
- **Charting**: `fl_chart` (for performance visualization)
- **Storage**: `shared_preferences`, `path`

## Getting Started

### Prerequisites

- Flutter SDK (3.47.0 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository**

```bash
    git clone https://github.com/your-username/card4k.git
    cd card4k
```

2. **Install dependencies**

```bash
    flutter pub get
```

3. **Run the app**

```bash
    flutter run
```

## Building for Release

### Android APK

```bash
    flutter build apk --release
```

### Android App Bundle (for Play Store)

```bash
    flutter build appbundle --release
```

## Project Structure

```text
    lib/
    ├── main.dart             # App entry point and ProviderScope initialization
    ├── models/               # Data models (Card, Group)
    ├── pages/                # UI screens (SelectionPage, PairingPage, ResultsPage, etc.)
    ├── providers/            # State management (GroupsNotifier, etc.)
    ├── data/                 # Repositories (sqlite_group_repository, etc.)
    ├── widgets/              # Reusable UI components
    ├── utils/                # Utility functions and constants
    └──assets/
    ├── icon/                 # SVG icons (settings, card, pairing, selection, etc.)
    └── sql/  
```

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Flutter and Dart
- State management powered by Riverpod
- Database persistence powered by sqflite
- Charting powered by fl_chart
- Inspired by clean, minimalist design principles
- Powered by 4aika_M
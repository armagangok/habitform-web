# HabitForm

<div align="center">

![Version](https://img.shields.io/badge/version-3.0.3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.6.0+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-Private-red.svg)

**A powerful and intuitive habit tracking application built with Flutter**

Transform your daily routines into lasting habits with beautiful visualizations, intelligent insights, and seamless cross-platform experience.

[Features](#-features) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Project Structure](#-project-structure)

</div>

---

## 📱 Overview

HabitForm is a comprehensive habit tracking application designed to help users build and maintain positive habits through data-driven insights, beautiful visualizations, and an engaging user experience. The app combines behavioral psychology principles with modern mobile design to create an effective tool for personal development.

## ✨ Features

### Core Functionality
- **Habit Management**: Create, edit, and organize habits with custom emojis, colors, and categories
- **Streak Tracking**: Visual streak counters with flame icons to maintain motivation
- **Completion Tracking**: Track daily completions with flexible daily targets
- **Smart Reminders**: Multiple reminder modes with time and location-based notifications
- **Habit Probability**: AI-powered habit formation probability calculations based on completion history
- **Difficulty Levels**: Set habit difficulty (easy, moderate, hard) to track progress appropriately

### Visualizations & Analytics
- **Heatmap Calendar**: Beautiful GitHub-style heatmap showing completion patterns over time
- **Habit Constellation**: Interactive visual representation of habit relationships
- **Progress Charts**: Detailed statistics and progress tracking with fl_chart
- **Insights & Milestones**: Personalized insights and milestone celebrations
- **Calendar View**: Month and week views for habit completion tracking

### Data Management
- **CSV Export/Import**: Export and import habit data for backup and migration
- **Data Sharing**: Share habit progress with customizable templates and screenshots
- **Local Storage**: Fast, reliable local data storage using Hive
- **Offline Support**: Full functionality without internet connection

### Platform Features
- **iOS Widgets**: Home screen widgets for quick habit completion without opening the app
- **Multi-language Support**: Available in 9 languages (English, Spanish, French, Italian, Chinese, Arabic, Turkish, Finnish, Japanese)
- **Dark Mode**: Beautiful dark and light themes with system preference detection
- **In-App Purchases**: Premium features via RevenueCat integration

### User Experience
- **Onboarding Flow**: Guided onboarding experience for new users
- **Modern UI/UX**: Clean, intuitive interface following Material Design principles
- **Animations**: Smooth Lottie animations for celebrations and transitions
- **Responsive Design**: Optimized for various screen sizes and orientations
- **Accessibility**: Support for accessibility features and screen readers

## 🏗️ Architecture

HabitForm follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
Models → Services → Providers → Views
```

### Architecture Layers

1. **Models**: Data models using Hive for local persistence
2. **Services**: Business logic and data operations (HabitService, ReminderService, etc.)
3. **Providers**: State management using Riverpod (ViewModels)
4. **Views**: UI components and pages

### State Management
- **Riverpod**: Reactive state management for Flutter
- **Provider Pattern**: Clean separation of concerns
- **State Classes**: Immutable state objects for predictable updates

## 🛠️ Tech Stack

### Core Framework
- **Flutter** 3.6.0+
- **Dart** SDK

### Key Dependencies
- **flutter_riverpod**: State management
- **hive_flutter**: Local database
- **easy_localization**: Internationalization
- **flutter_local_notifications**: Push notifications
- **purchases_flutter**: In-app purchases (RevenueCat)
- **fl_chart**: Data visualization
- **lottie**: Animations
- **table_calendar**: Calendar widgets
- **csv**: Data export/import
- **share_plus**: Social sharing
- **screenshot**: Image capture

### Development Tools
- **build_runner**: Code generation
- **hive_generator**: Model code generation
- **flutter_gen**: Asset code generation
- **flutter_lints**: Code quality

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and shared code
│   ├── constants/          # App constants
│   ├── helpers/            # Helper functions
│   ├── theme/              # Theme configuration
│   └── widgets/            # Reusable widgets
├── features/               # Feature modules
│   ├── create_habit/       # Habit creation flow
│   ├── habit_detail/       # Habit detail page
│   ├── habit_probability/  # Probability calculations
│   ├── home/               # Home screen
│   ├── settings/           # Settings page
│   ├── export_import_data/ # Data management
│   ├── share_habit/        # Sharing functionality
│   ├── purchase/           # In-app purchases
│   └── onboarding/         # Onboarding flow
├── models/                 # Data models
├── services/               # Business logic services
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd habitform
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure environment variables**
   - Create a `.env` file in the root directory
   - Add required API keys and configuration

5. **Run the app**
   ```bash
   flutter run
   ```

### iOS Setup

1. Navigate to `ios/` directory
2. Install CocoaPods dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
3. Open `ios/Runner.xcworkspace` in Xcode
4. Configure signing and capabilities

### Android Setup

1. Ensure Android SDK is properly configured
2. Set up signing keys for release builds
3. Configure `android/app/build.gradle` as needed

## 🏃 Running the App

### Development Mode
```bash
flutter run
```

### Release Build
```bash
# Android
flutter build apk --release
# or
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📱 Platform Support

- ✅ **iOS**: 12.0+
- ✅ **Android**: API 21+ (Android 5.0+)

## 🌍 Internationalization

HabitForm supports multiple languages:
- English (en-US)
- Spanish (es-ES)
- French (fr-FR)
- Italian (it-IT)
- Chinese Simplified (zh-Hans)
- Arabic (ar-SA)
- Turkish (tr-TR)
- Finnish (fi-FI)
- Japanese (ja-JP)

## 🔧 Configuration

### App Groups (iOS Widgets)
- **Identifier**: `group.com.habitrise.widgets`
- Required for widget functionality

### RevenueCat
- Configure RevenueCat API keys in `.env`
- Set up products in RevenueCat dashboard

### Notifications
- Configure notification permissions in platform-specific settings
- Timezone handling is automatic

## 📊 Key Features Implementation

### Habit Probability Calculation
Uses behavioral psychology principles to calculate habit formation probability based on:
- Completion frequency
- Streak consistency
- Time since habit creation
- Reward factor (α)

### Widget Sync
- iOS widgets sync via App Groups
- Real-time updates every 30 minutes
- Interactive completion buttons

### Data Export/Import
- CSV format for compatibility
- Includes all habit data and completions
- Preserves relationships and metadata

## 🤝 Contributing

This is a private project. For contributions, please contact the maintainers.

## 📄 License

This project is private and proprietary. All rights reserved.

## 📝 Version History

- **v3.0.3**: Performance improvements and optimizations
- **v3.0.2**: User experience improvements
- **v3.0.0**: Major release with new features

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors whose packages made this project possible
- The habit tracking community for inspiration and feedback

---

<div align="center">

**Built with ❤️ using Flutter**

For questions or support, please contact the development team.

</div>

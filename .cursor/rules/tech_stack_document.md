---
description: 
globs: 
alwaysApply: false
---
# Tech Stack Documentation

## Core Technologies

### Frontend
- **Flutter**: Primary framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Cupertino**: UI components

### Backend Services
- **Firebase**: Authentication, Analytics
- **RevenueCat**: Subscription management
- **Local Storage**: Hive

## Development Tools

### IDE & Tools
- **Cursor**: Primary IDE
- **Flutter SDK**: Development framework
- **Dart SDK**: Language tools
- **Git**: Version control

### Testing Tools
- **Flutter Test**: Unit testing
- **Integration Test**: End-to-end testing
- **Mockito**: Mocking framework

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  cupertino_icons: ^1.0.6
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.4
  flutter_localizations:
    sdk: flutter
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  mockito: ^5.4.4
```

## Architecture Patterns

### State Management
- Riverpod for state management
- Provider pattern for dependency injection
- Stateful/Stateless widget separation

### Design Patterns
- MVVM (Model-View-ViewModel)
- Repository pattern
- Service pattern
- Factory pattern

## Code Organization

### Directory Structure
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── habits/
│   ├── settings/
│   └── notifications/
├── models/
├── providers/
└── services/
```

### Naming Conventions
- Files: snake_case.dart
- Classes: PascalCase
- Variables: camelCase
- Constants: SCREAMING_SNAKE_CASE

## Performance Optimization

### Code Optimization
- Lazy loading
- Memory management
- Widget rebuilding optimization
- State persistence

### Build Optimization
- Tree shaking
- Code splitting
- Asset optimization
- Bundle size reduction

## Security

### Data Security
- Secure storage
- Encryption
- Token management
- API security

### App Security
- Code obfuscation
- Anti-tampering
- Secure communication
- Permission handling 
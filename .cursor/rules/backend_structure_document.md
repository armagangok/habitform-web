---
description: 
globs: 
alwaysApply: false
---
# Backend Structure Documentation

## Overview
This document outlines the backend architecture and structure for the HabitRise application.

## Core Components

### 1. Data Models
- Located in `lib/models/`
- Defines the core data structures
- Includes models for:
  - Habits
  - Completions
  - User preferences
  - Settings

### 2. Providers
- Located in `lib/providers/`
- State management using Riverpod
- Handles:
  - Habit state
  - User preferences
  - Theme management
  - Purchase/subscription state

### 3. Services
- Located in `lib/services/`
- Business logic implementation
- Includes:
  - Habit tracking
  - Data persistence
  - Analytics
  - Push notifications

### 4. Repositories
- Located in `lib/repositories/`
- Data access layer
- Handles:
  - Local storage
  - Remote API calls
  - Data synchronization

## Data Flow

1. **UI Layer**
   - Views and widgets
   - User interactions
   - State updates

2. **Business Logic Layer**
   - Providers
   - Services
   - Business rules

3. **Data Layer**
   - Repositories
   - Models
   - Data persistence

## State Management

### Riverpod Implementation
- Uses `flutter_riverpod` for state management
- Providers are organized by feature
- State updates are handled through providers
- Widgets consume state through `ConsumerWidget` or `ConsumerStatefulWidget`

## Error Handling

### Error Types
1. **UI Errors**
   - Handled through error boundaries
   - User-friendly error messages

2. **Business Logic Errors**
   - Logged and handled appropriately
   - May trigger retry mechanisms

3. **Data Errors**
   - Handled through repositories
   - May trigger data synchronization

## Testing Strategy

### Unit Tests
- Test providers
- Test services
- Test repositories

### Widget Tests
- Test UI components
- Test state management
- Test user interactions

### Integration Tests
- Test complete features
- Test data flow
- Test error scenarios 
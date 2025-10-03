# Habit Widget Implementation

## Overview
This iOS Widget Extension allows users to track and complete their habits directly from the iOS Home Screen without opening the main app.

## Features Implemented

### Small Widget (System Small)
- **Habit Display**: Shows the first active habit with emoji and name
- **Streak Counter**: Displays current streak with flame icon
- **Completion Button**: Interactive button to complete/uncomplete the habit
- **Real-time Updates**: Widget updates every 30 minutes and on completion actions

## Architecture

### Data Flow
1. **Flutter App** → Exports habit data to App Group container via `WidgetService`
2. **Widget** → Reads habit data from App Group container via `WidgetDataManager`
3. **User Interaction** → Widget updates data and triggers timeline reload

### Key Components

#### 1. HabitData.swift
- `HabitData`: Widget-compatible habit model
- `CompletionData`: Completion entry model
- `WidgetDataManager`: Manages data reading/writing to App Group

#### 2. HabitWidget.swift
- `HabitWidgetProvider`: Timeline provider for widget updates
- `SmallHabitWidgetView`: UI for small widget size
- `HabitWidget`: Main widget configuration

#### 3. HabitWidgetIntent.swift
- `CompleteHabitIntent`: Marks habit as completed
- `UncompleteHabitIntent`: Marks habit as not completed
- `ToggleHabitCompletionIntent`: Generic toggle intent

#### 4. WidgetService (Flutter)
- Exports Flutter habit data to JSON format
- Writes to App Group container for widget access

## Configuration

### App Groups
- **Identifier**: `group.com.habitrise.widgets`
- **Purpose**: Shared container between main app and widget
- **Location**: Both targets have App Groups capability enabled

### Widget Bundle ID
- **Main App**: `com.habitrise` (or your actual bundle ID)
- **Widget**: `com.habitrise.widgets`

## Usage

### Adding the Widget
1. Long press on Home Screen
2. Tap the "+" button
3. Search for "HabitForm" or "Habit Widget"
4. Select "Habit Tracker" widget
5. Choose Small size
6. Tap "Add Widget"

### Using the Widget
1. **View Habit**: See habit name, emoji, and current streak
2. **Complete Habit**: Tap the "Complete" button to mark as done
3. **Uncomplete Habit**: Tap "Done" button to undo completion
4. **Automatic Updates**: Widget refreshes every 30 minutes

## Data Synchronization

### Flutter to Widget
- Triggered when habits are created, updated, or completed
- Data exported as JSON to App Group container
- Widget reads data on timeline updates

### Widget to Flutter
- Widget updates are written to App Group container
- Main app can monitor for changes (future enhancement)
- Currently updates are persisted for widget consistency

## Testing

### Test Data
Use `TestDataGenerator.createTestHabitsFile()` to create sample data:
```swift
// Call this in widget's getTimeline method for testing
TestDataGenerator.createTestHabitsFile()
```

### Debug Information
- Widget logs to Xcode console
- Check App Group container path in logs
- Verify JSON file creation and reading

## Future Enhancements

### Planned Features
1. **Large Widget**: Show multiple habits with heatmap
2. **Extra Large Widget**: Detailed habit statistics
3. **Interactive Controls**: More complex habit interactions
4. **Customization**: User-selectable habits for widget

### Technical Improvements
1. **Bidirectional Sync**: Real-time updates from widget to main app
2. **Caching**: Improve widget performance with local caching
3. **Error Handling**: Better error states and fallbacks
4. **Accessibility**: VoiceOver and accessibility improvements

## Troubleshooting

### Common Issues
1. **Widget Not Appearing**: Check bundle identifiers and App Groups
2. **No Data**: Verify App Group container access and JSON file creation
3. **Updates Not Working**: Check widget timeline and intent handling
4. **Build Errors**: Ensure all Swift files are added to widget target

### Debug Steps
1. Check Xcode console for widget logs
2. Verify App Group container path exists
3. Test JSON file creation and reading
4. Validate widget timeline updates

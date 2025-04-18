---
description: 
globs: 
alwaysApply: false
---
# Frontend Guidelines Documentation

## UI/UX Principles

### Design System
- **Colors**: Consistent color palette
- **Typography**: Clear hierarchy
- **Spacing**: 8px grid system
- **Icons**: Cupertino icon set
- **Components**: Reusable widgets

### Layout Guidelines
- Responsive design
- Safe area consideration
- Consistent padding/margins
- Flexible layouts
- Adaptive components

## Widget Guidelines

### Custom Widgets
- Located in `lib/core/widgets/`
- Follow naming convention: `Custom[WidgetName]`
- Document widget properties
- Include usage examples
- Handle edge cases

### State Management
- Use `ConsumerWidget` for stateless
- Use `ConsumerStatefulWidget` for stateful
- Minimize widget rebuilds
- Use `const` constructors
- Implement proper disposal

## Code Style

### Widget Structure
```dart
class CustomWidget extends ConsumerWidget {
  const CustomWidget({
    super.key,
    required this.parameter,
  });

  final Type parameter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Widget();
  }
}
```

### Stateful Widget Structure
```dart
class CustomStatefulWidget extends ConsumerStatefulWidget {
  const CustomStatefulWidget({
    super.key,
    required this.parameter,
  });

  final Type parameter;

  @override
  ConsumerState<CustomStatefulWidget> createState() => _CustomStatefulWidgetState();
}

class _CustomStatefulWidgetState extends ConsumerState<CustomStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Widget();
  }
}
```

## Theme Guidelines

### Color Usage
- Primary colors for main actions
- Secondary colors for accents
- Neutral colors for backgrounds
- Semantic colors for states
- Consistent opacity values

### Typography
- Headline styles
- Body text styles
- Caption styles
- Button text styles
- Consistent font sizes

## Animation Guidelines

### Transitions
- Smooth page transitions
- Consistent duration
- Appropriate curves
- Performance consideration
- Fallback options

### Micro-interactions
- Feedback animations
- Loading states
- Success/error states
- Gesture responses
- State changes

## Accessibility

### Text Accessibility
- Sufficient contrast
- Readable font sizes
- Proper text scaling
- Semantic markup
- Screen reader support

### Interaction Accessibility
- Touch target size
- Gesture alternatives
- Focus management
- Keyboard navigation
- Voice control support

## Performance

### Rendering Optimization
- Const constructors
- Repaint boundaries
- Efficient layouts
- Image optimization
- Memory management

### State Optimization
- Minimal rebuilds
- Efficient providers
- Proper disposal
- Resource cleanup
- Background tasks 
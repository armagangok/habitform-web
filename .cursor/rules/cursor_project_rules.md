---
description: 
globs: 
alwaysApply: false
---
# Cursor Project Rules

## General Guidelines

### Code Organization
- Follow the established directory structure
- Keep related files together
- Use meaningful file names
- Maintain clean imports
- Document complex logic

### Version Control
- Use meaningful commit messages
- Follow branch naming conventions
- Regular commits
- Clean merge history
- Proper PR descriptions

## Development Workflow

### Branch Strategy
- `main` - Production code
- `develop` - Development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent fixes

### Code Review Process
1. Create feature branch
2. Implement changes
3. Run tests
4. Create PR
5. Address feedback
6. Merge to develop

## Code Style

### Dart Style
- Follow Dart style guide
- Use proper indentation
- Consistent naming
- Clear documentation
- Proper error handling

### Widget Guidelines
- Use const constructors
- Proper state management
- Clean widget tree
- Efficient rebuilds
- Proper disposal

## Testing Requirements

### Test Coverage
- Minimum 80% coverage
- Unit tests for logic
- Widget tests for UI
- Integration tests for flows
- Performance tests

### Test Organization
- Test files next to source
- Clear test names
- Proper test setup
- Clean test teardown
- Meaningful assertions

## Documentation

### Code Documentation
- Document public APIs
- Explain complex logic
- Include examples
- Update on changes
- Keep it current

### Project Documentation
- Update README
- Document architecture
- Keep changelog
- Document dependencies
- Update guides

## Performance

### Optimization Rules
- Profile regularly
- Fix memory leaks
- Optimize rebuilds
- Reduce bundle size
- Monitor performance

### Resource Usage
- Efficient images
- Proper caching
- Background tasks
- Battery optimization
- Network usage

## Security

### Code Security
- No hardcoded secrets
- Secure storage
- Input validation
- Error handling
- Regular audits

### Data Security
- Encrypt sensitive data
- Secure communication
- Proper authentication
- Access control
- Data backup

## Release Process

### Versioning
- Follow semantic versioning
- Update version numbers
- Tag releases
- Update changelog
- Document changes

### Deployment
- Test before release
- Follow checklist
- Monitor deployment
- Handle rollbacks
- Post-release checks 
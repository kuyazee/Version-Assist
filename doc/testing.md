# Testing Guidelines

## Running Tests

To run all unit tests with coverage:

```sh
# Install coverage package
dart pub global activate coverage 1.2.0

# Run tests with coverage
dart test --coverage=coverage

# Format coverage report
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

## Coverage Requirements

This project maintains a minimum test coverage requirement of 80% to ensure code quality and reliability. 

### Checking Coverage

To view the current test coverage:

```sh
# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/

# Open coverage report in browser
open coverage/index.html
```

### Coverage Rules

1. All new code must maintain or improve the current coverage percentage
2. Minimum coverage requirements:
   - Overall project coverage: 80%
   - New features/changes: 80%
   - Critical business logic: 90%

### Improving Coverage

If your changes result in coverage below 80%:

1. Identify uncovered code using the HTML coverage report
2. Add missing test cases focusing on:
   - Edge cases
   - Error conditions
   - Main success scenarios
3. Run coverage check again to verify improvement

### Exemptions

Some code may be exempted from coverage requirements:

- Generated code
- Platform-specific implementation details
- Simple getters/setters
- Debug-only code

To exempt code from coverage, add the following comment:

```dart
// coverage:ignore-file
```

## Best Practices

1. Write tests before implementing features (TDD approach)
2. Group related tests using `group()`
3. Use descriptive test names that explain the scenario
4. Follow the Arrange-Act-Assert pattern
5. Mock external dependencies
6. Test edge cases and error conditions

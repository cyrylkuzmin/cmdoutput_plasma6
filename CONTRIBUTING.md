# Contributing to cmdoutput

Thank you for your interest in contributing to cmdoutput! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Commit with clear messages: `git commit -am 'Add feature description'`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/yourname/cmdoutput_plasma6.git
cd cmdoutput_plasma6

# Build
cd cmdoutput_plasma6/contents/code
bash build-install.sh

# Test changes
plasmashell --replace &
```

## Code Style

- **C++**: Follow Qt/KDE coding standards (4-space indentation)
- **QML**: Use proper indentation and naming conventions (camelCase for properties/functions)
- **Commit messages**: Be descriptive and reference any related issues

## Areas for Contribution

- Bug fixes and error handling
- Performance improvements
- New features (please open an issue first to discuss)
- Documentation and examples
- Translation support
- Testing on different systems/configurations

## Testing

Before submitting a PR, please:

1. Test the widget loads correctly
2. Test with various shell commands
3. Test the configuration UI
4. Test auto-refresh functionality
5. Verify no console errors

## Reporting Issues

When reporting bugs, include:
- KDE Plasma version
- Qt version
- Command that triggers the issue
- Error messages or logs
- Steps to reproduce

## Questions?

Feel free to open a GitHub Discussion or Issue for questions and suggestions.

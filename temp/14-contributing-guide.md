# Contributing to MinimalAIChat

Thank you for your interest in contributing to MinimalAIChat! This document provides guidelines and instructions for contributing to the project. By participating, you are expected to uphold our code of conduct and follow these guidelines to help make the contribution process smooth and effective.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Contribution Workflow](#contribution-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

Our community strives to be open, inclusive, and respectful. We expect all contributors to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

1. **Fork the Repository**: Start by forking the MinimalAIChat repository on GitHub.

2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/MinimalAIChat.git
   cd MinimalAIChat
   ```

3. **Add Upstream Remote**:
   ```bash
   git remote add upstream https://github.com/original-owner/MinimalAIChat.git
   ```

4. **Keep Your Fork Updated**:
   ```bash
   git fetch upstream
   git merge upstream/main
   ```

## Development Environment

### Requirements

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- Swift 5.7+

### Setting Up

1. **Open the Project in Xcode**:
   ```bash
   open MinimalAIChat.xcodeproj
   ```

2. **Install Dependencies** (if using Swift Package Manager):
   Dependencies should be automatically resolved when opening the project. If not, use:
   ```bash
   swift package resolve
   ```

3. **Configure API Keys**:
   Copy the example configuration file and add your API keys:
   ```bash
   cp Config/APIConfig.example.swift Config/APIConfig.swift
   ```
   Then edit `APIConfig.swift` with your own API keys for development.

## Contribution Workflow

1. **Find an Issue**: Check the [issues](https://github.com/original-owner/MinimalAIChat/issues) for open tasks or create a new one for bugs or feature suggestions.

2. **Create a Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or for bugs:
   git checkout -b fix/bug-description
   ```

3. **Make Changes**: Implement your feature or fix the bug, following our coding standards.

4. **Commit Your Changes**:
   ```bash
   git commit -m "Feature/Fix: Concise description of the changes"
   ```
   
   Please use the following prefixes in your commit messages to categorize changes:
   - `Feature:` for new features
   - `Fix:` for bug fixes
   - `Docs:` for documentation changes
   - `Style:` for code style changes (formatting, etc.)
   - `Refactor:` for code refactoring
   - `Test:` for adding or modifying tests
   - `Chore:` for build process or tooling changes

5. **Push to Your Fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**: Open a pull request from your fork to the main repository.

## Coding Standards

### Swift Style Guide

We follow a modified version of the [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide) with the following specifics:

1. **Naming**:
   - Use descriptive names with camel case
   - For classes, protocols, structs, and enums, use upper camel case (e.g., `ChatViewModel`)
   - For methods, properties, and variables, use lower camel case (e.g., `messageSent`)

2. **Spacing**:
   - Use 4 spaces for indentation
   - Add a single space around binary operators (`+`, `-`, `*`, `/`, etc.)
   - No space after opening parentheses and before closing parentheses

3. **Documentation**:
   - All public methods, properties, and types should include documentation comments
   ```swift
   /// Registers a global hotkey with the system
   /// - Parameters:
   ///   - keyCombo: The key combination to register
   ///   - action: The action to execute when hotkey is triggered
   /// - Returns: A registration identifier or nil if registration failed
   func registerHotkey(keyCombo: KeyCombo, action: @escaping () -> Void) -> String? {
       // Implementation
   }
   ```

4. **SwiftLint**:
   We use SwiftLint to enforce our style guide. Please ensure your code passes the linter before submitting. The configuration is in `.swiftlint.yml` in the project root.

### Architecture

- Follow the MVVM (Model-View-ViewModel) pattern for UI components
- Keep components small and focused on a single responsibility
- Use protocols for dependency injection and testability
- Separate components into appropriate modules based on functionality

## Testing

All new features and bug fixes should include appropriate tests:

- **Unit Tests**: Test individual components in isolation
- **UI Tests**: Test user interface interactions
- **Integration Tests**: Test component interaction

Execute tests before submitting a pull request:
```bash
xcodebuild test -scheme MinimalAIChat -destination 'platform=macOS'
```

## Documentation

- Update README.md if you're changing functionality
- Add inline documentation for public APIs using Swift's documentation comments
- Update any relevant documentation in the `docs/` directory
- If adding new major features, consider adding a file to the docs directory explaining its architecture and usage

## Pull Request Process

1. **Create a Pull Request**: Submit a PR with a clear title and description.

2. **Address Review Comments**: Make changes requested by reviewers.

3. **Update CHANGELOG.md**: Add your changes to the Unreleased section.

4. **Merge Requirements**:
   - PR must pass all tests and CI checks
   - PR must be approved by at least one maintainer
   - All conversations must be resolved

## Community

- **Discussions**: For general questions and discussions, use the GitHub Discussions feature.
- **Issues**: Use GitHub Issues for bug reports and feature requests.
- **Contact**: For private inquiries, contact the maintainers via email.

## Recognizing Contributions

We believe in recognizing all types of contributions, not just code. This includes:

- Documentation improvements
- Bug reports
- Feature suggestions
- Design contributions
- Answering questions in discussions
- Marketing and promotion of the project

All contributors will be added to our `CONTRIBUTORS.md` file.

---

**Thank you for contributing to MinimalAIChat!**

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 
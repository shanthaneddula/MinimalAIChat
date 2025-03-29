# MinimalAIChat V2

A privacy-focused, high-performance AI chat application for macOS.

## Features

- Privacy-first approach with local processing capabilities
- High-performance architecture with efficient resource management
- Seamless macOS integration
- Extensible plugin system
- Advanced session management
- Secure authentication and data handling

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MinimalAIChat.git
cd MinimalAIChat
```

2. Build the project:
```bash
swift build
```

3. Run the application:
```bash
swift run
```

## Development

### Project Structure

```
Sources/
├── MinimalAIChat/        # Main application target
│   ├── Core/            # Core application logic
│   ├── Features/        # Feature modules
│   ├── Infrastructure/  # Infrastructure services
│   └── UI/             # User interface components
└── MinimalAIChatCore/   # Core library target

Tests/
├── Unit/               # Unit tests
├── Integration/        # Integration tests
└── Performance/       # Performance tests
```

### Building

```bash
# Build the project
swift build

# Run tests
swift test

# Run specific test target
swift test --filter MinimalAIChatTests
```

### Code Style

This project uses SwiftLint for code style enforcement. The configuration can be found in `.swiftlint.yml`.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
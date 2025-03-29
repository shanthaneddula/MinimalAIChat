# MinimalAIChat

A native macOS application providing instant, privacy-focused access to AI chat through a minimal interface with global hotkey activation.

## Features

- **Global Hotkey Access**: Summon the app from anywhere with a keyboard shortcut
- **Minimal Memory Footprint**: Only 45MB vs 200MB+ for web alternatives
- **Privacy-Focused**: Minimal data collection, local processing where possible
- **Native macOS Integration**: Spotlight search, Universal Links, and more
- **Optimized Performance**: Fast, responsive UI built with Swift and SwiftUI

## Current Status (v1.0)

In the initial version, MinimalAIChat focuses on:
- Wrapping web interfaces for top AI services
- Providing a unified chat experience
- Supporting platforms like ChatGPT, Claude AI, and DeepSeek

## Future Plans (v2.0)

In version 2.0 (planned for Q3-Q4 2024), we will implement direct API integration with:
- Native API support for all major AI platforms
- Seamless switching between web and API-based interactions
- Advanced configuration and management of AI service connections
- Secure API key storage in macOS Keychain

For more details, see the [API Key Implementation Roadmap](docs/api-key-future-implementation-doc.md).

## Getting Started

### Prerequisites

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- Swift 5.7+

### Setup Guide

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/MinimalAIChat.git
   cd MinimalAIChat
   ```

2. **Initialize Git repository** (if not already cloned)
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

3. **Set up project structure**
   ```bash
   mkdir -p App/{Core,Modules,UI,Utilities}
   mkdir -p App/Modules/{Hotkey,WebView,Subscription,Security,Navigation,Discovery}
   mkdir -p App/UI/{Views,Localization,Accessibility}
   mkdir -p Resources/{Assets.xcassets,Entitlements}
   mkdir -p Tests/{Unit,UI,Performance}
   mkdir -p docs
   ```

4. **Create Xcode project**
   ```bash
   # Open Xcode and create a new macOS app project
   # Choose SwiftUI App template
   # Name it MinimalAIChat
   # Save it in the repository folder
   ```

5. **Configure project**
   - Set minimum deployment target to macOS 12.0
   - Enable App Sandbox with network access
   - Add necessary entitlements for hotkey monitoring
   - Set up Info.plist with proper App Transport Security settings

6. **Install dependencies** (if using Swift Package Manager)
   - Open the project in Xcode
   - File > Swift Packages > Add Package Dependency
   - Add essential packages (if needed)

7. **Configure the project for development**
   ```bash
   # Copy example configuration files
   cp Config/APIConfig.example.swift Config/APIConfig.swift
   # Edit APIConfig.swift with your development settings
   ```

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- [Product Requirements](docs/01-product-requirements.md)
- [Technical Specification](docs/02-technical-specification.md)
- [Project Structure](docs/03-project-structure.md)
- [Project Overview](docs/04-project-overview.md)
- [Implementation Guide](docs/05-implementation-guide.md)
- [Core Component Implementation](docs/06-core-component-implementation.md)
- [Performance Optimization](docs/07-performance-optimization.md)
- [Testing Plan](docs/08-testing-plan.md)
- [Accessibility Testing](docs/09-accessibility-testing.md)
- [Security & Compliance](docs/10-security-compliance.md)
- [SEO & App Store Optimization](docs/11-seo-workflow.md)
- [Deployment Guide](docs/12-deployment-guide.md)
- [Glossary](docs/13-glossary.md)
- [Contributing Guide](docs/14-contributing-guide.md)

## Contributing

Please read our [Contributing Guide](docs/14-contributing-guide.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [OpenAI](https://openai.com/) for ChatGPT
- [Anthropic](https://www.anthropic.com/) for Claude
- [DeepSeek](https://deepseek.ai/) for DeepSeek AI 
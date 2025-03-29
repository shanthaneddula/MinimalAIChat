# MinimalAIChat Setup Guide

This guide provides detailed, step-by-step instructions for setting up the MinimalAIChat project from scratch, including repository creation, project structure, and development environment configuration.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Repository Setup](#repository-setup)
- [Project Structure Creation](#project-structure-creation)
- [Xcode Project Setup](#xcode-project-setup)
- [Configuration Files](#configuration-files)
- [Environment Setup](#environment-setup)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have the following installed:

- macOS 12.0+ (Monterey or later)
- Xcode 14.0+ (with Command Line Tools)
- Git
- Swift 5.7+

You can check your Swift version with:
```bash
swift --version
```

## Repository Setup

### 1. Create a Local Repository

Start by creating a directory for your project and initialize a Git repository:

```bash
# Create project directory
mkdir MinimalAIChat
cd MinimalAIChat

# Initialize git repository
git init

# Create initial README
echo "# MinimalAIChat" > README.md
git add README.md
git commit -m "Initial commit"
```

### 2. Set Up Remote Repository (Optional but Recommended)

#### GitHub Setup

1. Go to [GitHub](https://github.com) and sign in to your account
2. Click the "+" icon in the top-right corner and select "New repository"
3. Name the repository "MinimalAIChat"
4. Keep it private or public as per your preference
5. Do not initialize with README, .gitignore, or license as we've already created these locally
6. Click "Create repository"

Connect your local repository to the remote:

```bash
git remote add origin https://github.com/shanthaneddula/MinimalAIChat.git
git branch -M main
git push -u origin main
```

## Project Structure Creation

Create the recommended project structure following our documentation standards:

```bash
# Create main directories
mkdir -p App/{Core,Modules,UI,Utilities}
mkdir -p App/Modules/{Hotkey,WebView,Subscription,Security,Navigation,Discovery}
mkdir -p App/UI/{Views,Localization,Accessibility}
mkdir -p App/UI/Views/{Main,Preferences,Onboarding,Error}
mkdir -p Resources/{Assets.xcassets,Entitlements}
mkdir -p Tests/{Unit,UI,Performance}
mkdir -p docs
mkdir -p Config
mkdir -p Fastlane/{scripts}
mkdir -p .github/workflows

# Create placeholder files for key components
touch App/Core/{AppMain.swift,AppDelegate.swift,Constants.swift}
touch App/Modules/Hotkey/{HotkeyManager.swift,KeyCombo.swift,LaunchAgentService.swift}
touch App/Modules/WebView/{WebViewModel.swift,WebViewWrapper.swift,WebViewCleanupable.swift}
touch Resources/Entitlements/App.entitlements
touch Config/APIConfig.example.swift
```

## Xcode Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. Choose "File > New > Project..."
3. Select "macOS" tab and choose "App" template
4. Enter project details:
   - Product Name: MinimalAIChat
   - Team: Your development team (or Personal Team)
   - Organization Identifier: com.yourcompany (use your actual domain)
   - Interface: SwiftUI
   - Language: Swift
   - Ensure "Use Core Data" is unchecked
5. Choose the MinimalAIChat directory you created as the location for the project

### 2. Configure Project Settings

1. Select the project in the Navigator
2. In the "General" tab:
   - Set Minimum Deployment to macOS 12.0
   - Set App Category to "Productivity"
   - Enable Hardened Runtime
3. In the "Signing & Capabilities" tab:
   - Add the "App Sandbox" capability
   - Check "Outgoing Connections (Client)" under Network
   - If needed for hotkeys, add "Apple Events" capability

### 3. Configure Entitlements

Edit the `Resources/Entitlements/App.entitlements` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
```

### 4. Configure Info.plist

Ensure your Info.plist has the following settings:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <true/>
</dict>
```

## Configuration Files

### 1. Create API Configuration Template

Create a template for API configuration that developers can customize:

```swift
// Config/APIConfig.example.swift
import Foundation

/// This is an example configuration file.
/// Copy this to APIConfig.swift and fill in your actual API keys
struct APIConfig {
    // In the initial version, these are placeholders for future API integration
    static let openAIKey = "YOUR_OPENAI_API_KEY"
    static let anthropicKey = "YOUR_ANTHROPIC_API_KEY"
    static let deepSeekKey = "YOUR_DEEPSEEK_API_KEY"
    
    // Future configuration options
    static let organizationID = "YOUR_ORGANIZATION_ID" // Optional for some services
    
    // Feature flags
    static let useDirectAPI = false // Set to false for initial web-based version
    
    // Add additional configuration as needed
}
```

### 2. Create GitIgnore File

Create a `.gitignore` file to prevent sensitive information from being committed:

```bash
# Create .gitignore file
cat > .gitignore << 'EOL'
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## Xcode Patch
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
/*.gcno
**/xcshareddata/WorkspaceSettings.xcsettings

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
.build/
.swiftpm/

# CocoaPods
Pods/
Podfile.lock

# Carthage
Carthage/Checkouts
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
iOSInjectionProject/

# API Keys and secrets
Config/APIConfig.swift

# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Build products
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
EOL

git add .gitignore
git commit -m "Add .gitignore file"
```

## Environment Setup

### 1. Install Dependencies

If using Swift Package Manager:

1. In Xcode, go to "File > Swift Packages > Add Package Dependency..."
2. Add any necessary packages:
   - For HotKey support: https://github.com/soffes/HotKey
   - For auto-updates (if distributing outside App Store): https://github.com/sparkle-project/Sparkle

### 2. Set Up APIConfig.swift

```bash
# Copy the example to the actual file
cp Config/APIConfig.example.swift Config/APIConfig.swift
```

Edit the `Config/APIConfig.swift` file with your development settings if needed.

### 3. Build and Run Test

1. In Xcode, select the "MinimalAIChat" scheme
2. Choose a Mac simulator or your Mac as the build target
3. Click the Run button (▶️) or press Cmd+R
4. Verify the app builds and runs successfully

## Development Workflow

### 1. Branch Strategy

For development, follow this branch strategy:

```bash
# Create a development branch
git checkout -b develop
git push -u origin develop

# For new features
git checkout -b feature/feature-name develop
# For bug fixes
git checkout -b fix/bug-description develop
```

### 2. Initial Implementation

Start by implementing the core functionality:

1. `App/Core/AppMain.swift` - Create the SwiftUI app entry point
2. `App/Core/AppDelegate.swift` - Set up app lifecycle handling
3. `App/Modules/WebView/WebViewWrapper.swift` - Create the WebView wrapper for AI chat interfaces

### 3. Committing Code

```bash
# Add your changes
git add .

# Commit with descriptive message
git commit -m "Feature: Implement core app structure"

# Push to remote repository
git push origin feature/feature-name
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Xcode Build Errors

- **Issue**: "Missing package product" errors
  - **Solution**: Go to "File > Packages > Reset Package Caches"

- **Issue**: Entitlements issues
  - **Solution**: Ensure the entitlements file is properly linked in build settings

#### 2. Git Setup Issues

- **Issue**: Unable to push to remote repository
  - **Solution**: Verify remote URL with `git remote -v` and ensure you have proper access

#### 3. Project Structure Issues

- **Issue**: Files not showing in Xcode
  - **Solution**: Use "File > Add Files to 'MinimalAIChat'..." to add previously created files to the project

---

**Next Steps**: Once setup is complete, refer to the [Implementation Guide](05-implementation-guide.md) for guidance on developing the core functionality.

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 
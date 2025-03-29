# Deployment and Release Guide

This document outlines the deployment and release process for MinimalAIChat, covering versioning strategy, release cadence, build configuration, and distribution channels.

## 1. Release Strategy

### 1.1 Versioning Approach

MinimalAIChat follows **Semantic Versioning (SemVer)**: MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes, significant UI overhauls
- **MINOR**: Backwards-compatible feature additions
- **PATCH**: Backwards-compatible bug fixes

Example version progression:
- 1.0.0: Initial release
- 1.1.0: Added offline mode
- 1.1.1: Fixed memory leak in WebView
- 2.0.0: Redesigned UI and subscription model

### 1.2 Release Cadence

| Release Type | Frequency | Purpose |
|--------------|-----------|---------|
| **Major Releases** | Biannually | Major feature updates, redesigns |
| **Minor Releases** | Monthly | New features, improvements |
| **Patch Releases** | As needed | Critical bug fixes, security updates |

### 1.3 Branch Strategy

```mermaid
gitGraph
    commit id: "Initial"
    branch develop
    checkout develop
    commit id: "Feature work"
    branch feature/offline-mode
    checkout feature/offline-mode
    commit id: "Offline implementation"
    commit id: "Tests"
    checkout develop
    merge feature/offline-mode
    branch release/v1.1
    checkout release/v1.1
    commit id: "Version bump"
    commit id: "Release prep"
    checkout main
    merge release/v1.1
    tag "v1.1.0"
```

- **main**: Production code, tagged with releases
- **develop**: Integration branch for features
- **feature/***: Individual feature development
- **release/***: Release preparation
- **hotfix/***: Urgent fixes for production

## 2. Preparation Checklist

### 2.1 Pre-Release Validation

- [ ] All unit tests pass
- [ ] UI tests complete
- [ ] Performance benchmarks met:
  - [ ] Memory usage ≤ 200MB
  - [ ] CPU usage ≤ 20%
  - [ ] Startup time ≤ 1 second
- [ ] Security audit completed:
  - [ ] Certificate pinning validated
  - [ ] Keychain storage verified
  - [ ] Network security tested
- [ ] Localization verified
- [ ] Accessibility compliance checked:
  - [ ] VoiceOver compatibility
  - [ ] Keyboard navigation
  - [ ] Dynamic type support

### 2.2 Documentation Updates

- [ ] Update README.md
- [ ] Generate release notes
- [ ] Update version in:
  - [ ] Info.plist
  - [ ] Package.swift (if using SPM)
  - [ ] Marketing materials

### 2.3 Marketing Preparation

- [ ] Update App Store screenshots
- [ ] Refresh App Store description if needed
- [ ] Prepare email newsletter announcement
- [ ] Draft social media announcements
- [ ] Update website with new features

## 3. Build Process

### 3.1 Environment Configuration

Maintain separate environments:

| Environment | Purpose | Configuration |
|-------------|---------|--------------|
| Development | Daily development | Debug, local services |
| Staging | Pre-release testing | Release build, staging services |
| Production | Released app | Release build, production services |

Configure environment-specific values in a `Config.xcconfig` file:

```
// Development.xcconfig
API_BASE_URL = https://dev-api.minimalchat.app
ENABLE_LOGGING = YES

// Production.xcconfig
API_BASE_URL = https://api.minimalchat.app
ENABLE_LOGGING = NO
```

### 3.2 Xcode Build Configuration

#### 3.2.1 Build Settings

- **Configuration**: Release
- **Architectures**: 
  - Intel (x86_64)
  - Apple Silicon (arm64)
- **Deployment Target**: macOS 12.0 (Monterey)
- **Optimization**: Fastest, Smallest [-Os]
- **Bitcode**: Not required for macOS

#### 3.2.2 Build Phases

Add a custom build phase for version stamping:

```bash
# Update build number with git commit count
buildNumber=$(git rev-list HEAD | wc -l | tr -d ' ')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"

# Add git commit hash to Info.plist
gitHash=$(git rev-parse --short HEAD)
/usr/libexec/PlistBuddy -c "Add :GitCommitHash string $gitHash" "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
```

### 3.3 Code Signing

#### 3.3.1 Developer ID Signing (Direct Distribution)

- Obtain Developer ID Application certificate
- Enable hardened runtime
- Configure entitlements in `App.entitlements`

#### 3.3.2 App Store Signing

- Use Apple Distribution certificate
- Configure provisioning profiles
- Set automatic signing in Xcode

## 4. Distribution Channels

### 4.1 Mac App Store

#### 4.1.1 Submission Process

1. Archive app in Xcode
2. Validate App Store readiness
3. Upload to App Store Connect
4. Complete metadata:
   - App description
   - Screenshots
   - Keywords
   - Pricing
   - App privacy details
5. Submit for review

#### 4.1.2 TestFlight

- Create internal testing group for team members
- Add external testers for beta testing
- Set beta app review information
- Configure build expiration (90 days maximum)

### 4.2 Direct Distribution

#### 4.2.1 DMG Creation

Use a script to create a professional DMG installer:

```bash
# create-dmg.sh
#!/bin/bash

# Variables
APP_NAME="MinimalAIChat"
DMG_NAME="${APP_NAME}-$(git describe --tags).dmg"
VOLUME_NAME="${APP_NAME} Installer"
SOURCE_FOLDER="./build/Release"
APP_PATH="${SOURCE_FOLDER}/${APP_NAME}.app"
DMG_PATH="./build/${DMG_NAME}"

# Create temp DMG
hdiutil create -srcfolder "${SOURCE_FOLDER}" -volname "${VOLUME_NAME}" -fs HFS+ \
      -fsargs "-c c=64,a=16,e=16" -format UDRW -size 100m "${DMG_PATH}"

# Mount the temp DMG
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_PATH}" | egrep '^/dev/' | sed 1q | awk '{print $1}')

# Customize appearance
echo '
   tell application "Finder"
     tell disk "'${VOLUME_NAME}'"
       open
       set current view of container window to icon view
       set toolbar visible of container window to false
       set statusbar visible of container window to false
       set the bounds of container window to {400, 100, 900, 440}
       set position of item "'${APP_NAME}'.app" of container window to {160, 180}
       set position of item "Applications" of container window to {340, 180}
       close
       open
       update without registering applications
       delay 2
     end tell
   end tell
' | osascript

# Finalize the DMG
hdiutil detach "${DEVICE}"
hdiutil convert "${DMG_PATH}" -format UDZO -imagekey zlib-level=9 -o "${DMG_PATH/.dmg/-final.dmg}"
mv "${DMG_PATH/.dmg/-final.dmg}" "${DMG_PATH}"

echo "Created ${DMG_PATH}"
```

#### 4.2.2 Auto-Update Mechanism

Implement Sparkle for automatic updates:

1. Add Sparkle framework via SPM:
   ```swift
   dependencies: [
       .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.3.0")
   ]
   ```

2. Configure app to check for updates:
   ```swift
   import Sparkle
   
   class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
       private var updater: SPUUpdater!
       
       func applicationDidFinishLaunching(_ notification: Notification) {
           // Set up Sparkle
           let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
           updater = updaterController.updater
       }
       
       // Optional: Customize update behavior
       func updater(_ updater: SPUUpdater, shouldScheduleUpdate item: SUAppcastItem) -> Bool {
           // You can add logic here to determine if this update should be applied
           return true
       }
   }
   ```

3. Host an appcast.xml file:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
       <channel>
           <title>MinimalAIChat Updates</title>
           <link>https://minimalchat.app/appcast.xml</link>
           <description>Updates for MinimalAIChat</description>
           <language>en</language>
           <item>
               <title>Version 1.1.0</title>
               <description>
                   <![CDATA[
                       <h2>New Features</h2>
                       <ul>
                           <li>Added offline mode for previously accessed content</li>
                           <li>Improved memory management</li>
                           <li>Added customizable hotkeys</li>
                       </ul>
                   ]]>
               </description>
               <pubDate>Sat, 26 Mar 2023 12:00:00 +0000</pubDate>
               <enclosure url="https://minimalchat.app/downloads/MinimalAIChat-1.1.0.dmg"
                          sparkle:version="1.1.0"
                          sparkle:shortVersionString="1.1.0"
                          length="8276418"
                          type="application/octet-stream"
                          sparkle:edSignature="..." />
               <sparkle:minimumSystemVersion>12.0</sparkle:minimumSystemVersion>
           </item>
       </channel>
   </rss>
   ```

## 5. Notarization Process

### 5.1 Notarization Steps

1. Create archive in Xcode
2. Export with Developer ID
3. Submit for notarization:
   ```bash
   xcrun notarytool submit MinimalAIChat.app \
     --apple-id "your@email.com" \
     --password "@keychain:AC_PASSWORD" \
     --team-id "YOUR_TEAM_ID" \
     --wait
   ```
4. Staple ticket to application:
   ```bash
   xcrun stapler staple MinimalAIChat.app
   ```
5. Verify notarization status:
   ```bash
   spctl -a -vvv -t exec MinimalAIChat.app
   ```

### 5.2 Notarization Automation

Add notarization to the CI/CD pipeline:

```bash
# notarize-app.sh
#!/bin/bash

# Variables
APP_PATH="$1"
APPLE_ID="$2"
TEAM_ID="$3"
APP_PASSWORD="$4"

# Create temp zip for notarization
ZIP_PATH=$(mktemp -d)/app.zip
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

# Submit for notarization
echo "Submitting for notarization..."
SUBMISSION_ID=$(xcrun notarytool submit "${ZIP_PATH}" \
  --apple-id "${APPLE_ID}" \
  --password "${APP_PASSWORD}" \
  --team-id "${TEAM_ID}" \
  --no-progress)

# Wait for completion
echo "Waiting for notarization to complete..."
xcrun notarytool wait "${SUBMISSION_ID}" \
  --apple-id "${APPLE_ID}" \
  --password "${APP_PASSWORD}" \
  --team-id "${TEAM_ID}"

# Check status
NOTARIZATION_INFO=$(xcrun notarytool info "${SUBMISSION_ID}" \
  --apple-id "${APPLE_ID}" \
  --password "${APP_PASSWORD}" \
  --team-id "${TEAM_ID}")

if echo "${NOTARIZATION_INFO}" | grep -q "status: Accepted"; then
  echo "Notarization successful!"
  # Staple the ticket
  xcrun stapler staple "${APP_PATH}"
  echo "Ticket stapled to application!"
  exit 0
else
  echo "Notarization failed:"
  echo "${NOTARIZATION_INFO}"
  exit 1
fi
```

## 6. Continuous Integration/Continuous Deployment (CI/CD)

### 6.1 GitHub Actions Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: MinimalAIChat CI/CD

on:
  push:
    branches: [ main, develop ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ develop ]

jobs:
  build-and-test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: latest-stable
    
    - name: Install dependencies
      run: |
        brew install swiftlint
    
    - name: Run SwiftLint
      run: swiftlint
    
    - name: Build
      run: xcodebuild clean build -scheme MinimalAIChat -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    
    - name: Run Tests
      run: xcodebuild test -scheme MinimalAIChat -destination 'platform=macOS' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    
    - name: Build Release (tagged commits only)
      if: startsWith(github.ref, 'refs/tags/v')
      run: xcodebuild clean archive -scheme MinimalAIChat -configuration Release -archivePath build/MinimalAIChat.xcarchive
    
    - name: Create DMG (tagged commits only)
      if: startsWith(github.ref, 'refs/tags/v')
      run: |
        chmod +x ./Scripts/create-dmg.sh
        ./Scripts/create-dmg.sh
    
    - name: Upload DMG as artifact
      if: startsWith(github.ref, 'refs/tags/v')
      uses: actions/upload-artifact@v3
      with:
        name: MinimalAIChat-DMG
        path: build/MinimalAIChat-*.dmg
    
    - name: Create Release
      if: startsWith(github.ref, 'refs/tags/v')
      uses: softprops/action-gh-release@v1
      with:
        files: build/MinimalAIChat-*.dmg
        draft: true
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 6.2 Fastlane Integration

Create a `Fastfile` for automated deployment:

```ruby
# Fastlane/Fastfile
default_platform(:mac)

platform :mac do
  desc "Run tests"
  lane :test do
    run_tests(scheme: "MinimalAIChat")
  end

  desc "Build for TestFlight"
  lane :beta do
    # Increment build number based on latest TestFlight build
    increment_build_number(
      build_number: latest_testflight_build_number + 1
    )
    
    # Build the app
    build_app(
      scheme: "MinimalAIChat",
      export_method: "app-store"
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build and upload to App Store"
  lane :release do
    # Capture version from git tag
    version = last_git_tag.gsub(/[^\d\.]/, '')
    
    # Update version in Info.plist
    increment_version_number(version_number: version)
    
    # Build and upload
    build_app(
      scheme: "MinimalAIChat",
      export_method: "app-store"
    )
    
    # Upload to App Store
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: true,
      automatic_release: true,
      force: true
    )
    
    # Notify team
    slack(
      message: "MinimalAIChat v#{version} released to App Store!",
      success: true
    )
  end
end
```

## 7. Beta Testing

### 7.1 TestFlight Setup

1. Configure TestFlight in App Store Connect
2. Create testing groups:
   - Internal (team members)
   - External (beta testers)
3. Add test information:
   - Beta app description
   - Beta app feedback email
   - Marketing URL

### 7.2 Feedback Collection

Implement a dedicated feedback mechanism:

```swift
struct FeedbackView: View {
    @State private var feedback = ""
    @State private var email = ""
    @State private var includeSystemInfo = true
    @State private var feedbackType = FeedbackType.general
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    enum FeedbackType: String, CaseIterable, Identifiable {
        case general = "General Feedback"
        case bug = "Bug Report"
        case feature = "Feature Request"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Your Feedback")) {
                Picker("Feedback Type", selection: $feedbackType) {
                    ForEach(FeedbackType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                TextEditor(text: $feedback)
                    .frame(height: 150)
                
                TextField("Email (Optional)", text: $email)
                    .textContentType(.emailAddress)
                
                Toggle("Include System Information", isOn: $includeSystemInfo)
            }
            
            Button(action: submitFeedback) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("Submit Feedback")
                }
            }
            .disabled(feedback.isEmpty || isSubmitting)
        }
        .padding()
        .frame(width: 450)
        .alert("Feedback Sent", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your feedback!")
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // Prepare feedback data
        var feedbackData: [String: Any] = [
            "type": feedbackType.rawValue,
            "message": feedback
        ]
        
        if !email.isEmpty {
            feedbackData["email"] = email
        }
        
        if includeSystemInfo {
            feedbackData["systemInfo"] = gatherSystemInfo()
        }
        
        // Send feedback
        Task {
            do {
                try await sendFeedback(feedbackData)
                isSubmitting = false
                showSuccess = true
                feedback = ""
            } catch {
                isSubmitting = false
                // Handle error
            }
        }
    }
    
    private func gatherSystemInfo() -> [String: String] {
        return [
            "macOS": ProcessInfo.processInfo.operatingSystemVersionString,
            "model": deviceModel(),
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        ]
    }
    
    private func deviceModel() -> String {
        var size: size_t = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    private func sendFeedback(_ data: [String: Any]) async throws {
        // Implementation to send feedback to your backend
    }
}
```

## 8. Post-Release

### 8.1 Monitoring

- Track crash reports in Xcode Organizer
- Monitor App Store reviews
- Check support emails for issues
- Analyze app analytics for usage patterns

### 8.2 Rollback Strategy

In case of critical issues:

1. **Identification**:
   - Monitor crash rates in App Store Connect
   - Set up alerts for elevated crash rates

2. **Immediate Action**:
   - For App Store: Temporarily pause promotion
   - For direct distribution: Disable download links

3. **Fix Implementation**:
   - Create hotfix branch from tagged release
   - Implement fix with thorough testing
   - Release as patch version

4. **Communication**:
   - Notify users via in-app alert
   - Update release notes
   - Publish notification on website

## 9. Release Communication

### 9.1 Release Notes Template

```markdown
# MinimalAIChat v1.1.0

## New Features
- **Offline Mode**: Access your recent conversations even without internet
- **Customizable Hotkeys**: Personalize your activation shortcut in Preferences
- **Enhanced Privacy Controls**: Added options to control data collection

## Improvements
- Reduced memory usage by 25%
- Faster startup time
- Improved keyboard navigation

## Bug Fixes
- Fixed WebView memory leak
- Resolved issue with hotkey not working in certain applications
- Fixed text selection in dark mode

## Known Issues
- May experience slow response when opening large conversations
```

### 9.2 Communication Channels

- App Store release notes
- Website announcement banner
- Email newsletter to users
- Social media posts
- In-app notification

---

**Document Information**
- **Version:** 1.0.0
- **Last Updated:** March 26, 2023
- **Status:** Draft 
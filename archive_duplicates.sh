#!/bin/bash

# Create timestamp for archive
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_DIR="Archived/duplicates_$TIMESTAMP"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# List of files to archive
FILES=(
    "App/Modules/Navigation/DeepLinkRoute.swift"
    "App/Modules/Security/CertificatePinner.swift"
    "App/Modules/Security/ThreadSafeCache.swift"
    "App/Modules/Subscription/Models/Product.swift"
    "App/Modules/Subscription/Models/SubscriptionTier.swift"
    "App/Modules/Subscription/Services/PurchaseManager.swift"
    "App/Modules/Subscription/Services/ReceiptValidator.swift"
    "App/Modules/Subscription/Services/SubscriptionService.swift"
    "App/Modules/Subscription/UI/PaywallView.swift"
    "App/Modules/Subscription/UI/RestorePurchaseButton.swift"
    "App/UI/Accessibility/AccessibleWebView.swift"
    "App/UI/Views/Error/AppError.swift"
    "App/UI/Views/Error/ErrorView.swift"
    "App/UI/Views/Onboarding/PrivacyConsentView.swift"
    "App/UI/Views/Preferences/AccountPrefsView.swift"
    "App/UI/Views/Preferences/AdvancedPrefsView.swift"
    "App/UI/Views/Preferences/GeneralPrefsView.swift"
    "App/UI/Views/Preferences/PreferencesView.swift"
    "App/Utilities/ErrorLogger.swift"
    "App/Utilities/LeakDetector.swift"
)

# Create a log file
LOG_FILE="$ARCHIVE_DIR/archive_log.txt"
echo "Archive created at: $TIMESTAMP" > "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# Move each file to the archive directory
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        # Create the directory structure in the archive
        mkdir -p "$ARCHIVE_DIR/$(dirname "$file")"
        # Move the file
        mv "$file" "$ARCHIVE_DIR/$file"
        echo "Archived: $file" >> "$LOG_FILE"
    else
        echo "File not found: $file" >> "$LOG_FILE"
    fi
done

echo "----------------------------------------" >> "$LOG_FILE"
echo "Archive complete. Check $LOG_FILE for details." 
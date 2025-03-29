#!/bin/bash

# Create a temporary directory for storing file hashes
TEMP_DIR=$(mktemp -d)
ARCHIVE_DIR="Archived"

# Create Archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Function to calculate file hash
calculate_hash() {
    md5 -q "$1"
}

# Function to check if file is a Swift source file
is_swift_file() {
    [[ "$1" == *.swift ]]
}

# Function to check if file is a test file
is_test_file() {
    [[ "$1" == *Tests.swift ]]
}

# Function to check if file is in the Archive directory
is_archived() {
    [[ "$1" == *"$ARCHIVE_DIR"* ]]
}

# Find all Swift files and calculate their hashes
echo "Scanning for duplicate files..."
find . -type f -name "*.swift" | while read -r file; do
    # Skip files in Archive directory and test files
    if ! is_archived "$file" && ! is_test_file "$file"; then
        hash=$(calculate_hash "$file")
        echo "$hash|$file" >> "$TEMP_DIR/hashes.txt"
    fi
done

# Find duplicates
echo "Analyzing duplicates..."
sort "$TEMP_DIR/hashes.txt" | awk -F'|' '
    NR==1 { prev=$1; files=$2 }
    NR>1 {
        if ($1 == prev) {
            files = files "\n" $2
        } else {
            if (files ~ /\n/) {
                print "Found duplicate files:"
                print files
                print "---"
            }
            prev=$1
            files=$2
        }
    }
    END {
        if (files ~ /\n/) {
            print "Found duplicate files:"
            print files
            print "---"
        }
    }
'

# Clean up
rm -rf "$TEMP_DIR"

echo "Duplicate file scan complete. Please review the results above." 
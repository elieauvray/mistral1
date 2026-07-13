#!/bin/bash

# SafePaste Build Script

echo "Building SafePaste..."

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: Xcode command line tools are not installed."
    echo "Please install Xcode from the Mac App Store and run:"
    echo "  xcode-select --install"
    exit 1
fi

# Build the project
cd "$(dirname "$0")/SafePaste"

# Clean and build
xcodebuild clean
xcodebuild -scheme SafePaste -configuration Release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can find SafePaste.app in the Release-iphoneos directory."
    
    # Try to open the built app
    if [ -d "build/Release/SafePaste.app" ]; then
        echo "Opening SafePaste.app..."
        open "build/Release/SafePaste.app"
    fi
else
    echo "Build failed. Please check the error messages above."
    exit 1
fi

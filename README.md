# Factory Auto Update App

A Flutter application with built-in auto-update functionality for factory deployment. This app allows users to check for updates, download new APK files, and install them without requiring Google Play Store.

## Features

- ✅ Auto-update functionality
- ✅ Check for updates from GitHub Releases
- ✅ Download and install APK automatically
- ✅ Bengali language interface
- ✅ Progress tracking for downloads
- ✅ No Google Play Store required

## How It Works

1. The app checks for updates from a `version.json` file hosted on GitHub
2. If a new version is available, it shows an update dialog
3. User can download and install the update with one click
4. The app handles all permissions automatically

## Version Information

Current Version: 1.0.1 (Build 2)

## Setup for Development

1. Clone this repository
2. Run `flutter pub get`
3. Update the GitHub repository URL in `lib/services/update_service.dart`
4. Build the app: `flutter build apk --release`

## Releasing Updates

1. Update version in `pubspec.yaml`
2. Build release APK: `flutter build apk --release`
3. Create a new GitHub Release with the APK
4. Update `version.json` with new version info
5. Commit and push changes

## License

This project is for internal factory use.

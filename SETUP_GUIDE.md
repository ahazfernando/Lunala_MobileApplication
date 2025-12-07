# How to Run the Keells Flutter App

## Prerequisites

### 1. Install Flutter

**For macOS (your system):**

1. **Download Flutter SDK:**
   - Visit: https://docs.flutter.dev/get-started/install/macos
   - Download the latest stable Flutter SDK for macOS
   - Extract the zip file to a location like `~/development/flutter`

2. **Add Flutter to PATH:**
   ```bash
   # Add this to your ~/.zshrc file (since you're using zsh)
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Or if you extracted to a different location:
   export PATH="$PATH:/path/to/flutter/bin"
   ```

3. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

4. **Verify installation:**
   ```bash
   flutter --version
   flutter doctor
   ```

### 2. Install Xcode (for iOS development)
   - Install from Mac App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - Accept license: `sudo xcodebuild -runFirstLaunch`

### 3. Install Android Studio (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK, Android SDK Platform-Tools, and Android Emulator
   - Accept Android licenses: `flutter doctor --android-licenses`

### 4. Install VS Code or Android Studio
   - VS Code: Install Flutter and Dart extensions
   - Android Studio: Install Flutter and Dart plugins

## Running the Application

### Step 1: Navigate to Project Directory
```bash
cd /Users/ahazfernando/Downloads/Lunala
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Check Available Devices
```bash
flutter devices
```

This will show:
- Connected physical devices (iPhone, Android phone)
- Available emulators/simulators

### Step 4: Run the App

**Option A: Run on iOS Simulator**
```bash
# Open iOS Simulator first
open -a Simulator

# Then run
flutter run
```

**Option B: Run on Android Emulator**
```bash
# Start Android Emulator from Android Studio, then:
flutter run
```

**Option C: Run on Connected Device**
```bash
# Connect your iPhone or Android phone via USB
# Enable developer mode on your device
flutter run
```

**Option D: Run on Specific Device**
```bash
# List devices
flutter devices

# Run on specific device (use device ID from list)
flutter run -d <device-id>
```

### Step 5: Hot Reload (During Development)
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Alternative: Using VS Code

1. Open the project folder in VS Code
2. Press `F5` or click "Run and Debug"
3. Select your target device (iOS/Android)
4. The app will launch automatically

## Troubleshooting

### If `flutter` command not found:
- Make sure Flutter is added to your PATH
- Restart your terminal
- Run `source ~/.zshrc`

### If dependencies fail:
```bash
flutter clean
flutter pub get
```

### If build fails:
```bash
flutter doctor
# Fix any issues shown
flutter clean
flutter pub get
flutter run
```

### Common Issues:

1. **iOS: CocoaPods not installed**
   ```bash
   sudo gem install cocoapods
   cd ios && pod install && cd ..
   ```

2. **Android: Gradle issues**
   - Make sure Android Studio is properly set up
   - Check that Android SDK is installed

3. **No devices found**
   - For iOS: Open Simulator from Xcode
   - For Android: Start emulator from Android Studio

## Quick Start (If Flutter is Already Installed)

```bash
cd /Users/ahazfernando/Downloads/Lunala
flutter pub get
flutter run
```




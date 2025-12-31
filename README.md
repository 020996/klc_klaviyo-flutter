# Klaviyo Flutter Plugin - Integration Guide

Complete guide for integrating the `klc_klaviyo_flutter` plugin into your Flutter application with support for push notifications on both Android and iOS platforms.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Android Setup](#android-setup)
4. [iOS Setup](#ios-setup)
5. [Usage](#usage)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:

- Flutter SDK installed (version 3.10.0 or higher)
- A Klaviyo account with your Public API Key (Site ID)
- For Android: Firebase project with `google-services.json`
- For iOS: Apple Developer account with APNs certificate configured in Klaviyo
- Xcode 14+ (for iOS development)

---

## Installation

Run:

```bash
flutter pub get klc_klaviyo_flutter
```

---

## Android Setup


### Step 1: Thêm JitPack Repository

Để tải được SDK Klaviyo, bạn cần thêm JitPack vào phần `repositories` trong file Gradle:

Mở file `android/build.gradle.kts` (hoặc `android/build.gradle`) và thêm dòng sau vào bên trong khối `repositories`:

```kotlin
maven { url = uri("https://jitpack.io") }
```

Ví dụ:

```kotlin
allprojects {
  repositories {
    google()
    mavenCentral()
    maven { url = uri("https://jitpack.io") } // Thêm dòng này
  }
}
```

### Step 2: Add Google Services Plugin

#### Update `settings.gradle.kts`

Open `android/settings.gradle.kts` và add the Google Services plugin at the top:

```kotlin
pluginManagement {
  repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
  }
}

plugins {
  id("com.google.gms.google-services") version "4.4.2" apply false
}

// ... rest of the file
```

#### Update `build.gradle.kts`

Open `android/app/build.gradle.kts` và apply the Google Services plugin at the bottom:

```kotlin
plugins {
  id("com.google.gms.google-services")  // Add this line
}
```

Open `android/app/settings.gradle.kts` và apply the Google Services plugin at the bottom:

```kotlin
plugins {
  id("com.google.gms.google-services") version "4.4.2" apply false   // Add this line
}
```

### Step 2: Add Firebase Configuration File

1. Download `google-services.json` from your Firebase Console
2. Place the file in `android/app/` directory

```
android/
  └── app/
      ├── build.gradle.kts
      └── google-services.json  ← Place here
```

## iOS Setup

### Step 1: Enable Push Notifications Capability

1. Open your iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select **Runner** target in the left sidebar

3. Go to **Signing & Capabilities** tab

4. Click **+ Capability** button

5. Select **Push Notifications**

### Step 2: Create Notification Service Extension

This extension is required for **Rich Push Notifications** (images, videos).

#### 2.1 Create the Extension Target

1. In Xcode: **File** → **New** → **Target**

2. Select **Notification Service Extension**

3. Configure:
   - **Product Name**: `KlaviyoNotificationServiceExtension`
   - **Language**: Swift
   - **Project**: Runner
   - Click **Finish**

4. When prompted "Activate scheme?", click **Cancel**

#### 2.2 Set Deployment Target

1. Select **KlaviyoNotificationServiceExtension** target

2. Go to **Build Settings** tab

3. Search for **"iOS Deployment Target"**

4. Set to **13.0** (or match your app's deployment target)

#### 2.3 Add KlaviyoSwiftExtension Dependency

Open `ios/Podfile` and add the extension target:

```ruby
# ... existing code

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

# Add this section
target 'KlaviyoNotificationServiceExtension' do
  use_frameworks!
  pod 'KlaviyoSwiftExtension', '~> 5.1.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### 2.4 Update NotificationService.swift

Replace the content of `ios/KlaviyoNotificationServiceExtension/NotificationService.swift`:

```swift
import KlaviyoSwiftExtension
import UserNotifications
import os.log

/// Klaviyo Notification Service Extension
/// Uses official KlaviyoSwiftExtension SDK to handle rich push (images, videos) and badge counts.
class NotificationService: UNNotificationServiceExtension {
    
    private let logger = OSLog(subsystem: "com.abcsoft.sid96604127520.KlaviyoNotificationServiceExtension", category: "RichPush")
    
    var request: UNNotificationRequest!
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.request = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo
        
        if let bestAttemptContent = bestAttemptContent {
            KlaviyoExtensionSDK.handleNotificationServiceDidReceivedRequest(
                request: self.request,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
        } else {
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            KlaviyoExtensionSDK.handleNotificationServiceExtensionTimeWillExpireRequest(
                request: request,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
        }
    }
}
```

### Step 3: Setup App Groups

App Groups allow the extension to share data with your main app.

#### 3.1 Main App Target

1. Select **Runner** target

2. Go to **Signing & Capabilities**

3. Click **+ Capability** → **App Groups**

4. Click **+** button to create a new App Group

5. Enter: `group.com.yourcompany.yourapp.klaviyo`
   - Replace `yourcompany` and `yourapp` with your actual values
   - Example: `group.com.example.myshop.klaviyo`

6. Check the checkbox to enable it

#### 3.2 Extension Target

1. Select **KlaviyoNotificationServiceExtension** target

2. Go to **Signing & Capabilities**

3. Click **+ Capability** → **App Groups**

4. Select the **same App Group** you created for the main app

### Step 4: Add klaviyo_app_group to Info.plist

#### 4.1 Main App (Runner/Info.plist)

Add this key to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- ... existing keys ... -->

    <key>klaviyo_app_group</key>
    <string>group.com.yourcompany.yourapp.klaviyo</string>
</dict>
```

#### 4.2 Extension (KlaviyoNotificationServiceExtension/Info.plist)

Add the same key to `ios/KlaviyoNotificationServiceExtension/Info.plist`:

```xml
<dict>
    <!-- ... existing keys ... -->

    <key>klaviyo_app_group</key>
    <string>group.com.yourcompany.yourapp.klaviyo</string>
</dict>
```

### Step 5: Install Pods

Run pod install:

```bash
cd ios
pod install
cd ..
```

### Step 6: Fix Build Phase Ordering (If Needed)

If you encounter a build error about circular dependencies:

1. In Xcode, select **Runner** target

2. Go to **Build Phases** tab

3. Find **"Embed Foundation Extensions"** phase

4. **Drag it above** the **"Thin Binary"** phase

5. The correct order should be:
   ```
   - Dependencies
   - Compile Sources
   - Link Binary With Libraries
   - Embed Foundation Extensions  ← Move here
   - Thin Binary
   - [CP] Embed Pods Frameworks
   - Run Script (Flutter Build)
   ```

### iOS Setup Complete!

Run your app to verify:

```bash
flutter run -d ios
```

---

## Usage

### Initialize Klaviyo SDK

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:klc_klaviyo_flutter/klc_klaviyo_flutter.dart';
import 'package:klc_klaviyo_flutter/models/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for Android)
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Not initialized';
  String? _pushToken;
  String? _email;

  @override
  void initState() {
    super.initState();
    _setupKlaviyo();
  }

  Future<void> _setupKlaviyo() async {
    // Setup push token callback
    KlcKlaviyoFlutter.ic.onPushTokenReceived = (token) {
      setState(() => _pushToken = token);
      debugPrint('✅ Push token received: $token');
    };

    // Setup notification tap callback
    KlcKlaviyoFlutter.ic.onNotificationTapped = (payload) {
      debugPrint('👆 Notification tapped: $payload');
      // Handle notification tap
    };

    try {
      // Initialize with your Klaviyo Public API Key
      await KlcKlaviyoFlutter.ic.initialize('YOUR_KLAVIYO_PUBLIC_API_KEY');

      // Request push notification permission
      await KlcKlaviyoFlutter.ic.requestPushPermission();

      setState(() => _status = 'Initialized ✅');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _setProfile() async {
    await KlcKlaviyoFlutter.ic.setProfile(
      KlaviyoProfile(
        email: 'user@example.com',
        firstName: 'John',
        lastName: 'Doe',
        properties: {'plan': 'premium'},
      ),
    );

    final email = await KlcKlaviyoFlutter.ic.getEmail();
    setState(() => _email = email);
  }

  Future<void> _trackEvent() async {
    await KlcKlaviyoFlutter.ic.createEvent(
      KlaviyoEvent(
        name: 'Added to Cart',
        properties: {
          'product_id': '123',
          'product_name': 'Widget',
          'price': 29.99
        },
        value: 29.99,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Klaviyo Integration')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Status: $_status'),
              Text('Email: ${_email ?? "Not set"}'),
              Text('Token: ${_pushToken?.substring(0, 20) ?? "None"}...'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setProfile,
                child: const Text('Set Profile'),
              ),
              ElevatedButton(
                onPressed: _trackEvent,
                child: const Text('Track Event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await KlcKlaviyoFlutter.ic.resetProfile();
                  setState(() => _email = null);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### API Methods

| Method | Description |
|--------|-------------|
| `initialize(apiKey)` | Initialize SDK with your Klaviyo Public API Key |
| `setProfile(profile)` | Set user profile information |
| `setEmail(email)` | Set user email address |
| `setPhoneNumber(phone)` | Set user phone number (E.164 format) |
| `setExternalId(id)` | Set external user ID |
| `resetProfile()` | Reset profile (call on logout) |
| `getEmail()` | Get current user email |
| `getPhoneNumber()` | Get current user phone |
| `getExternalId()` | Get current external ID |
| `createEvent(event)` | Track custom event |
| `requestPushPermission()` | Request push notification permission |
| `getPushPermissionStatus()` | Get current permission status |
| `getPushToken()` | Get current push token |
| `setPushToken(token)` | Set push token manually |
| `registerForInAppForms()` | Enable in-app forms |
| `unregisterFromInAppForms()` | Disable in-app forms |

---

## Troubleshooting

### Android Issues

#### Push Notifications Not Working

1. Verify `google-services.json` is in `android/app/` directory
2. Check that Firebase is initialized in your app
3. Verify the plugin is applied in `build.gradle.kts`:
   ```kotlin
   id("com.google.gms.google-services")
   ```
4. Check Logcat for error messages

#### Build Errors

If you see errors about Google Services:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS Issues

#### Push Token Not Received

1. **Simulator Limitation**: Push notifications don't work on iOS Simulator. Always test on a real device.

2. Check Push Notifications capability is enabled:
   - Xcode → Runner → Signing & Capabilities → Push Notifications

3. Verify provisioning profile includes push notifications

4. Check console logs for errors

#### Rich Push Images Not Showing

1. **App must be in background** when receiving the notification

2. Verify App Groups are configured for both targets:
   - Runner target → Signing & Capabilities → App Groups
   - Extension target → Signing & Capabilities → App Groups
   - Both must have the same group ID

3. Check `klaviyo_app_group` is in both Info.plist files

4. Verify extension deployment target ≤ app deployment target

#### Build Phase Circular Dependency Error

Error: `Cycle inside Runner; building could produce unreliable results`

**Solution**:
1. Xcode → Runner target → Build Phases
2. Drag "Embed Foundation Extensions" **above** "Thin Binary"
3. Clean build folder: **Product** → **Clean Build Folder** (Shift + Cmd + K)
4. Rebuild

#### Extension Deployment Target Error

Error: `The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to...`

**Solution**:
1. Select **KlaviyoNotificationServiceExtension** target
2. Build Settings → Search "iOS Deployment Target"
3. Set to **13.0** or match your app's target

#### Pod Install Issues

If pod install fails:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### General Issues

#### API Key Invalid

Make sure you're using the **Public API Key** (Site ID), not the Private API Key:
- Find it in Klaviyo dashboard: **Settings** → **API Keys** → **Public API Key**

#### Events Not Showing in Klaviyo

1. Check that you initialized the SDK before tracking events
2. Verify you set a user profile (email or external ID)
3. Events may take a few minutes to appear in Klaviyo dashboard
4. Check the **Metrics** section in your Klaviyo account

---

## Resources

- [Klaviyo Developer Docs](https://developers.klaviyo.com/)
- [Klaviyo iOS SDK](https://github.com/klaviyo/klaviyo-swift-sdk)
- [Klaviyo Android SDK](https://github.com/klaviyo/klaviyo-android-sdk)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)

---

## Support

If you encounter issues:

1. Check this README's troubleshooting section
2. Review the example app implementation
3. Check Klaviyo's official documentation
4. Report bugs on the plugin's GitHub repository

---

**Last Updated**: December 2025

# Firebase Setup Guide

This guide will help you set up Firebase for your Flutter application and connect it to your MERN stack inventory system.

## Prerequisites

1. A Firebase account (sign up at https://firebase.google.com/)
2. Flutter SDK installed
3. Firebase CLI installed (optional, but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "Keells App")
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

## Step 2: Add Firebase to Your Flutter App

### For Android:

1. In Firebase Console, click the Android icon to add an Android app
2. Register your app:
   - **Package name**: `com.example.keells_app` (check your `android/app/build.gradle.kts` for the actual package name)
   - **App nickname**: Keells App (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Download `google-services.json`
4. Place `google-services.json` in `android/app/` directory
5. Update `android/build.gradle.kts`:
   ```kotlin
   buildscript {
       dependencies {
           classpath("com.google.gms:google-services:4.4.0")
       }
   }
   ```
6. Update `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services") // Add this line
   }
   ```

### For iOS:

1. In Firebase Console, click the iOS icon to add an iOS app
2. Register your app:
   - **Bundle ID**: Check your `ios/Runner.xcodeproj` for the bundle ID
   - **App nickname**: Keells App (optional)
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into the `Runner` folder in Xcode
6. Make sure "Copy items if needed" is checked

### For Web (if needed):

1. In Firebase Console, click the Web icon to add a Web app
2. Register your app with a nickname
3. Copy the Firebase configuration object
4. Create `lib/firebase_options.dart` (see below)

## Step 3: Install FlutterFire CLI (Recommended)

```bash
dart pub global activate flutterfire_cli
```

Then run:
```bash
flutterfire configure
```

This will automatically:
- Detect your Firebase projects
- Configure your app for all platforms
- Generate `lib/firebase_options.dart`

## Step 4: Update main.dart

The `main.dart` file has already been updated to initialize Firebase. If you used FlutterFire CLI, update it to:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Add this if using FlutterFire CLI
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Add this if using FlutterFire CLI
  );
  runApp(const KeellsApp());
}
```

## Step 5: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development) or **Start in production mode** (with security rules)
4. Select a location for your database (choose the closest to your users)
5. Click "Enable"

### Firestore Security Rules (Development)

For development, you can use these rules (update later for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents (for development only)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Firestore Security Rules (Production - Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products - read for all, write for admins only
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Orders - users can only access their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
                           resource.data.userId == request.auth.uid;
    }
    
    // Carts - users can only access their own cart
    match /carts/{userId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == userId;
    }
    
    // Inventory - read for all, write for admins only
    match /inventory/{inventoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Categories - read for all, write for admins only
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users - users can read/write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 6: Set Up Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Phone** authentication (for your current login flow)
4. Optionally enable **Email/Password** or other providers

### Phone Authentication Setup

1. Enable Phone provider in Authentication > Sign-in method
2. For testing, add test phone numbers in the "Phone numbers for testing" section
3. For production, you'll need to configure your app's SHA-1/SHA-256 certificates

## Step 7: Firestore Database Structure

Here's the recommended structure for your Firestore database:

### Collections:

1. **products**
   ```
   products/{productId}
     - name: string
     - description: string
     - price: number
     - imageUrl: string
     - category: string
     - stock: number
     - isAvailable: boolean
     - metadata: map (optional)
     - createdAt: timestamp
     - updatedAt: timestamp
   ```

2. **inventory**
   ```
   inventory/{productId}
     - productId: string (reference to products)
     - stock: number
     - reserved: number
     - lowStockThreshold: number
     - updatedAt: timestamp
   ```

3. **orders**
   ```
   orders/{orderId}
     - userId: string
     - items: array
       - productId: string
       - productName: string
       - quantity: number
       - price: number
     - totalAmount: number
     - status: string (pending, confirmed, processing, shipped, delivered, cancelled)
     - deliveryAddress: string
     - scheduledDate: timestamp (optional)
     - note: string (optional)
     - createdAt: timestamp
     - updatedAt: timestamp
   ```

4. **carts**
   ```
   carts/{userId}
     - userId: string
     - items: array
       - productId: string
       - quantity: number
       - addedAt: timestamp
     - createdAt: timestamp
     - updatedAt: timestamp
   ```

5. **categories**
   ```
   categories/{categoryId}
     - name: string
     - imageUrl: string (optional)
     - description: string (optional)
     - createdAt: timestamp
   ```

6. **users**
   ```
   users/{userId}
     - phoneNumber: string
     - name: string (optional)
     - email: string (optional)
     - address: map (optional)
     - role: string (user, admin)
     - createdAt: timestamp
     - updatedAt: timestamp
   ```

## Step 8: Connect to Your MERN Stack Backend

Your MERN stack backend can interact with Firebase using the Firebase Admin SDK:

### Node.js Example:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Example: Get all products
async function getProducts() {
  const snapshot = await db.collection('products').get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

// Example: Update inventory
async function updateInventory(productId, newStock) {
  await db.collection('inventory').doc(productId).update({
    stock: newStock,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
}
```

### Getting Service Account Key:

1. In Firebase Console, go to **Project Settings**
2. Go to **Service Accounts** tab
3. Click "Generate new private key"
4. Download the JSON file and keep it secure (add to `.gitignore`)

## Step 9: Install Dependencies

Run the following command to install the Firebase packages:

```bash
flutter pub get
```

## Step 10: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Check Firebase Console to see if data is being written/read

## Troubleshooting

### Android Issues:

- Make sure `google-services.json` is in `android/app/`
- Ensure Google Services plugin is added to `build.gradle.kts`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

### iOS Issues:

- Make sure `GoogleService-Info.plist` is added to Xcode project
- Check that the bundle ID matches in Firebase Console and Xcode
- Clean build folder in Xcode: Product > Clean Build Folder

### General Issues:

- Check Firebase initialization in `main.dart`
- Verify internet connection
- Check Firebase Console for error logs
- Ensure Firestore is enabled in Firebase Console

## Next Steps

1. Integrate `FirebaseService` into your screens
2. Replace hardcoded data with Firestore queries
3. Implement real-time updates using Streams
4. Set up proper authentication flow
5. Connect your MERN backend to Firebase Admin SDK

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)


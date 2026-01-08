# User Profile Service - Edit Profile Implementation

## Overview

The `UserProfileService` provides a clean, production-ready way to fetch and update user profile data from Firestore `users/{userId}` collection.

## Firestore Structure

```
users/
  {userId}/  (e.g., CUST00001)
    firstName: "John"
    lastName: "Doe"
    email: "john.doe@example.com"
    phoneNumber: "+94771234567"
    createdAt: Timestamp
    updatedAt: Timestamp
```

## Features

✅ Gets the currently logged-in user's ID (customer ID)  
✅ Fetches user profile from `users/{userId}` collection  
✅ Updates `firstName`, `lastName`, `email`, and `phoneNumber`  
✅ Handles loading, error, and empty states  
✅ Provides both Future and Stream approaches  
✅ Clean architecture with separation of concerns  

## Usage

### 1. Import the Service

```dart
import '../services/user_profile_service.dart';
```

### 2. Initialize the Service

```dart
final UserProfileService _profileService = UserProfileService();
```

### 3. Get User Profile (Future)

```dart
Future<void> loadProfile() async {
  final profileData = await _profileService.getUserProfile();
  
  if (profileData != null) {
    final firstName = profileData['firstName'] as String? ?? '';
    final lastName = profileData['lastName'] as String? ?? '';
    final email = profileData['email'] as String? ?? '';
    final phoneNumber = profileData['phoneNumber']?.toString() ?? '';
    
    // Populate your TextEditingControllers
    _firstNameController.text = firstName;
    _lastNameController.text = lastName;
    _emailController.text = email;
    _phoneController.text = phoneNumber;
  }
}
```

### 4. Get User Profile (Stream - Real-time Updates)

```dart
StreamBuilder<Map<String, dynamic>?>(
  stream: _profileService.getUserProfileStream(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    final profileData = snapshot.data;
    if (profileData == null) {
      return Text('No profile found');
    }
    
    // Use profileData to populate UI
    return YourProfileWidget(profileData: profileData);
  },
)
```

### 5. Update User Profile

```dart
Future<void> saveProfile() async {
  final success = await _profileService.updateUserProfile(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(), // Optional
    phoneNumber: _phoneController.text.trim(),
  );
  
  if (success) {
    // Show success message
  } else {
    // Show error message
  }
}
```

## Complete Example

### Using FutureBuilder

```dart
class EditProfileExample extends StatefulWidget {
  const EditProfileExample({super.key});

  @override
  State<EditProfileExample> createState() => _EditProfileExampleState();
}

class _EditProfileExampleState extends State<EditProfileExample> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final UserProfileService _profileService = UserProfileService();
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final profileData = await _profileService.getUserProfile();
      
      if (profileData != null && mounted) {
        _firstNameController.text = profileData['firstName'] as String? ?? '';
        _lastNameController.text = profileData['lastName'] as String? ?? '';
        _emailController.text = profileData['email'] as String? ?? '';
        _phoneController.text = profileData['phoneNumber']?.toString() ?? '';
        
        setState(() {
          _isLoadingData = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Profile not found';
          _isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _profileService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
```

## Methods

### `getCurrentUserId()`
- Returns: `Future<String?>` - User ID (e.g., "CUST00001") or null
- Gets the logged-in user's ID from memory cache or SharedPreferences

### `getUserProfile()`
- Returns: `Future<Map<String, dynamic>?>`
- Fetches user profile from `users/{userId}` collection
- Returns null if user not found or not logged in

### `getUserProfileStream()`
- Returns: `Stream<Map<String, dynamic>?>`
- Provides real-time updates when profile changes in Firestore

### `updateUserProfile()`
- Parameters:
  - `firstName` (required): String
  - `lastName` (required): String
  - `email` (optional): String?
  - `phoneNumber` (required): String
- Returns: `Future<bool>` - true if successful
- Updates user profile in Firestore `users/{userId}` collection
- Automatically sets `updatedAt` timestamp

## Error Handling

The service handles:
- ✅ User not logged in (returns null)
- ✅ Profile not found (returns null)
- ✅ Network errors (returns null with error logging)
- ✅ Invalid data (gracefully handles missing fields)

## Integration

The existing `EditProfileScreen` has been updated to use this service. It:
1. Fetches profile from `users/{userId}` on load
2. Populates TextEditingControllers with fetched data
3. Saves updates back to Firestore
4. Handles all loading/error/empty states

## Notes

- The service uses the in-memory cache from `FirebaseService` for user ID lookup
- All methods include comprehensive error logging for debugging
- The `updateUserProfile` method uses `set()` with `merge: true` to preserve existing fields
- Phone numbers are stored as provided (no automatic formatting)

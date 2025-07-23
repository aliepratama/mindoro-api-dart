# Mindoro API Dart - Supabase Authentication Integration

Example of Consumer API for Mindoro Platform with Supabase integration using Model-Repository-ViewModel pattern.

## Features

This project demonstrates how to integrate Supabase authentication in a Flutter/Dart application using a clean architecture approach with:

- **Models**: Data classes for authentication requests, responses, and user data
- **Repository**: Abstract layer for authentication operations with Supabase implementation
- **ViewModel**: State management and business logic using Riverpod
- **Examples**: Complete usage examples for registration and login

## Architecture Pattern

```
┌─────────────────┐
│   ViewModel     │  ← State Management & Business Logic
├─────────────────┤
│   Repository    │  ← Data Access Layer (Abstract + Supabase Implementation)
├─────────────────┤
│     Models      │  ← Data Transfer Objects
├─────────────────┤
│   Supabase      │  ← External Service
└─────────────────┘
```

## Setup Instructions

### 1. Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.3.4
  flutter_riverpod: ^2.4.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 2. Supabase Configuration

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the project settings
3. Update the initialization in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'your_supabase_project_url',
  anonKey: 'your_supabase_anon_key',
);
```

### 3. Authentication Setup

Enable Email authentication in your Supabase dashboard:
- Go to Authentication > Settings
- Enable Email provider
- Configure email templates as needed

## Project Structure

```
lib/
├── main.dart                     # App initialization with Supabase
├── models/
│   └── auth_models.dart         # User, AuthRequest, AuthResponse models
├── repositories/
│   └── auth_repository.dart     # Abstract repository + Supabase implementation
├── viewmodels/
│   └── auth_viewmodel.dart      # AuthViewModel with Riverpod providers
├── views/
│   ├── auth_wrapper.dart        # Main auth state router
│   ├── login_screen.dart        # Login UI with form validation
│   ├── register_screen.dart     # Registration UI with form validation
│   ├── home_screen.dart         # Authenticated user dashboard
│   └── views.dart              # View exports
└── examples/
    ├── auth_examples.dart       # Complete usage examples
    ├── simple_auth_example.dart # Standalone examples
    └── view_examples.dart       # UI demonstration app
```

## Usage Examples

### 1. Register Task with Email

```dart
// Using ViewModel approach
final authViewModel = AuthViewModel(SupabaseAuthRepository());

await authViewModel.register(
  email: 'user@example.com',
  password: 'securePassword123',
  displayName: 'John Doe', // Optional
);

// Check the result
final authState = authViewModel.state;
if (authState.status == AuthStatus.authenticated) {
  print('Registration successful!');
  print('User: ${authState.user?.email}');
}
```

### 2. Login Task with Email

```dart
// Using ViewModel approach
await authViewModel.login(
  email: 'user@example.com',
  password: 'securePassword123',
);

// Check the result
final authState = authViewModel.state;
if (authState.status == AuthStatus.authenticated) {
  print('Login successful!');
  print('User ID: ${authState.user?.id}');
}
```

### 3. Direct Repository Usage

```dart
// Using Repository directly for more control
final repository = SupabaseAuthRepository();

// Register
final registerRequest = RegisterRequest(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'User Name',
);

final registerResponse = await repository.register(registerRequest);
if (registerResponse.success) {
  print('Registration successful');
}

// Login
final loginRequest = AuthRequest(
  email: 'user@example.com',
  password: 'password123',
);

final loginResponse = await repository.login(loginRequest);
if (loginResponse.success) {
  print('Login successful');
  print('Access Token: ${loginResponse.accessToken}');
}
```

### 4. Using with Riverpod Providers

```dart
// In your Flutter widget
class AuthWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    
    return switch (authState.status) {
      AuthStatus.loading => CircularProgressIndicator(),
      AuthStatus.authenticated => Text('Welcome ${authState.user?.email}'),
      AuthStatus.unauthenticated => LoginForm(authViewModel),
      AuthStatus.error => Text('Error: ${authState.errorMessage}'),
      _ => SizedBox(),
    };
  }
}
```

## 🎨 Complete UI Implementation

The project includes a complete Flutter UI with the following screens:

### AuthWrapper
- Automatically routes users based on authentication state
- Shows splash screen during initialization
- Handles state transitions smoothly

### LoginScreen
- Email and password input with validation
- Password visibility toggle
- "Forgot Password" functionality
- Link to registration screen
- Loading states and error handling

### RegisterScreen
- Email, password, and display name inputs
- Password confirmation validation
- Form validation with user-friendly messages
- Success/error feedback
- Navigation back to login

### HomeScreen
- Welcome message with user information
- Account details display
- Code examples viewer
- Architecture information
- Profile menu with logout option

### Usage in Your App
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/auth_wrapper.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: AuthWrapper(), // This handles everything!
      ),
    ),
  );
}
```

## Available Methods

### AuthRepository

- `register(RegisterRequest)` - Register new user with email/password
- `login(AuthRequest)` - Login with email/password
- `logout()` - Sign out current user
- `getCurrentUser()` - Get current authenticated user
- `resetPassword(String email)` - Send password reset email
- `updatePassword(String newPassword)` - Update user password

### AuthViewModel

- `register({email, password, displayName})` - Register with state management
- `login({email, password})` - Login with state management
- `logout()` - Logout with state management
- `resetPassword(email)` - Password reset with state management
- `clearError()` - Clear error state

### Riverpod Providers

- `authViewModelProvider` - Main auth state provider
- `authRepositoryProvider` - Repository provider
- `currentUserProvider` - Current user convenience provider
- `isAuthenticatedProvider` - Authentication status provider
- `isLoadingProvider` - Loading state provider

## Models

### User
```dart
class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? emailConfirmedAt;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
}
```

### AuthRequest
```dart
class AuthRequest {
  final String email;
  final String password;
}
```

### RegisterRequest
```dart
class RegisterRequest extends AuthRequest {
  final String? displayName;
}
```

### AuthResponse
```dart
class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
}
```

## Running the Examples

To see the complete examples in action:

### 1. Console Examples (Repository/ViewModel only)
```dart
import 'lib/examples/auth_examples.dart';

void main() async {
  // Initialize your Supabase configuration first
  await runAuthExamples();
}
```

### 2. Simple Console Example (No dependencies)
```bash
dart run example_main.dart
```

### 3. Full Flutter UI Example
```bash
flutter run
```

### 4. UI Demo App
```dart
import 'lib/examples/view_examples.dart';

void main() {
  runApp(ViewExampleApp());
}
```

This will launch a complete demo app with:
- Interactive auth state display
- Quick register/login buttons
- Full UI flow demonstration
- Architecture documentation

## Error Handling

The implementation includes comprehensive error handling:

- Network errors
- Authentication errors (invalid credentials, etc.)
- Validation errors
- Supabase-specific errors

All errors are captured and returned as `AuthResponse.failure()` with descriptive messages.

## Best Practices

1. **Always check response success**: Check `response.success` before accessing user data
2. **Handle loading states**: Use `AuthState.loading` to show progress indicators
3. **Implement proper error handling**: Display user-friendly error messages
4. **Use providers wisely**: Leverage Riverpod providers for reactive UI updates
5. **Secure storage**: Consider using secure storage for sensitive data

## Security Considerations

- Never store passwords in plain text
- Use HTTPS for all communications
- Implement proper session management
- Consider implementing refresh token rotation
- Validate inputs on both client and server side

## Testing

The repository pattern makes testing easier:

```dart
// Create a mock repository for testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResponse> login(AuthRequest request) async {
    // Return test data
    return AuthResponse.success(user: testUser);
  }
  // ... implement other methods
}
```

## Contributing

1. Follow the established architecture pattern
2. Add comprehensive error handling
3. Include documentation for new methods
4. Write tests for new functionality
5. Update this README for any new features

## License

This project is provided as an example for educational purposes.

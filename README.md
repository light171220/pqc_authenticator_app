# PQC Authenticator App

A quantum-safe TOTP authenticator app built with Flutter.

## Features

- Cross-platform (iOS/Android) support
- Material Design 3 UI
- QR code scanning for account setup
- Offline TOTP code generation
- Secure local storage
- Go backend integration
- JWT authentication
- Account synchronization

## Setup

1. Install Flutter SDK
2. Run `flutter pub get`
3. Configure backend API endpoint in `lib/utils/constants.dart`
4. Run `flutter run`

## Backend API

Requires a Go backend with the following endpoints:
- POST /api/v1/users/register
- POST /api/v1/users/login
- GET /api/v1/accounts
- POST /api/v1/accounts
- DELETE /api/v1/accounts/{id}

## Permissions

The app requires camera permission for QR code scanning.

## Security

- Encrypted local storage for TOTP secrets
- JWT token management
- Input validation
- Secure storage for sensitive data
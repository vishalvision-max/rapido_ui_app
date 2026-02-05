# Rapido UI App

A complete Flutter mobile application UI inspired by the Rapido bike taxi app.

## Features

- ✅ **Clean UI Design** - Rapido-inspired yellow & black theme
- ✅ **Smooth Animations** - Animated splash screen, loading states, and transitions
- ✅ **Multiple Screens** - Complete user flow from login to payment
- ✅ **State Management** - GetX for efficient state management
- ✅ **Navigation** - Seamless screen transitions with GetX routing
- ✅ **Responsive Layout** - Mobile-first design approach

## Screens Included

1. **Splash Screen** - Auto-navigates to login after 3 seconds
2. **Login Screen** - Phone number input with country code
3. **OTP Screen** - 6-digit OTP verification with auto-focus
4. **Home Screen** - Map placeholder with pickup/drop location inputs
5. **Ride Selection** - Choose between bike and auto with fare estimates
6. **Searching Rider** - Animated search screen
7. **Ride Details** - Rider info, call/chat options, and trip tracking
8. **Payment Screen** - Fare breakdown and payment methods
9. **Ride History** - List of previous rides
10. **Wallet Screen** - Balance display and transaction history
11. **Profile Screen** - User profile and settings

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: GetX
- **Font**: Google Fonts (Poppins)
- **Architecture**: Clean architecture with modular structure

## Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── ride.dart
│   ├── colors.dart
│   └── assets.dart
├── modules/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   └── otp_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── home_content.dart
│   ├── ride/
│   │   ├── ride_selection_screen.dart
│   │   ├── searching_rider_screen.dart
│   │   ├── ride_details_screen.dart
│   │   └── ride_history_screen.dart
│   ├── payment/
│   │   ├── payment_screen.dart
│   │   └── wallet_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── main.dart
```

## Running the App

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```

## Important Notes

- This is a **UI-only** app with no backend integration
- All data is **dummy/static** for demonstration purposes
- No real API calls are made
- Map views use placeholder containers

## Customization

### Theme Colors
Edit `/lib/core/colors.dart` to customize the color scheme:
```dart
static const Color primaryYellow = Color(0xFFFDD835);
static const Color primaryBlack = Color(0xFF121212);
```

### Navigation
All routes are defined in `/lib/main.dart`:
```dart
getPages: [
  GetPage(name: '/', page: () => const SplashScreen()),
  // ... more routes
]
```

## Dependencies

- `get: ^4.6.6` - State management and routing
- `google_fonts: ^6.1.0` - Custom fonts (Poppins)
- `intl: ^0.19.0` - Date formatting

## License

This project is created for educational purposes.

---

**Built with ❤️ using Flutter**
# rapido_ui_app

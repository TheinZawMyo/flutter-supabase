# Flutter Supabase Authentication

A modern Flutter application with beautiful login and register screens integrated with Supabase authentication.

## Features

- 💰 **Budget Tracking**: Manage your income and expenses easily
- 📊 **Visual Analytics**: Interactive pie charts for spending category analysis
- 🎨 **Modern Dashboard**: Real-time balance, income, and expense summaries
- 🔐 **Supabase Integration**: Secure cloud storage for all your financial data
- ✨ **Smooth Animations**: High-quality transitions and glassmorphism UI
- 🔒 **Secure Auth**: Full login and registration system
- 👤 **User Profile**: Account management and member statistics
- 🎊 **Custom Alerts**: Animated snackbar system for all interactions

## Screenshots

The app features:
- Beautiful gradient backgrounds (Purple to Blue)
- Glassmorphism input fields
- Smooth fade and slide animations
- Hero animations for shared elements
- Custom page transitions between Login and Register screens

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the project settings
3. Update the `.env` file with your credentials:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Important:** Never commit your `.env` file to version control. It's already added to `.gitignore`.

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── constants/
│   └── app_colors.dart      # Color constants for the app
├── utils/
│   └── custom_snackbar.dart # Custom animated snackbar utility
├── login_page.dart           # Login screen with Supabase auth
├── register_page.dart        # Register screen with Supabase auth
├── home_page.dart            # Home/Dashboard screen
├── profile_page.dart         # User profile screen
└── main.dart                 # App entry point with Supabase initialization
```

## Key Components

### AppColors
Centralized color management for consistent theming:
- Gradient colors (Purple to Blue)
- Text colors (Primary and Secondary)
- Input field backgrounds
- Button colors

### Authentication Flow

**Login:**
- Email and password validation
- Supabase `signInWithPassword`
- Custom animated snackbar for success/error messages
- Loading state during authentication
- Automatic navigation to home page on success

**Register:**
- Email and password fields with confirmation
- Password matching validation
- Supabase `signUp`
- Email confirmation flow
- Custom animated snackbar alerts
- Automatic navigation back to login after successful registration

### Custom Snackbar

Beautiful animated notification system with 4 types:
- **Success** (Green): Login success, registration complete
- **Error** (Red): Authentication errors, validation failures
- **Warning** (Orange): Missing fields, incomplete forms
- **Info** (Blue): General information messages

Features:
- Slide-in animation from top
- Auto-dismiss after 3 seconds
- Manual close button
- Icon indicators for each type
- Smooth fade and slide animations
- Glassmorphism design with shadows

### Home Page

After successful login, users are redirected to a beautiful dashboard featuring:
- Gradient header with user email
- Welcome message
- User profile avatar (clickable)
- Feature cards (Profile, Settings, Notifications, Analytics)
- Smooth animations and transitions
- Modern card-based layout

### Profile Page

Accessible by clicking the user avatar in the home page header:
- Large circular avatar with user initials
- User email display
- Account creation date
- User information cards:
  - Email address
  - User ID
  - Account creation date
- Logout button
- Smooth animations and transitions
- Back navigation to home page

## Dependencies

- `flutter_dotenv: ^6.0.0` - Environment variable management
- `supabase_flutter: ^2.12.0` - Supabase client for Flutter

## Environment Variables

The app uses environment variables to securely store Supabase credentials:

- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anonymous key

## Security Notes

- The `.env` file is excluded from version control
- Never share your Supabase credentials publicly
- Use Supabase Row Level Security (RLS) policies for data protection

## Next Steps

After successful authentication, you can:
1. Create a home/dashboard screen
2. Add user profile management
3. Implement password reset functionality
4. Add social authentication (Google, Facebook)
5. Create protected routes

## Troubleshooting

**Issue: "Unable to load asset: .env"**
- Make sure the `.env` file exists in the project root
- Verify `assets` is configured in `pubspec.yaml`
- Run `flutter clean` and `flutter pub get`

**Issue: Authentication errors**
- Verify your Supabase credentials are correct
- Check if email confirmation is required in Supabase settings
- Ensure your Supabase project is active

## License

This project is open source and available under the MIT License.

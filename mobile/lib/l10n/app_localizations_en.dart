// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Outside';

  @override
  String get welcomeTagline => 'A social network for expats near you';

  @override
  String get createAccount => 'Create account';

  @override
  String get login => 'Log in';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordConfirmLabel => 'Confirm password';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'letters and _, 3+ characters';

  @override
  String get usernameChecking => 'checking…';

  @override
  String get usernameAvailable => 'available';

  @override
  String get usernameTaken => 'taken';

  @override
  String get errorEmailInvalid => 'Enter a valid email';

  @override
  String get errorEmailTaken => 'This email is already registered.';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get errorPasswordMismatch => 'Passwords don\'t match';

  @override
  String get errorUsernameInvalid =>
      'Only latin letters and _, 3 to 30 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get verifyEmailTitle => 'Confirm your email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'We sent a code to $email';
  }

  @override
  String errorCodeWrong(int count) {
    return 'Wrong code, attempts left: $count';
  }

  @override
  String get errorCodeExpired => 'Code expired or invalid';

  @override
  String get errorCodeLocked => 'Too many attempts. Request a new code';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeTimer(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get onboardingStep1Title => 'What\'s your name?';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get next => 'Next';

  @override
  String get onboardingStep2Title => 'Where are you from?';

  @override
  String get onboardingStep2Subtitle =>
      'Pick your compatriots or who you\'d like to meet';

  @override
  String get searchCountry => 'Search country';

  @override
  String get otherCountry => 'Other country…';

  @override
  String get onboardingStep3Title => 'Where are you now?';

  @override
  String get done => 'Done';

  @override
  String get loginTitle => 'Log in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccountCreate => 'No account? Create one';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String errorTryLater(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s';
  }

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get sendCode => 'Send code';

  @override
  String get codeSentNotice => 'If that email is registered, we sent a code';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get saveAndLogin => 'Save and log in';

  @override
  String get blockedTitle => 'Your account is blocked';

  @override
  String get blockedReasonLabel => 'Reason:';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get logout => 'Log out';

  @override
  String get avatarUploadFailed =>
      'Couldn\'t upload the photo — you can add it later in your profile';

  @override
  String get homeWelcomeTitle => 'Welcome to Outside!';

  @override
  String get genericError => 'Something went wrong. Please try again';

  @override
  String get noConnection => 'No connection';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';
}

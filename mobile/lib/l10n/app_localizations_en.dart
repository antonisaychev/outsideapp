// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'outside';

  @override
  String get welcomeTagline => 'Your people, in any country';

  @override
  String get createAccount => 'Create account';

  @override
  String get login => 'Log in';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get registerTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordHint => 'Password (min. 8 characters)';

  @override
  String get passwordConfirmHint => 'Confirm password';

  @override
  String get usernameHint => '@username';

  @override
  String get usernameHelper =>
      'Your username is your profile link. Latin letters and _, up to 30 characters';

  @override
  String get legalNotice =>
      'By creating an account you accept the Terms of Service and Privacy Policy';

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
    return 'We sent a 6-digit code to $email. Enter it to finish signing up';
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
  String resendCodeTimer(String time) {
    return 'Resend code in $time';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String onboardingStepLabel(int step) {
    return 'Step $step of 3';
  }

  @override
  String get onboardingStep1Title => 'What\'s your name?';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get genderLabel => 'Gender';

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
  String get citiesFootnote => 'More cities coming soon';

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
  String get forgotPasswordTitle => 'Forgot password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email — we\'ll send a 6-digit reset code';

  @override
  String get sendCode => 'Send code';

  @override
  String get backToLogin => '‹ Back to log in';

  @override
  String get codeSentNotice => 'If that email is registered, we sent a code';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordHint => 'New password (min. 8 characters)';

  @override
  String get saveAndLogin => 'Save and log in';

  @override
  String get blockedTitle => 'Account blocked';

  @override
  String blockedReasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get blockedSubtitle =>
      'If you believe this is a mistake — write to us and we\'ll sort it out';

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

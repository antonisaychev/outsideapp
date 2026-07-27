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
  String get errorPasswordLatin => 'Latin letters, digits and symbols only';

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
  String get tabDating => 'Dating';

  @override
  String get tabServices => 'Services';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabFriends => 'Friends';

  @override
  String get tabProfile => 'Profile';

  @override
  String get comingSoonSection =>
      'This section is coming in the next iteration';

  @override
  String get servicesTitle => 'Services';

  @override
  String get servicesTabRecommended => 'Recommended';

  @override
  String get servicesTabPending => 'In review';

  @override
  String get categoryAll => 'All';

  @override
  String get placeSheetTitle => 'Place';

  @override
  String get servicesEmptyPending =>
      'No services in review yet. Be the first to add one!';

  @override
  String get servicesEmptyRecommended => 'No recommended services yet';

  @override
  String get addServiceAction => 'Add a service';

  @override
  String authGateTitle(String action) {
    return 'Log in to $action';
  }

  @override
  String get authGateSubtitle =>
      'It takes less than a minute. After logging in the action will complete automatically';

  @override
  String get authGateActionFavorite => 'save to favorites';

  @override
  String get authGateActionLike => 'recommend a service';

  @override
  String get authGateActionAdd => 'add a service';

  @override
  String recommendCount(int count) {
    return '$count recommend';
  }

  @override
  String get recommendButton => '👍 Recommend';

  @override
  String get youRecommend => '✓ You recommend';

  @override
  String confirmButton(int count, int threshold) {
    return 'Confirm ($count/$threshold)';
  }

  @override
  String get confirmedByLocals => 'Confirmed by locals of the service\'s city';

  @override
  String get yourServiceBadge => 'Added by you';

  @override
  String get siteButton => 'Website';

  @override
  String get mapButton => 'On the map';

  @override
  String addedBy(String name) {
    return 'Added by $name';
  }

  @override
  String get reportSheetTitle => 'Report';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonFraud => 'Fraud';

  @override
  String get reportReasonAbuse => 'Abuse';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportCommentHint => 'Comment (optional)';

  @override
  String get reportCommentRequired =>
      'For \"Other\" please describe the problem';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSent => 'Report sent. We\'ll review it and take action.';

  @override
  String get addServiceTitle => 'New recommendation';

  @override
  String get addServiceSubtitle =>
      'Recommend organizations and services, not individuals';

  @override
  String get photosCaption =>
      '1 to 5 photos. First one is the cover; long-press to change';

  @override
  String get coverBadge => 'Cover';

  @override
  String get makeCover => 'Make cover';

  @override
  String get deletePhoto => 'Delete';

  @override
  String get serviceNameHint => 'Service name';

  @override
  String get serviceDescriptionHint => 'Description';

  @override
  String get serviceWebsiteHint => 'Website link (optional)';

  @override
  String get serviceMapHint => 'Map link (optional)';

  @override
  String get categoryChip => 'Category';

  @override
  String placeChipPrefix(String city) {
    return 'Place: $city';
  }

  @override
  String get submitForReview => 'Submit for review';

  @override
  String get sentForReview => 'Submitted for review';

  @override
  String get categorySheetTitle => 'Category';

  @override
  String get duplicateSheetTitle => 'Possibly already added';

  @override
  String get addAnyway => 'Add anyway';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyHint => 'Save services with the heart on a card';

  @override
  String get toServices => 'To services';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get genericError => 'Something went wrong. Please try again';

  @override
  String get noConnection => 'No connection';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';
}

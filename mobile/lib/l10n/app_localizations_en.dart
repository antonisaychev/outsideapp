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
      'Pick the country you came from — that’s how fellow expats find you';

  @override
  String get searchCountry => 'Search country';

  @override
  String get otherCountry => 'Other country…';

  @override
  String get onboardingStep3Title => 'Where are you now?';

  @override
  String get citiesFootnote => 'More places coming soon';

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
      'Think this is a mistake? Write to us and we’ll sort it out';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get logout => 'Log out';

  @override
  String get avatarUploadFailed =>
      'Couldn’t upload the photo. Please try again';

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
  String get recommendButton => 'Recommend';

  @override
  String get youRecommend => 'You recommend this';

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
  String get reportSent => 'Report sent — we’ll look into it';

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
  String get deletePhoto => 'Delete photo';

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
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String notifFriendRequest(String name) {
    return '$name sent you a friend request';
  }

  @override
  String notifFriendAccepted(String name) {
    return '$name accepted your request — you’re friends now';
  }

  @override
  String notifMatch(String name) {
    return 'You and $name are interested in each other — you’re friends now';
  }

  @override
  String notifServiceRecommended(String title) {
    return 'Your listing “$title” has passed review 🎉';
  }

  @override
  String notifServiceHidden(String title) {
    return 'Your card “$title” was hidden by an admin';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get nowFriends => 'You are now friends';

  @override
  String get requestDeclined => 'Request declined';

  @override
  String get guestDatingTitle => 'Log in to meet people';

  @override
  String get datingEnableTitle => 'Meet people nearby';

  @override
  String get datingEnableBody =>
      'Turn it on and we’ll show you to other expats nearby. You can switch it off anytime';

  @override
  String get datingEnableButton => 'Enable dating';

  @override
  String get datingProfileIncompleteTitle => 'Complete your profile';

  @override
  String get datingProfileIncompleteBody =>
      'Dating requires a name, photo, gender and date of birth';

  @override
  String get datingIncompleteBanner =>
      'Add a photo, gender and date of birth — otherwise others won’t see you';

  @override
  String get datingIncompleteAction => 'Fill in';

  @override
  String get deckEmpty => 'You’ve seen everyone nearby. Check back later';

  @override
  String get likeLimitReached => 'You’re out of likes for today';

  @override
  String get matchTitle => 'It\'s a match! 🎉';

  @override
  String matchSubtitle(String name) {
    return 'You and $name are interested in each other';
  }

  @override
  String get matchWriteMessage => 'Send a message';

  @override
  String get matchLater => 'Later';

  @override
  String get datingSettingsTitle => 'Dating settings';

  @override
  String get datingParticipate => 'Show me in Dating';

  @override
  String get datingParticipateHint =>
      'Others see your profile in this section. Turn it off to hide';

  @override
  String get lookingForLabel => 'Looking for';

  @override
  String get lookingForAny => 'Anything';

  @override
  String get lookingForFriends => 'Friends';

  @override
  String get lookingForDating => 'Dating';

  @override
  String get lookingForNetworking => 'Networking';

  @override
  String get showGenderLabel => 'Show me';

  @override
  String get showGenderAny => 'Everyone';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get deleteMessage => 'Delete message';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty =>
      'Your chats will appear here. You can message friends';

  @override
  String get toFriends => 'To friends';

  @override
  String get messageHint => 'Message';

  @override
  String get cannotMessageUser => 'You can only message friends';

  @override
  String get guestMessagesTitle => 'Log in to message your friends';

  @override
  String get friendsTabMy => 'My friends';

  @override
  String get friendsTabIncoming => 'Incoming';

  @override
  String get friendsTabOutgoing => 'Outgoing';

  @override
  String get friendsEmpty => 'No friends yet';

  @override
  String get findPeople => 'Find people';

  @override
  String get incomingEmpty => 'No incoming requests';

  @override
  String get outgoingEmpty => 'No outgoing requests';

  @override
  String get wantsToBeFriends => 'wants to add you as a friend';

  @override
  String get acceptRequest => 'Accept';

  @override
  String get declineRequest => 'Decline';

  @override
  String get cancelRequest => 'Cancel';

  @override
  String get cancelRequestTitle => 'Cancel the request?';

  @override
  String get requestSent => 'Request sent';

  @override
  String get addFriend => 'Add friend';

  @override
  String get alreadyFriends => 'You’re friends';

  @override
  String get writeMessage => 'Send a message';

  @override
  String get removeFriend => 'Remove from friends';

  @override
  String removeFriendTitle(String name) {
    return 'Remove $name from friends?';
  }

  @override
  String get removeFriendWarning =>
      'The chat will become unavailable; adding again requires a new request';

  @override
  String get removeFriendConfirm => 'Remove';

  @override
  String get blockUser => 'Block';

  @override
  String blockUserTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get unblockUser => 'Unblock';

  @override
  String unblockConfirmTitle(String name) {
    return 'Unblock $name?';
  }

  @override
  String get blockedListEmpty => 'The list is empty';

  @override
  String get peopleSearchTitle => 'Find people';

  @override
  String get peopleSearchHint => 'First or last name';

  @override
  String get compatriots => 'Compatriots';

  @override
  String allInCity(String city) {
    return 'Everyone here';
  }

  @override
  String get nobodyFound => 'Nobody found';

  @override
  String get authGateActionAddFriend => 'add as a friend';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get countFriends => 'Friends';

  @override
  String get countRecommendations => 'Recommendations';

  @override
  String get guestProfileTitle => 'Log in to create a profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionProfile => 'Profile';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionDating => 'Dating';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionAdmin => 'Admin';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPasswordHint => 'Current password';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get languageTitle => 'Language';

  @override
  String get blockedUsersTitle => 'Blocked users';

  @override
  String get blockedScreenTitle => 'Blocked';

  @override
  String get adminTitle => 'Administration';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarning =>
      'Your profile will be deleted and your service cards hidden. This can’t be undone';

  @override
  String get deleteAccountContinue => 'Continue';

  @override
  String get deleteAccountPasswordTitle => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirm => 'Delete forever';

  @override
  String get photosLabel => 'Photos';

  @override
  String get photosHint =>
      'Up to 10 photos. The first one appears in Dating and next to your name';

  @override
  String get photosLimitReached => 'You can’t add more than 10 photos';

  @override
  String get makeMainPhoto => 'Set as main';

  @override
  String get mainPhotoBadge => 'Main';

  @override
  String get bioHint => 'About me';

  @override
  String get placeLabel => 'Place';

  @override
  String get countryLabel => 'Country';

  @override
  String get birthDateLabel => 'Date of birth';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get unsavedChangesTitle => 'Leave without saving?';

  @override
  String get leaveWithoutSaving => 'Leave';

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

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminTabServices => 'Services';

  @override
  String get adminTabReports => 'Reports';

  @override
  String get adminTabCategories => 'Categories';

  @override
  String get adminSearchUsersHint => 'Email or name';

  @override
  String get adminBlock => 'Block';

  @override
  String get adminUnblock => 'Unblock';

  @override
  String get adminBlockedLabel => 'blocked';

  @override
  String get adminBlockTitle => 'Block this user?';

  @override
  String get adminBlockReasonHint => 'Reason (required)';

  @override
  String get adminBlockNote =>
      'The reason will be shown to the user on the blocked screen. All their services will be hidden.';

  @override
  String get adminUserBlocked => 'User blocked';

  @override
  String get adminUserUnblocked => 'User unblocked';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminFilterPending => 'Pending';

  @override
  String get adminFilterRecommended => 'Recommended';

  @override
  String get adminFilterHidden => 'Hidden';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminHide => 'Hide';

  @override
  String get adminServiceApproved => 'Service approved';

  @override
  String get adminServiceHidden => 'Service hidden';

  @override
  String get adminEditServiceTitle => 'Edit service';

  @override
  String get adminEditServiceNote => 'Admin mode · changes apply immediately';

  @override
  String get adminSaveChanges => 'Save changes';

  @override
  String adminReportOnService(String title) {
    return 'About “$title”';
  }

  @override
  String adminReportOnUser(String name) {
    return 'About $name';
  }

  @override
  String adminReportFrom(String name) {
    return '— $name';
  }

  @override
  String get adminTakeAction => 'Take action';

  @override
  String get adminActionOpen => 'Open';

  @override
  String get adminActionHideService => 'Hide service';

  @override
  String get adminActionBlockUser => 'Block author';

  @override
  String get adminActionResolve => 'Mark as resolved';

  @override
  String get adminReportResolved => 'Report resolved';

  @override
  String get adminNewCategoryTitle => 'New category';

  @override
  String get adminCategoryNameRu => 'Name (Russian)';

  @override
  String get adminCategoryNameEn => 'Name (English)';

  @override
  String get adminCreate => 'Create';

  @override
  String get adminCategoryDeleteNote =>
      'Only categories without services can be deleted';

  @override
  String get adminCategoryInUse =>
      'This category has services — move them first';

  @override
  String get adminCategoryCreated => 'Category created';

  @override
  String get adminCategoryDeleted => 'Category deleted';

  @override
  String get adminCategoryDuplicate => 'This category already exists';

  @override
  String get adminEmptyUsers => 'Nobody found';

  @override
  String get adminEmptyServices => 'No services';

  @override
  String get adminEmptyReports => 'No open reports';

  @override
  String adminServicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '$count service',
    );
    return '$_temp0';
  }

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminShow => 'Show';

  @override
  String get adminDelete => 'Delete';

  @override
  String get adminDeleteServiceTitle => 'Delete this service for good?';

  @override
  String get adminDeleteServiceNote =>
      'The card, its photos, likes and reports will be wiped from the server. This cannot be undone';

  @override
  String get adminServiceRestored => 'Service is visible again';

  @override
  String get adminServiceDeleted => 'Service deleted';

  @override
  String get adminDeleteCategoryTitle => 'Delete this category?';

  @override
  String get adminYes => 'Yes';

  @override
  String get adminNo => 'No';

  @override
  String get adminReportCategory => 'Category';

  @override
  String get adminReportDescription => 'Details';

  @override
  String get adminReportReporter => 'Reported by';

  @override
  String get adminNotAvailable => 'n/a';

  @override
  String get userBlockedProfile =>
      'This user was blocked for violating the terms of service';

  @override
  String get serviceVerified => 'Verified service';

  @override
  String get serviceVerifiedNote =>
      'An admin has personally checked this listing';

  @override
  String get serviceAddedBy => 'Added by';

  @override
  String get serviceOwner => 'Owner';

  @override
  String get adminVerifiedToggle => 'Verified service';

  @override
  String get adminVerifiedHint =>
      'The badge is visible in the list and on the card';

  @override
  String get adminOwnerLabel => 'Owner';

  @override
  String get adminOwnerNone => 'Not set';

  @override
  String get adminOwnerPick => 'Choose owner';

  @override
  String get adminOwnerClear => 'Remove owner';

  @override
  String get online => 'online';

  @override
  String get linkOpenFailed => 'Couldn’t open the link';

  @override
  String get adminDeletedLabel => 'Deleted';

  @override
  String get adminRoleLabel => 'Admin';

  @override
  String get servicesEmptyTitle => 'Nothing here yet';

  @override
  String get errorTitle => 'Couldn’t load';

  @override
  String get errorNetworkBody => 'Check your connection and try again';

  @override
  String get friendsEmptyTitle => 'No friends yet';

  @override
  String get friendsEmptyBody =>
      'Find people you know in search or accept a request';

  @override
  String get requestsEmptyTitle => 'No requests';

  @override
  String get requestsEmptyBody => 'Incoming friend requests will appear here';

  @override
  String get chatsEmptyTitle => 'No messages yet';

  @override
  String get chatsEmptyBody =>
      'A chat appears after a match or when you write to a friend';

  @override
  String get favoritesEmptyTitle => 'No favourites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on a service card to save it here';

  @override
  String get searchEmptyTitle => 'Nobody found';

  @override
  String get searchEmptyBody => 'Check the spelling or try an @nickname';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody =>
      'Friend requests, matches and news about your listings appear here';

  @override
  String get deckEmptyTitle => 'Nobody around yet';

  @override
  String get blockedEmptyTitle => 'Nothing here';

  @override
  String get blockedEmptyBody => 'Blocked users will appear here';

  @override
  String get serviceOwnerCaption => 'Service owner';

  @override
  String get serviceAddedByLine => 'Listing added by';

  @override
  String get profileFrom => 'From';

  @override
  String profileNowIn(String place) {
    return 'Now in $place';
  }
}

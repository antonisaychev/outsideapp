import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'outside'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In ru, this message translates to:
  /// **'Свои люди в любой стране'**
  String get welcomeTagline;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @continueAsGuest.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить без регистрации'**
  String get continueAsGuest;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Пароль (мин. 8 символов)'**
  String get passwordHint;

  /// No description provided for @passwordConfirmHint.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get passwordConfirmHint;

  /// No description provided for @usernameHint.
  ///
  /// In ru, this message translates to:
  /// **'@никнейм'**
  String get usernameHint;

  /// No description provided for @usernameHelper.
  ///
  /// In ru, this message translates to:
  /// **'Никнейм — это ссылка на ваш профиль. Латинские буквы и _, до 30 символов'**
  String get usernameHelper;

  /// No description provided for @legalNotice.
  ///
  /// In ru, this message translates to:
  /// **'Создавая аккаунт, вы принимаете Условия использования и Политику конфиденциальности'**
  String get legalNotice;

  /// No description provided for @usernameChecking.
  ///
  /// In ru, this message translates to:
  /// **'проверяем…'**
  String get usernameChecking;

  /// No description provided for @usernameAvailable.
  ///
  /// In ru, this message translates to:
  /// **'свободно'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In ru, this message translates to:
  /// **'занято'**
  String get usernameTaken;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email'**
  String get errorEmailInvalid;

  /// No description provided for @errorEmailTaken.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован.'**
  String get errorEmailTaken;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не короче 8 символов'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get errorPasswordMismatch;

  /// No description provided for @errorUsernameInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Только латинские буквы и _, от 3 до 30 символов'**
  String get errorUsernameInvalid;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get alreadyHaveAccount;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите почту'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили 6-значный код на {email}. Введите его, чтобы завершить регистрацию'**
  String verifyEmailSubtitle(String email);

  /// No description provided for @errorCodeWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код, осталось попыток: {count}'**
  String errorCodeWrong(int count);

  /// No description provided for @errorCodeExpired.
  ///
  /// In ru, this message translates to:
  /// **'Код истёк или недействителен'**
  String get errorCodeExpired;

  /// No description provided for @errorCodeLocked.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Запросите новый код'**
  String get errorCodeLocked;

  /// No description provided for @resendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код повторно'**
  String get resendCode;

  /// No description provided for @resendCodeTimer.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код повторно через {time}'**
  String resendCodeTimer(String time);

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @onboardingStepLabel.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {step} из 3'**
  String onboardingStepLabel(int step);

  /// No description provided for @onboardingStep1Title.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут?'**
  String get onboardingStep1Title;

  /// No description provided for @firstNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastNameHint;

  /// No description provided for @genderLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get genderFemale;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In ru, this message translates to:
  /// **'Откуда вы?'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите ваших соотечественников или с кем хотите пообщаться'**
  String get onboardingStep2Subtitle;

  /// No description provided for @searchCountry.
  ///
  /// In ru, this message translates to:
  /// **'Поиск страны'**
  String get searchCountry;

  /// No description provided for @otherCountry.
  ///
  /// In ru, this message translates to:
  /// **'Другая страна…'**
  String get otherCountry;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In ru, this message translates to:
  /// **'Где вы находитесь?'**
  String get onboardingStep3Title;

  /// No description provided for @citiesFootnote.
  ///
  /// In ru, this message translates to:
  /// **'Скоро добавим новые города'**
  String get citiesFootnote;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @noAccountCreate.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Создать'**
  String get noAccountCreate;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get errorInvalidCredentials;

  /// No description provided for @errorTryLater.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Попробуйте через {seconds} с'**
  String errorTryLater(int seconds);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите email — пришлём 6-значный код для сброса пароля'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код'**
  String get sendCode;

  /// No description provided for @backToLogin.
  ///
  /// In ru, this message translates to:
  /// **'‹ Вернуться ко входу'**
  String get backToLogin;

  /// No description provided for @codeSentNotice.
  ///
  /// In ru, this message translates to:
  /// **'Если такой email зарегистрирован, мы отправили код'**
  String get codeSentNotice;

  /// No description provided for @newPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль (мин. 8 символов)'**
  String get newPasswordHint;

  /// No description provided for @saveAndLogin.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и войти'**
  String get saveAndLogin;

  /// No description provided for @blockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт заблокирован'**
  String get blockedTitle;

  /// No description provided for @blockedReasonLabel.
  ///
  /// In ru, this message translates to:
  /// **'Причина: {reason}'**
  String blockedReasonLabel(String reason);

  /// No description provided for @blockedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Если вы считаете это ошибкой — напишите нам, разберёмся'**
  String get blockedSubtitle;

  /// No description provided for @contactSupport.
  ///
  /// In ru, this message translates to:
  /// **'Написать в поддержку'**
  String get contactSupport;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить фото — добавите его позже в профиле'**
  String get avatarUploadFailed;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Outside!'**
  String get homeWelcomeTitle;

  /// No description provided for @genericError.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз'**
  String get genericError;

  /// No description provided for @noConnection.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения'**
  String get noConnection;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

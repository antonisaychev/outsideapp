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

  /// No description provided for @errorPasswordLatin.
  ///
  /// In ru, this message translates to:
  /// **'Только латинские буквы, цифры и символы'**
  String get errorPasswordLatin;

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
  /// **'Отметьте страну, откуда вы приехали — так вас найдут земляки'**
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
  /// **'Скоро добавим новые места'**
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
  /// **'Считаете, что это ошибка? Напишите нам — разберёмся'**
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
  /// **'Не удалось загрузить фото. Попробуйте ещё раз'**
  String get avatarUploadFailed;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Outside!'**
  String get homeWelcomeTitle;

  /// No description provided for @tabDating.
  ///
  /// In ru, this message translates to:
  /// **'Знакомства'**
  String get tabDating;

  /// No description provided for @tabServices.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get tabServices;

  /// No description provided for @tabMessages.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get tabMessages;

  /// No description provided for @tabFriends.
  ///
  /// In ru, this message translates to:
  /// **'Друзья'**
  String get tabFriends;

  /// No description provided for @tabProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get tabProfile;

  /// No description provided for @comingSoonSection.
  ///
  /// In ru, this message translates to:
  /// **'Этот раздел появится в следующей итерации'**
  String get comingSoonSection;

  /// No description provided for @servicesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get servicesTitle;

  /// No description provided for @servicesTabRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендовано'**
  String get servicesTabRecommended;

  /// No description provided for @servicesTabPending.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get servicesTabPending;

  /// No description provided for @categoryAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get categoryAll;

  /// No description provided for @placeSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get placeSheetTitle;

  /// No description provided for @servicesEmptyPending.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сервисов на проверке. Добавьте первым!'**
  String get servicesEmptyPending;

  /// No description provided for @servicesEmptyRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет рекомендованных сервисов'**
  String get servicesEmptyRecommended;

  /// No description provided for @addServiceAction.
  ///
  /// In ru, this message translates to:
  /// **'Добавить сервис'**
  String get addServiceAction;

  /// No description provided for @authGateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы {action}'**
  String authGateTitle(String action);

  /// No description provided for @authGateSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Это займёт меньше минуты. После входа действие выполнится автоматически'**
  String get authGateSubtitle;

  /// No description provided for @authGateActionFavorite.
  ///
  /// In ru, this message translates to:
  /// **'сохранить в избранное'**
  String get authGateActionFavorite;

  /// No description provided for @authGateActionLike.
  ///
  /// In ru, this message translates to:
  /// **'рекомендовать сервис'**
  String get authGateActionLike;

  /// No description provided for @authGateActionAdd.
  ///
  /// In ru, this message translates to:
  /// **'добавить сервис'**
  String get authGateActionAdd;

  /// No description provided for @recommendCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} рекомендуют'**
  String recommendCount(int count);

  /// No description provided for @recommendButton.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендую'**
  String get recommendButton;

  /// No description provided for @youRecommend.
  ///
  /// In ru, this message translates to:
  /// **'Вы рекомендуете'**
  String get youRecommend;

  /// No description provided for @confirmButton.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить ({count}/{threshold})'**
  String confirmButton(int count, int threshold);

  /// No description provided for @confirmedByLocals.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждают жители города сервиса'**
  String get confirmedByLocals;

  /// No description provided for @yourServiceBadge.
  ///
  /// In ru, this message translates to:
  /// **'Добавлен вами'**
  String get yourServiceBadge;

  /// No description provided for @siteButton.
  ///
  /// In ru, this message translates to:
  /// **'Сайт'**
  String get siteButton;

  /// No description provided for @mapButton.
  ///
  /// In ru, this message translates to:
  /// **'На карте'**
  String get mapButton;

  /// No description provided for @addedBy.
  ///
  /// In ru, this message translates to:
  /// **'Добавил(а): {name}'**
  String addedBy(String name);

  /// No description provided for @reportSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пожаловаться'**
  String get reportSheetTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In ru, this message translates to:
  /// **'Спам'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonFraud.
  ///
  /// In ru, this message translates to:
  /// **'Мошенничество'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonAbuse.
  ///
  /// In ru, this message translates to:
  /// **'Оскорбления'**
  String get reportReasonAbuse;

  /// No description provided for @reportReasonOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get reportReasonOther;

  /// No description provided for @reportCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий (необязательно)'**
  String get reportCommentHint;

  /// No description provided for @reportCommentRequired.
  ///
  /// In ru, this message translates to:
  /// **'Для «Другое» опишите проблему'**
  String get reportCommentRequired;

  /// No description provided for @reportSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Отправить жалобу'**
  String get reportSubmit;

  /// No description provided for @reportSent.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отправлена — мы её рассмотрим'**
  String get reportSent;

  /// No description provided for @addServiceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая рекомендация'**
  String get addServiceTitle;

  /// No description provided for @addServiceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуйте организации и сервисы, а не отдельных людей'**
  String get addServiceSubtitle;

  /// No description provided for @photosCaption.
  ///
  /// In ru, this message translates to:
  /// **'От 1 до 5 фото. Первое — обложка; удерживайте, чтобы изменить'**
  String get photosCaption;

  /// No description provided for @coverBadge.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get coverBadge;

  /// No description provided for @makeCover.
  ///
  /// In ru, this message translates to:
  /// **'Сделать обложкой'**
  String get makeCover;

  /// No description provided for @deletePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото'**
  String get deletePhoto;

  /// No description provided for @serviceNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название сервиса'**
  String get serviceNameHint;

  /// No description provided for @serviceDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get serviceDescriptionHint;

  /// No description provided for @serviceWebsiteHint.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на сервис (необязательно)'**
  String get serviceWebsiteHint;

  /// No description provided for @serviceMapHint.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на геопозицию (необязательно)'**
  String get serviceMapHint;

  /// No description provided for @categoryChip.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get categoryChip;

  /// No description provided for @placeChipPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Место: {city}'**
  String placeChipPrefix(String city);

  /// No description provided for @submitForReview.
  ///
  /// In ru, this message translates to:
  /// **'Отправить на проверку'**
  String get submitForReview;

  /// No description provided for @sentForReview.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено на проверку'**
  String get sentForReview;

  /// No description provided for @categorySheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get categorySheetTitle;

  /// No description provided for @duplicateSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Возможно, уже добавлен'**
  String get duplicateSheetTitle;

  /// No description provided for @addAnyway.
  ///
  /// In ru, this message translates to:
  /// **'Всё равно добавить'**
  String get addAnyway;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет уведомлений'**
  String get notificationsEmpty;

  /// No description provided for @notifFriendRequest.
  ///
  /// In ru, this message translates to:
  /// **'{name} отправил(а) вам заявку в друзья'**
  String notifFriendRequest(String name);

  /// No description provided for @notifFriendAccepted.
  ///
  /// In ru, this message translates to:
  /// **'{name} принял(а) заявку — теперь вы друзья'**
  String notifFriendAccepted(String name);

  /// No description provided for @notifMatch.
  ///
  /// In ru, this message translates to:
  /// **'Вы и {name} заинтересовали друг друга — теперь вы друзья'**
  String notifMatch(String name);

  /// No description provided for @notifServiceRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Ваша карточка «{title}» попала в «Рекомендовано» 🎉'**
  String notifServiceRecommended(String title);

  /// No description provided for @notifServiceHidden.
  ///
  /// In ru, this message translates to:
  /// **'Ваша карточка «{title}» скрыта администратором'**
  String notifServiceHidden(String title);

  /// No description provided for @timeJustNow.
  ///
  /// In ru, this message translates to:
  /// **'Только что'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин назад'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} ч назад'**
  String timeHoursAgo(int count);

  /// No description provided for @timeYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн назад'**
  String timeDaysAgo(int count);

  /// No description provided for @nowFriends.
  ///
  /// In ru, this message translates to:
  /// **'Вы теперь друзья'**
  String get nowFriends;

  /// No description provided for @requestDeclined.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отклонена'**
  String get requestDeclined;

  /// No description provided for @guestDatingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы знакомиться'**
  String get guestDatingTitle;

  /// No description provided for @datingEnableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Знакомьтесь с людьми рядом'**
  String get datingEnableTitle;

  /// No description provided for @datingEnableBody.
  ///
  /// In ru, this message translates to:
  /// **'Включите — и вас начнут показывать другим экспатам рядом. Выключить можно в любой момент'**
  String get datingEnableBody;

  /// No description provided for @datingEnableButton.
  ///
  /// In ru, this message translates to:
  /// **'Включить знакомства'**
  String get datingEnableButton;

  /// No description provided for @datingProfileIncompleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль'**
  String get datingProfileIncompleteTitle;

  /// No description provided for @datingProfileIncompleteBody.
  ///
  /// In ru, this message translates to:
  /// **'Для знакомств нужны имя, фото, пол и дата рождения'**
  String get datingProfileIncompleteBody;

  /// No description provided for @datingIncompleteBanner.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте фото, пол и дату рождения — иначе вас не покажут другим'**
  String get datingIncompleteBanner;

  /// No description provided for @datingIncompleteAction.
  ///
  /// In ru, this message translates to:
  /// **'Заполнить'**
  String get datingIncompleteAction;

  /// No description provided for @deckEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Вы посмотрели всех, кто рядом. Загляните позже'**
  String get deckEmpty;

  /// No description provided for @likeLimitReached.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня лайки закончились'**
  String get likeLimitReached;

  /// No description provided for @matchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Это мэтч! 🎉'**
  String get matchTitle;

  /// No description provided for @matchSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы и {name} заинтересовали друг друга'**
  String matchSubtitle(String name);

  /// No description provided for @matchWriteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Написать сообщение'**
  String get matchWriteMessage;

  /// No description provided for @matchLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get matchLater;

  /// No description provided for @datingSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки знакомств'**
  String get datingSettingsTitle;

  /// No description provided for @datingParticipate.
  ///
  /// In ru, this message translates to:
  /// **'Показывать меня в Знакомствах'**
  String get datingParticipate;

  /// No description provided for @datingParticipateHint.
  ///
  /// In ru, this message translates to:
  /// **'Другие видят ваш профиль в этом разделе. Выключите — и вас перестанут показывать'**
  String get datingParticipateHint;

  /// No description provided for @lookingForLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что ищете'**
  String get lookingForLabel;

  /// No description provided for @lookingForAny.
  ///
  /// In ru, this message translates to:
  /// **'Не важно'**
  String get lookingForAny;

  /// No description provided for @lookingForFriends.
  ///
  /// In ru, this message translates to:
  /// **'Друзей'**
  String get lookingForFriends;

  /// No description provided for @lookingForDating.
  ///
  /// In ru, this message translates to:
  /// **'Свидания'**
  String get lookingForDating;

  /// No description provided for @lookingForNetworking.
  ///
  /// In ru, this message translates to:
  /// **'Нетворкинг'**
  String get lookingForNetworking;

  /// No description provided for @showGenderLabel.
  ///
  /// In ru, this message translates to:
  /// **'Кого показывать'**
  String get showGenderLabel;

  /// No description provided for @showGenderAny.
  ///
  /// In ru, this message translates to:
  /// **'Всех'**
  String get showGenderAny;

  /// No description provided for @messageDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение удалено'**
  String get messageDeleted;

  /// No description provided for @deleteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Удалить сообщение'**
  String get deleteMessage;

  /// No description provided for @messagesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get messagesTitle;

  /// No description provided for @messagesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся переписки. Писать можно друзьям'**
  String get messagesEmpty;

  /// No description provided for @toFriends.
  ///
  /// In ru, this message translates to:
  /// **'К друзьям'**
  String get toFriends;

  /// No description provided for @messageHint.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get messageHint;

  /// No description provided for @cannotMessageUser.
  ///
  /// In ru, this message translates to:
  /// **'Написать можно только друзьям'**
  String get cannotMessageUser;

  /// No description provided for @guestMessagesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы переписываться с друзьями'**
  String get guestMessagesTitle;

  /// No description provided for @friendsTabMy.
  ///
  /// In ru, this message translates to:
  /// **'Мои друзья'**
  String get friendsTabMy;

  /// No description provided for @friendsTabIncoming.
  ///
  /// In ru, this message translates to:
  /// **'Входящие'**
  String get friendsTabIncoming;

  /// No description provided for @friendsTabOutgoing.
  ///
  /// In ru, this message translates to:
  /// **'Исходящие'**
  String get friendsTabOutgoing;

  /// No description provided for @friendsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет друзей'**
  String get friendsEmpty;

  /// No description provided for @findPeople.
  ///
  /// In ru, this message translates to:
  /// **'Найти людей'**
  String get findPeople;

  /// No description provided for @incomingEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет входящих заявок'**
  String get incomingEmpty;

  /// No description provided for @outgoingEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет исходящих заявок'**
  String get outgoingEmpty;

  /// No description provided for @wantsToBeFriends.
  ///
  /// In ru, this message translates to:
  /// **'хочет добавить вас в друзья'**
  String get wantsToBeFriends;

  /// No description provided for @acceptRequest.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get acceptRequest;

  /// No description provided for @declineRequest.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get declineRequest;

  /// No description provided for @cancelRequest.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get cancelRequest;

  /// No description provided for @cancelRequestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отменить заявку?'**
  String get cancelRequestTitle;

  /// No description provided for @requestSent.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отправлена'**
  String get requestSent;

  /// No description provided for @addFriend.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в друзья'**
  String get addFriend;

  /// No description provided for @alreadyFriends.
  ///
  /// In ru, this message translates to:
  /// **'Вы друзья'**
  String get alreadyFriends;

  /// No description provided for @writeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Написать сообщение'**
  String get writeMessage;

  /// No description provided for @removeFriend.
  ///
  /// In ru, this message translates to:
  /// **'Удалить из друзей'**
  String get removeFriend;

  /// No description provided for @removeFriendTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить {name} из друзей?'**
  String removeFriendTitle(String name);

  /// No description provided for @removeFriendWarning.
  ///
  /// In ru, this message translates to:
  /// **'Переписка станет недоступна, повторное добавление — новой заявкой'**
  String get removeFriendWarning;

  /// No description provided for @removeFriendConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get removeFriendConfirm;

  /// No description provided for @blockUser.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать'**
  String get blockUser;

  /// No description provided for @blockUserTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать {name}?'**
  String blockUserTitle(String name);

  /// No description provided for @unblockUser.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать'**
  String get unblockUser;

  /// No description provided for @unblockConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать {name}?'**
  String unblockConfirmTitle(String name);

  /// No description provided for @blockedListEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get blockedListEmpty;

  /// No description provided for @peopleSearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поиск людей'**
  String get peopleSearchTitle;

  /// No description provided for @peopleSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя или фамилия'**
  String get peopleSearchHint;

  /// No description provided for @compatriots.
  ///
  /// In ru, this message translates to:
  /// **'Земляки'**
  String get compatriots;

  /// No description provided for @allInCity.
  ///
  /// In ru, this message translates to:
  /// **'Все, кто здесь'**
  String allInCity(String city);

  /// No description provided for @nobodyFound.
  ///
  /// In ru, this message translates to:
  /// **'Никого не нашли'**
  String get nobodyFound;

  /// No description provided for @authGateActionAddFriend.
  ///
  /// In ru, this message translates to:
  /// **'добавить в друзья'**
  String get authGateActionAddFriend;

  /// No description provided for @linkCopied.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована'**
  String get linkCopied;

  /// No description provided for @countFriends.
  ///
  /// In ru, this message translates to:
  /// **'Друзья'**
  String get countFriends;

  /// No description provided for @countRecommendations.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендации'**
  String get countRecommendations;

  /// No description provided for @guestProfileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы завести профиль'**
  String get guestProfileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsSectionProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get settingsSectionProfile;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionDating.
  ///
  /// In ru, this message translates to:
  /// **'Знакомства'**
  String get settingsSectionDating;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Приватность'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Админ'**
  String get settingsSectionAdmin;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsSectionAbout;

  /// No description provided for @editProfile.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get changePassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль'**
  String get currentPasswordHint;

  /// No description provided for @wrongPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный пароль'**
  String get wrongPassword;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageTitle;

  /// No description provided for @blockedUsersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заблокированные пользователи'**
  String get blockedUsersTitle;

  /// No description provided for @blockedScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заблокированные'**
  String get blockedScreenTitle;

  /// No description provided for @adminTitle.
  ///
  /// In ru, this message translates to:
  /// **'Администрирование'**
  String get adminTitle;

  /// No description provided for @termsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get termsTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyTitle;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get logoutConfirmTitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In ru, this message translates to:
  /// **'Профиль удалится, ваши карточки сервисов скроются. Отменить это нельзя'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get deleteAccountContinue;

  /// No description provided for @deleteAccountPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль для подтверждения'**
  String get deleteAccountPasswordTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить навсегда'**
  String get deleteAccountConfirm;

  /// No description provided for @photosLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get photosLabel;

  /// No description provided for @photosHint.
  ///
  /// In ru, this message translates to:
  /// **'До 10 фото. Первое видят в знакомствах и рядом с именем'**
  String get photosHint;

  /// No description provided for @photosLimitReached.
  ///
  /// In ru, this message translates to:
  /// **'Больше 10 фото добавить нельзя'**
  String get photosLimitReached;

  /// No description provided for @makeMainPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сделать главным'**
  String get makeMainPhoto;

  /// No description provided for @mainPhotoBadge.
  ///
  /// In ru, this message translates to:
  /// **'Главное'**
  String get mainPhotoBadge;

  /// No description provided for @bioHint.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get bioHint;

  /// No description provided for @placeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get placeLabel;

  /// No description provided for @countryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Страна'**
  String get countryLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get birthDateLabel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get saved;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти без сохранения?'**
  String get unsavedChangesTitle;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get leaveWithoutSaving;

  /// No description provided for @favoritesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняйте сервисы сердечком на карточке'**
  String get favoritesEmptyHint;

  /// No description provided for @toServices.
  ///
  /// In ru, this message translates to:
  /// **'К сервисам'**
  String get toServices;

  /// No description provided for @addedToFavorites.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в избранное'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In ru, this message translates to:
  /// **'Убрано из избранного'**
  String get removedFromFavorites;

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

  /// No description provided for @adminTabUsers.
  ///
  /// In ru, this message translates to:
  /// **'Пользователи'**
  String get adminTabUsers;

  /// No description provided for @adminTabServices.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get adminTabServices;

  /// No description provided for @adminTabReports.
  ///
  /// In ru, this message translates to:
  /// **'Жалобы'**
  String get adminTabReports;

  /// No description provided for @adminTabCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get adminTabCategories;

  /// No description provided for @adminSearchUsersHint.
  ///
  /// In ru, this message translates to:
  /// **'Email или имя'**
  String get adminSearchUsersHint;

  /// No description provided for @adminBlock.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать'**
  String get adminBlock;

  /// No description provided for @adminUnblock.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать'**
  String get adminUnblock;

  /// No description provided for @adminBlockedLabel.
  ///
  /// In ru, this message translates to:
  /// **'заблокирован'**
  String get adminBlockedLabel;

  /// No description provided for @adminBlockTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать пользователя?'**
  String get adminBlockTitle;

  /// No description provided for @adminBlockReasonHint.
  ///
  /// In ru, this message translates to:
  /// **'Причина блокировки (обязательно)'**
  String get adminBlockReasonHint;

  /// No description provided for @adminBlockNote.
  ///
  /// In ru, this message translates to:
  /// **'Причина будет показана пользователю на экране блокировки. Все его сервисы будут скрыты.'**
  String get adminBlockNote;

  /// No description provided for @adminUserBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь заблокирован'**
  String get adminUserBlocked;

  /// No description provided for @adminUserUnblocked.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь разблокирован'**
  String get adminUserUnblocked;

  /// No description provided for @adminFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get adminFilterAll;

  /// No description provided for @adminFilterPending.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get adminFilterPending;

  /// No description provided for @adminFilterRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендовано'**
  String get adminFilterRecommended;

  /// No description provided for @adminFilterHidden.
  ///
  /// In ru, this message translates to:
  /// **'Скрытые'**
  String get adminFilterHidden;

  /// No description provided for @adminApprove.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить'**
  String get adminApprove;

  /// No description provided for @adminHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get adminHide;

  /// No description provided for @adminServiceApproved.
  ///
  /// In ru, this message translates to:
  /// **'Сервис одобрен'**
  String get adminServiceApproved;

  /// No description provided for @adminServiceHidden.
  ///
  /// In ru, this message translates to:
  /// **'Сервис скрыт'**
  String get adminServiceHidden;

  /// No description provided for @adminEditServiceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование сервиса'**
  String get adminEditServiceTitle;

  /// No description provided for @adminEditServiceNote.
  ///
  /// In ru, this message translates to:
  /// **'Режим админа · изменения применяются сразу'**
  String get adminEditServiceNote;

  /// No description provided for @adminSaveChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить изменения'**
  String get adminSaveChanges;

  /// No description provided for @adminReportOnService.
  ///
  /// In ru, this message translates to:
  /// **'На карточку «{title}»'**
  String adminReportOnService(String title);

  /// No description provided for @adminReportOnUser.
  ///
  /// In ru, this message translates to:
  /// **'На пользователя {name}'**
  String adminReportOnUser(String name);

  /// No description provided for @adminReportFrom.
  ///
  /// In ru, this message translates to:
  /// **'— {name}'**
  String adminReportFrom(String name);

  /// No description provided for @adminTakeAction.
  ///
  /// In ru, this message translates to:
  /// **'Принять меры'**
  String get adminTakeAction;

  /// No description provided for @adminActionOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get adminActionOpen;

  /// No description provided for @adminActionHideService.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть сервис'**
  String get adminActionHideService;

  /// No description provided for @adminActionBlockUser.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать автора'**
  String get adminActionBlockUser;

  /// No description provided for @adminActionResolve.
  ///
  /// In ru, this message translates to:
  /// **'Отметить обработанной'**
  String get adminActionResolve;

  /// No description provided for @adminReportResolved.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба обработана'**
  String get adminReportResolved;

  /// No description provided for @adminNewCategoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get adminNewCategoryTitle;

  /// No description provided for @adminCategoryNameRu.
  ///
  /// In ru, this message translates to:
  /// **'Название (русский)'**
  String get adminCategoryNameRu;

  /// No description provided for @adminCategoryNameEn.
  ///
  /// In ru, this message translates to:
  /// **'Name (english)'**
  String get adminCategoryNameEn;

  /// No description provided for @adminCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get adminCreate;

  /// No description provided for @adminCategoryDeleteNote.
  ///
  /// In ru, this message translates to:
  /// **'Удалить можно только категорию без активных сервисов'**
  String get adminCategoryDeleteNote;

  /// No description provided for @adminCategoryInUse.
  ///
  /// In ru, this message translates to:
  /// **'В категории есть сервисы — сначала перенесите их'**
  String get adminCategoryInUse;

  /// No description provided for @adminCategoryCreated.
  ///
  /// In ru, this message translates to:
  /// **'Категория создана'**
  String get adminCategoryCreated;

  /// No description provided for @adminCategoryDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Категория удалена'**
  String get adminCategoryDeleted;

  /// No description provided for @adminCategoryDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Такая категория уже есть'**
  String get adminCategoryDuplicate;

  /// No description provided for @adminEmptyUsers.
  ///
  /// In ru, this message translates to:
  /// **'Никого не найдено'**
  String get adminEmptyUsers;

  /// No description provided for @adminEmptyServices.
  ///
  /// In ru, this message translates to:
  /// **'Сервисов нет'**
  String get adminEmptyServices;

  /// No description provided for @adminEmptyReports.
  ///
  /// In ru, this message translates to:
  /// **'Необработанных жалоб нет'**
  String get adminEmptyReports;

  /// No description provided for @adminServicesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} сервис} few{{count} сервиса} other{{count} сервисов}}'**
  String adminServicesCount(int count);

  /// No description provided for @adminEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get adminEdit;

  /// No description provided for @adminShow.
  ///
  /// In ru, this message translates to:
  /// **'Отображать'**
  String get adminShow;

  /// No description provided for @adminDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get adminDelete;

  /// No description provided for @adminDeleteServiceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить карточку навсегда?'**
  String get adminDeleteServiceTitle;

  /// No description provided for @adminDeleteServiceNote.
  ///
  /// In ru, this message translates to:
  /// **'Карточка, её фотографии, лайки и жалобы будут стёрты с сервера. Отменить это нельзя'**
  String get adminDeleteServiceNote;

  /// No description provided for @adminServiceRestored.
  ///
  /// In ru, this message translates to:
  /// **'Сервис снова виден'**
  String get adminServiceRestored;

  /// No description provided for @adminServiceDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Карточка удалена'**
  String get adminServiceDeleted;

  /// No description provided for @adminDeleteCategoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить категорию?'**
  String get adminDeleteCategoryTitle;

  /// No description provided for @adminYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get adminYes;

  /// No description provided for @adminNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get adminNo;

  /// No description provided for @adminReportCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get adminReportCategory;

  /// No description provided for @adminReportDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get adminReportDescription;

  /// No description provided for @adminReportReporter.
  ///
  /// In ru, this message translates to:
  /// **'Заявитель'**
  String get adminReportReporter;

  /// No description provided for @adminNotAvailable.
  ///
  /// In ru, this message translates to:
  /// **'н/д'**
  String get adminNotAvailable;

  /// No description provided for @userBlockedProfile.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь был заблокирован за нарушение условий использования сервиса'**
  String get userBlockedProfile;

  /// No description provided for @serviceVerified.
  ///
  /// In ru, this message translates to:
  /// **'Проверенный сервис'**
  String get serviceVerified;

  /// No description provided for @serviceVerifiedNote.
  ///
  /// In ru, this message translates to:
  /// **'Админ лично проверил эту карточку'**
  String get serviceVerifiedNote;

  /// No description provided for @serviceAddedBy.
  ///
  /// In ru, this message translates to:
  /// **'Добавил'**
  String get serviceAddedBy;

  /// No description provided for @serviceOwner.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get serviceOwner;

  /// No description provided for @adminVerifiedToggle.
  ///
  /// In ru, this message translates to:
  /// **'Проверенный сервис'**
  String get adminVerifiedToggle;

  /// No description provided for @adminVerifiedHint.
  ///
  /// In ru, this message translates to:
  /// **'Значок проверки виден всем в списке и в карточке'**
  String get adminVerifiedHint;

  /// No description provided for @adminOwnerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get adminOwnerLabel;

  /// No description provided for @adminOwnerNone.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get adminOwnerNone;

  /// No description provided for @adminOwnerPick.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать владельца'**
  String get adminOwnerPick;

  /// No description provided for @adminOwnerClear.
  ///
  /// In ru, this message translates to:
  /// **'Убрать владельца'**
  String get adminOwnerClear;

  /// No description provided for @online.
  ///
  /// In ru, this message translates to:
  /// **'в сети'**
  String get online;

  /// No description provided for @linkOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть ссылку'**
  String get linkOpenFailed;
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

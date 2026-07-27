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
  /// **'👍 Рекомендую'**
  String get recommendButton;

  /// No description provided for @youRecommend.
  ///
  /// In ru, this message translates to:
  /// **'✓ Вы рекомендуете'**
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
  /// **'Жалоба отправлена. Мы все проверим и примем решение.'**
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
  /// **'Удалить'**
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
  /// **'Отправлено ✓'**
  String get requestSent;

  /// No description provided for @addFriend.
  ///
  /// In ru, this message translates to:
  /// **'+ Добавить'**
  String get addFriend;

  /// No description provided for @alreadyFriends.
  ///
  /// In ru, this message translates to:
  /// **'✓ Друзья'**
  String get alreadyFriends;

  /// No description provided for @writeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
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
  /// **'Все на {city}'**
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
  /// **'Профиль будет удалён, ваши карточки сервисов скроются. Действие необратимо.'**
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

  /// No description provided for @changePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото'**
  String get changePhoto;

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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'outside';

  @override
  String get welcomeTagline => 'Свои люди в любой стране';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get login => 'Войти';

  @override
  String get continueAsGuest => 'Продолжить без регистрации';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordHint => 'Пароль (мин. 8 символов)';

  @override
  String get passwordConfirmHint => 'Повторите пароль';

  @override
  String get usernameHint => '@никнейм';

  @override
  String get usernameHelper =>
      'Никнейм — это ссылка на ваш профиль. Латинские буквы и _, до 30 символов';

  @override
  String get legalNotice =>
      'Создавая аккаунт, вы принимаете Условия использования и Политику конфиденциальности';

  @override
  String get usernameChecking => 'проверяем…';

  @override
  String get usernameAvailable => 'свободно';

  @override
  String get usernameTaken => 'занято';

  @override
  String get errorEmailInvalid => 'Введите корректный email';

  @override
  String get errorEmailTaken => 'Этот email уже зарегистрирован.';

  @override
  String get errorPasswordTooShort => 'Пароль должен быть не короче 8 символов';

  @override
  String get errorPasswordLatin => 'Только латинские буквы, цифры и символы';

  @override
  String get errorPasswordMismatch => 'Пароли не совпадают';

  @override
  String get errorUsernameInvalid =>
      'Только латинские буквы и _, от 3 до 30 символов';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get verifyEmailTitle => 'Подтвердите почту';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Мы отправили 6-значный код на $email. Введите его, чтобы завершить регистрацию';
  }

  @override
  String errorCodeWrong(int count) {
    return 'Неверный код, осталось попыток: $count';
  }

  @override
  String get errorCodeExpired => 'Код истёк или недействителен';

  @override
  String get errorCodeLocked => 'Слишком много попыток. Запросите новый код';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String resendCodeTimer(String time) {
    return 'Отправить код повторно через $time';
  }

  @override
  String get confirm => 'Подтвердить';

  @override
  String onboardingStepLabel(int step) {
    return 'Шаг $step из 3';
  }

  @override
  String get onboardingStep1Title => 'Как вас зовут?';

  @override
  String get firstNameHint => 'Имя';

  @override
  String get lastNameHint => 'Фамилия';

  @override
  String get genderLabel => 'Пол';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get next => 'Далее';

  @override
  String get onboardingStep2Title => 'Откуда вы?';

  @override
  String get onboardingStep2Subtitle =>
      'Выберите ваших соотечественников или с кем хотите пообщаться';

  @override
  String get searchCountry => 'Поиск страны';

  @override
  String get otherCountry => 'Другая страна…';

  @override
  String get onboardingStep3Title => 'Где вы находитесь?';

  @override
  String get citiesFootnote => 'Скоро добавим новые города';

  @override
  String get done => 'Готово';

  @override
  String get loginTitle => 'Вход';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get noAccountCreate => 'Нет аккаунта? Создать';

  @override
  String get errorInvalidCredentials => 'Неверный email или пароль';

  @override
  String errorTryLater(int seconds) {
    return 'Слишком много попыток. Попробуйте через $seconds с';
  }

  @override
  String get forgotPasswordTitle => 'Забыли пароль?';

  @override
  String get forgotPasswordSubtitle =>
      'Укажите email — пришлём 6-значный код для сброса пароля';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get backToLogin => '‹ Вернуться ко входу';

  @override
  String get codeSentNotice =>
      'Если такой email зарегистрирован, мы отправили код';

  @override
  String get newPasswordTitle => 'Новый пароль';

  @override
  String get newPasswordHint => 'Новый пароль (мин. 8 символов)';

  @override
  String get saveAndLogin => 'Сохранить и войти';

  @override
  String get blockedTitle => 'Аккаунт заблокирован';

  @override
  String blockedReasonLabel(String reason) {
    return 'Причина: $reason';
  }

  @override
  String get blockedSubtitle =>
      'Если вы считаете это ошибкой — напишите нам, разберёмся';

  @override
  String get contactSupport => 'Написать в поддержку';

  @override
  String get logout => 'Выйти';

  @override
  String get avatarUploadFailed =>
      'Не удалось загрузить фото — добавите его позже в профиле';

  @override
  String get homeWelcomeTitle => 'Добро пожаловать в Outside!';

  @override
  String get tabDating => 'Знакомства';

  @override
  String get tabServices => 'Сервисы';

  @override
  String get tabMessages => 'Сообщения';

  @override
  String get tabFriends => 'Друзья';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get comingSoonSection => 'Этот раздел появится в следующей итерации';

  @override
  String get servicesTitle => 'Сервисы';

  @override
  String get servicesTabRecommended => 'Рекомендовано';

  @override
  String get servicesTabPending => 'На проверке';

  @override
  String get categoryAll => 'Все';

  @override
  String get placeSheetTitle => 'Место';

  @override
  String get servicesEmptyPending =>
      'Пока нет сервисов на проверке. Добавьте первым!';

  @override
  String get servicesEmptyRecommended => 'Пока нет рекомендованных сервисов';

  @override
  String get addServiceAction => 'Добавить сервис';

  @override
  String authGateTitle(String action) {
    return 'Войдите, чтобы $action';
  }

  @override
  String get authGateSubtitle =>
      'Это займёт меньше минуты. После входа действие выполнится автоматически';

  @override
  String get authGateActionFavorite => 'сохранить в избранное';

  @override
  String get authGateActionLike => 'рекомендовать сервис';

  @override
  String get authGateActionAdd => 'добавить сервис';

  @override
  String recommendCount(int count) {
    return '$count рекомендуют';
  }

  @override
  String get recommendButton => '👍 Рекомендую';

  @override
  String get youRecommend => '✓ Вы рекомендуете';

  @override
  String confirmButton(int count, int threshold) {
    return 'Подтвердить ($count/$threshold)';
  }

  @override
  String get confirmedByLocals => 'Подтверждают жители города сервиса';

  @override
  String get yourServiceBadge => 'Добавлен вами';

  @override
  String get siteButton => 'Сайт';

  @override
  String get mapButton => 'На карте';

  @override
  String addedBy(String name) {
    return 'Добавил(а): $name';
  }

  @override
  String get reportSheetTitle => 'Пожаловаться';

  @override
  String get reportReasonSpam => 'Спам';

  @override
  String get reportReasonFraud => 'Мошенничество';

  @override
  String get reportReasonAbuse => 'Оскорбления';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportCommentHint => 'Комментарий (необязательно)';

  @override
  String get reportCommentRequired => 'Для «Другое» опишите проблему';

  @override
  String get reportSubmit => 'Отправить жалобу';

  @override
  String get reportSent =>
      'Жалоба отправлена. Мы все проверим и примем решение.';

  @override
  String get addServiceTitle => 'Новая рекомендация';

  @override
  String get addServiceSubtitle =>
      'Рекомендуйте организации и сервисы, а не отдельных людей';

  @override
  String get photosCaption =>
      'От 1 до 5 фото. Первое — обложка; удерживайте, чтобы изменить';

  @override
  String get coverBadge => 'Обложка';

  @override
  String get makeCover => 'Сделать обложкой';

  @override
  String get deletePhoto => 'Удалить';

  @override
  String get serviceNameHint => 'Название сервиса';

  @override
  String get serviceDescriptionHint => 'Описание';

  @override
  String get serviceWebsiteHint => 'Ссылка на сервис (необязательно)';

  @override
  String get serviceMapHint => 'Ссылка на геопозицию (необязательно)';

  @override
  String get categoryChip => 'Категория';

  @override
  String placeChipPrefix(String city) {
    return 'Место: $city';
  }

  @override
  String get submitForReview => 'Отправить на проверку';

  @override
  String get sentForReview => 'Отправлено на проверку';

  @override
  String get categorySheetTitle => 'Категория';

  @override
  String get duplicateSheetTitle => 'Возможно, уже добавлен';

  @override
  String get addAnyway => 'Всё равно добавить';

  @override
  String get friendsTabMy => 'Мои друзья';

  @override
  String get friendsTabIncoming => 'Входящие';

  @override
  String get friendsTabOutgoing => 'Исходящие';

  @override
  String get friendsEmpty => 'Пока нет друзей';

  @override
  String get findPeople => 'Найти людей';

  @override
  String get incomingEmpty => 'Нет входящих заявок';

  @override
  String get outgoingEmpty => 'Нет исходящих заявок';

  @override
  String get wantsToBeFriends => 'хочет добавить вас в друзья';

  @override
  String get acceptRequest => 'Принять';

  @override
  String get declineRequest => 'Отклонить';

  @override
  String get cancelRequest => 'Отменить';

  @override
  String get cancelRequestTitle => 'Отменить заявку?';

  @override
  String get requestSent => 'Отправлено ✓';

  @override
  String get addFriend => '+ Добавить';

  @override
  String get alreadyFriends => '✓ Друзья';

  @override
  String get writeMessage => 'Написать';

  @override
  String get removeFriend => 'Удалить из друзей';

  @override
  String removeFriendTitle(String name) {
    return 'Удалить $name из друзей?';
  }

  @override
  String get removeFriendWarning =>
      'Переписка станет недоступна, повторное добавление — новой заявкой';

  @override
  String get removeFriendConfirm => 'Удалить';

  @override
  String get blockUser => 'Заблокировать';

  @override
  String blockUserTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String get unblockUser => 'Разблокировать';

  @override
  String unblockConfirmTitle(String name) {
    return 'Разблокировать $name?';
  }

  @override
  String get blockedListEmpty => 'Список пуст';

  @override
  String get peopleSearchTitle => 'Поиск людей';

  @override
  String get peopleSearchHint => 'Имя или фамилия';

  @override
  String get compatriots => 'Земляки';

  @override
  String allInCity(String city) {
    return 'Все на $city';
  }

  @override
  String get nobodyFound => 'Никого не нашли';

  @override
  String get authGateActionAddFriend => 'добавить в друзья';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get countFriends => 'Друзья';

  @override
  String get countRecommendations => 'Рекомендации';

  @override
  String get guestProfileTitle => 'Войдите, чтобы завести профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionProfile => 'Профиль';

  @override
  String get settingsSectionAccount => 'Аккаунт';

  @override
  String get settingsSectionDating => 'Знакомства';

  @override
  String get settingsSectionPrivacy => 'Приватность';

  @override
  String get settingsSectionAdmin => 'Админ';

  @override
  String get settingsSectionAbout => 'О приложении';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get currentPasswordHint => 'Текущий пароль';

  @override
  String get wrongPassword => 'Неверный пароль';

  @override
  String get languageTitle => 'Язык';

  @override
  String get blockedUsersTitle => 'Заблокированные пользователи';

  @override
  String get blockedScreenTitle => 'Заблокированные';

  @override
  String get adminTitle => 'Администрирование';

  @override
  String get termsTitle => 'Условия использования';

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт';

  @override
  String get deleteAccountWarning =>
      'Профиль будет удалён, ваши карточки сервисов скроются. Действие необратимо.';

  @override
  String get deleteAccountContinue => 'Продолжить';

  @override
  String get deleteAccountPasswordTitle => 'Введите пароль для подтверждения';

  @override
  String get deleteAccountConfirm => 'Удалить навсегда';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get bioHint => 'О себе';

  @override
  String get placeLabel => 'Место';

  @override
  String get countryLabel => 'Страна';

  @override
  String get birthDateLabel => 'Дата рождения';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get unsavedChangesTitle => 'Выйти без сохранения?';

  @override
  String get leaveWithoutSaving => 'Выйти';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesEmptyHint => 'Сохраняйте сервисы сердечком на карточке';

  @override
  String get toServices => 'К сервисам';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get removedFromFavorites => 'Убрано из избранного';

  @override
  String get genericError => 'Что-то пошло не так. Попробуйте ещё раз';

  @override
  String get noConnection => 'Нет соединения';

  @override
  String get cancel => 'Отмена';

  @override
  String get retry => 'Повторить';
}

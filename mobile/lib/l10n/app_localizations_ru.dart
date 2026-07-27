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
  String get genericError => 'Что-то пошло не так. Попробуйте ещё раз';

  @override
  String get noConnection => 'Нет соединения';

  @override
  String get cancel => 'Отмена';

  @override
  String get retry => 'Повторить';
}

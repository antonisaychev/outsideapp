/// Профиль текущего пользователя (ответ GET/PATCH /me).
class MeProfile {
  MeProfile({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.cityId,
    this.homeCountry,
    this.gender,
    this.birthDate,
  });

  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final int? cityId;
  final String? homeCountry;
  final String? gender;
  final String? birthDate;

  factory MeProfile.fromJson(Map<String, dynamic> json) => MeProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    cityId: json['city_id'] as int?,
    homeCountry: json['home_country'] as String?,
    gender: json['gender'] as String?,
    birthDate: json['birth_date'] as String?,
  );

  // Онбординг (docs/TZ_Outside_v5_3_changes.md, п.2) — 3 обязательных шага.
  bool get onboardingStep1Done =>
      (firstName?.isNotEmpty ?? false) &&
      (lastName?.isNotEmpty ?? false) &&
      gender != null;
  bool get onboardingStep2Done => homeCountry?.isNotEmpty ?? false;
  bool get onboardingStep3Done => cityId != null;
  bool get onboardingComplete =>
      onboardingStep1Done && onboardingStep2Done && onboardingStep3Done;
}

class City {
  City({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.countryRu,
    required this.countryEn,
    required this.flag,
  });

  final int id;
  final String nameRu;
  final String nameEn;
  final String countryRu;
  final String countryEn;
  final String flag;

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'] as int,
    nameRu: json['name_ru'] as String,
    nameEn: json['name_en'] as String,
    countryRu: json['country_ru'] as String,
    countryEn: json['country_en'] as String,
    flag: json['flag'] as String,
  );
}

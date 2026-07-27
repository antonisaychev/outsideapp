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

class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.nameRu,
    required this.nameEn,
  });

  final int id;
  final String nameRu;
  final String nameEn;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      ServiceCategory(
        id: json['id'] as int,
        nameRu: json['name_ru'] as String,
        nameEn: json['name_en'] as String,
      );
}

/// Карточка сервиса в плитке (ответ GET /services и GET /me/favorites).
class ServiceSummary {
  ServiceSummary({
    required this.id,
    required this.title,
    required this.photoUrl,
    required this.categoryId,
    required this.cityId,
    required this.status,
    required this.likesCount,
    this.confirmCount = 0,
    this.confirmThreshold,
    this.photosCount = 1,
  });

  final String id;
  final String title;
  final String photoUrl;
  final int categoryId;
  final int cityId;
  final String status;
  final int likesCount;
  final int confirmCount;
  final int? confirmThreshold;
  final int photosCount;

  factory ServiceSummary.fromJson(Map<String, dynamic> json) => ServiceSummary(
    id: json['id'] as String,
    title: json['title'] as String,
    photoUrl: json['photo_url'] as String,
    categoryId: json['category_id'] as int,
    cityId: json['city_id'] as int,
    status: json['status'] as String,
    likesCount: json['likes_count'] as int,
    confirmCount: (json['confirm_count'] as int?) ?? 0,
    confirmThreshold: json['confirm_threshold'] as int?,
    photosCount: (json['photos_count'] as int?) ?? 1,
  );
}

class ServicePhoto {
  ServicePhoto({required this.id, required this.url, required this.sort});

  final String id;
  final String url;
  final int sort;

  factory ServicePhoto.fromJson(Map<String, dynamic> json) => ServicePhoto(
    id: json['id'] as String,
    url: json['url'] as String,
    sort: json['sort'] as int,
  );
}

/// Детальная карточка (ответ GET /services/:id).
class ServiceDetail {
  ServiceDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.photos,
    this.websiteUrl,
    this.mapUrl,
    required this.cityId,
    required this.categoryId,
    required this.status,
    required this.likesCount,
    required this.confirmCount,
    required this.confirmThreshold,
    required this.authorId,
    required this.authorName,
    required this.isAuthor,
    required this.likedByMe,
    required this.isFavorite,
    required this.canConfirm,
  });

  final String id;
  final String title;
  final String description;
  final String photoUrl;
  final List<ServicePhoto> photos;
  final String? websiteUrl;
  final String? mapUrl;
  final int cityId;
  final int categoryId;
  final String status;
  final int likesCount;
  final int confirmCount;
  final int confirmThreshold;
  final String authorId;
  final String authorName;
  final bool isAuthor;
  final bool likedByMe;
  final bool isFavorite;
  final bool canConfirm;

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final first = author['first_name'] as String?;
    final last = author['last_name'] as String?;
    final name = [
      first,
      last,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    return ServiceDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      photoUrl: json['photo_url'] as String,
      photos: ((json['photos'] as List?) ?? [])
          .map((e) => ServicePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      websiteUrl: json['website_url'] as String?,
      mapUrl: json['map_url'] as String?,
      cityId: json['city_id'] as int,
      categoryId: json['category_id'] as int,
      status: json['status'] as String,
      likesCount: json['likes_count'] as int,
      confirmCount: (json['confirm_count'] as int?) ?? 0,
      confirmThreshold: (json['confirm_threshold'] as int?) ?? 30,
      authorId: author['id'] as String? ?? '',
      authorName: name.isEmpty ? '@${author['username'] ?? ''}' : name,
      isAuthor: (json['is_author'] as bool?) ?? false,
      likedByMe: (json['liked_by_me'] as bool?) ?? false,
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      canConfirm: (json['can_confirm'] as bool?) ?? false,
    );
  }
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

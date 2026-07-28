import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models.dart';

/// Анкета знакомств (GET/PATCH /dating/profile).
class DatingProfile {
  DatingProfile({
    required this.isActive,
    required this.lookingFor,
    required this.showGender,
    required this.eligible,
  });

  final bool isActive;

  /// friends | dating | networking | any
  final String lookingFor;

  /// male | female | any
  final String showGender;

  /// Заполнены ли обязательные поля профиля (имя, фото, пол, дата рождения)
  final bool eligible;

  factory DatingProfile.fromJson(Map<String, dynamic> json) => DatingProfile(
    isActive: (json['is_active'] as bool?) ?? false,
    lookingFor: (json['looking_for'] as String?) ?? 'any',
    showGender: (json['show_gender'] as String?) ?? 'any',
    eligible: (json['eligible'] as bool?) ?? false,
  );
}

/// Карточка в колоде (GET /dating/deck).
class DeckCard {
  DeckCard({
    required this.id,
    required this.username,
    this.firstName,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.birthDate,
    this.photos = const [],
  });

  final String id;
  final String username;
  final String? firstName;
  final String? avatarUrl;
  final List<UserPhoto> photos;
  final String? bio;
  final String? gender;
  final DateTime? birthDate;

  String get displayName =>
      (firstName != null && firstName!.isNotEmpty) ? firstName! : '@$username';

  /// Возраст показывается на карточке (мастер-ТЗ §7)
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var years = now.year - birthDate!.year;
    final hadBirthday =
        now.month > birthDate!.month ||
        (now.month == birthDate!.month && now.day >= birthDate!.day);
    if (!hadBirthday) years--;
    return years;
  }

  factory DeckCard.fromJson(Map<String, dynamic> json) => DeckCard(
    id: json['id'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    bio: json['bio'] as String?,
    photos: UserPhoto.listFrom(json['photos']),
    gender: json['gender'] as String?,
    birthDate: json['birth_date'] != null
        ? DateTime.tryParse(json['birth_date'] as String)
        : null,
  );
}

/// Мэтч в списке «Мои мэтчи» (GET /dating/matches).
class DatingMatch {
  DatingMatch({
    required this.id,
    required this.username,
    this.firstName,
    this.avatarUrl,
    this.matchedAt,
  });

  final String id;
  final String username;
  final String? firstName;
  final String? avatarUrl;
  final DateTime? matchedAt;

  String get displayName =>
      (firstName != null && firstName!.isNotEmpty) ? firstName! : '@$username';

  factory DatingMatch.fromJson(Map<String, dynamic> json) => DatingMatch(
    id: json['id'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    matchedAt: json['matched_at'] != null
        ? DateTime.tryParse(json['matched_at'] as String)
        : null,
  );
}

/// Результат свайпа: при взаимном лайке — мэтч с данными собеседника.
class SwipeResult {
  SwipeResult({required this.match, this.user});

  final bool match;
  final DatingMatch? user;

  factory SwipeResult.fromJson(Map<String, dynamic> json) => SwipeResult(
    match: (json['match'] as bool?) ?? false,
    user: json['user'] != null
        ? DatingMatch.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );
}

class DatingApi {
  DatingApi(this._dio);
  final Dio _dio;

  Future<DatingProfile> getProfile() async {
    try {
      final r = await _dio.get('/dating/profile');
      return DatingProfile.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<void> updateProfile({
    bool? isActive,
    String? lookingFor,
    String? showGender,
  }) async {
    try {
      await _dio.patch(
        '/dating/profile',
        data: {
          'is_active': ?isActive,
          'looking_for': ?lookingFor,
          'show_gender': ?showGender,
        },
      );
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<DeckCard>> deck() async {
    try {
      final r = await _dio.get('/dating/deck');
      return (r.data as List)
          .map((e) => DeckCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<SwipeResult> swipe(String userId, {required bool like}) async {
    try {
      final r = await _dio.post(
        '/dating/swipe',
        data: {'user_id': userId, 'direction': like ? 'like' : 'pass'},
      );
      return SwipeResult.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }

  Future<List<DatingMatch>> matches() async {
    try {
      final r = await _dio.get('/dating/matches');
      return (r.data as List)
          .map((e) => DatingMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw toApiException(e);
    }
  }
}

final datingApiProvider = Provider<DatingApi>(
  (ref) => DatingApi(ref.read(dioProvider)),
);

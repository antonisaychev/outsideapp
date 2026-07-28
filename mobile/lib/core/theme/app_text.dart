import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографическая шкала Outside 2.0 — один в один с текстовыми стилями
/// Figma (страница «Outside 2.0»). Названия повторяют названия стилей,
/// чтобы макет и код читались одинаково.
class AppText {
  AppText._();

  static const _f = 'Inter';

  /// Дисплей/32 Bold — приветственный экран, «Это мэтч!»
  static const display = TextStyle(
    fontFamily: _f,
    fontSize: 32,
    height: 38 / 32,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
  );

  /// Заголовок/28 Bold — заголовок вкладки
  static const h1 = TextStyle(
    fontFamily: _f,
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.3,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
  );

  /// Заголовок/24 Bold — название карточки, имя в профиле
  static const h2 = TextStyle(
    fontFamily: _f,
    fontSize: 24,
    height: 30 / 24,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
  );

  /// Заголовок/20 Semi Bold — заголовок секции, пустого состояния
  static const h3 = TextStyle(
    fontFamily: _f,
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
  );

  /// Подзаголовок/17 Semi Bold — заголовок навбара, имя в списке
  static const title = TextStyle(
    fontFamily: _f,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
  );

  /// Текст/16 Regular — основной текст
  static const body = TextStyle(
    fontFamily: _f,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral800,
  );

  /// Текст/16 Semi Bold — акцентная строка, название в списке
  static const bodyStrong = TextStyle(
    fontFamily: _f,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
  );

  /// Текст/15 Regular — описания, подписи под именем
  static const callout = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    height: 21 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral800,
  );

  /// Мелкий/13 Regular — метаданные, подсказки под полями
  static const small = TextStyle(
    fontFamily: _f,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral500,
  );

  /// Мелкий/13 Medium — время, счётчики
  static const smallMedium = TextStyle(
    fontFamily: _f,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral800,
  );

  /// Подпись/12 Medium — метка поля, подпись таб-бара
  static const caption = TextStyle(
    fontFamily: _f,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral500,
  );

  /// Рубрика/12 Semi Bold CAPS — заголовок группы настроек
  static const overline = TextStyle(
    fontFamily: _f,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral500,
  );

  /// Кнопка/16 Semi Bold
  static const button = TextStyle(
    fontFamily: _f,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
  );
}

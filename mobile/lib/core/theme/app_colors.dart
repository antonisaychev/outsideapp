import 'package:flutter/material.dart';

/// Палитра Outside 2.0 — совпадает с переменными Figma
/// (страница «Outside 2.0», коллекция «Outside 2.0 · Цвет»).
///
/// Старые имена (background, surface, border, textPrimary…) сохранены как
/// псевдонимы новой шкалы: экраны, которые ещё не переведены на новые токены,
/// продолжают работать и автоматически получают обновлённые оттенки.
class AppColors {
  AppColors._();

  // --- Нейтральная шкала ---
  static const neutral0 = Color(0xFFFFFFFF); // фон
  static const neutral50 = Color(0xFFFAFAFB); // подложка экрана
  static const neutral100 = Color(0xFFF4F4F6); // поверхность, чипы
  static const neutral200 = Color(0xFFEAEAEF); // разделители
  static const neutral300 = Color(0xFFDCDCE3); // рамки полей
  static const neutral400 = Color(0xFFB4B4BF); // плейсхолдеры, неактивное
  static const neutral500 = Color(0xFF8A8A96); // вторичный текст
  static const neutral600 = Color(0xFF63636E); // спокойный текст
  static const neutral800 = Color(0xFF2A2A31); // основной текст
  static const neutral900 = Color(0xFF16161A); // заголовки

  // --- Бренд ---
  static const coral = Color(0xFFFF385C);
  static const coralPressed = Color(0xFFE32B4D);
  static const coralBg = Color(0xFFFFF0F3);
  static const coralBorder = Color(0xFFFFD3DC);
  static const gradientStart = Color(0xFFFD297B);
  static const gradientEnd = Color(0xFFFF655B);

  // --- Смысловые ---
  static const success = Color(0xFF17B26A);
  static const successBg = Color(0xFFE7F8F0);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF6E7);
  static const error = Color(0xFFE5484D);
  static const errorBg = Color(0xFFFDECEC);

  /// Синяя галочка «проверено админом» — единственный синий в интерфейсе
  static const verified = Color(0xFF2E7CF6);

  /// Зелёная точка «в сети»
  static const online = Color(0xFF31C859);

  // --- Псевдонимы для непереведённых экранов ---
  static const background = neutral0;
  static const surface = neutral100;
  static const border = neutral200;
  static const textPrimary = neutral800;
  static const textSecondary = neutral500;
  static const coralTint = coralBg;

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  /// Затемнение под текстом на фотографии (карточки, галереи)
  static const photoScrim = LinearGradient(
    begin: Alignment.center,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xD1000000)],
  );
}

/// Радиусы скруглений из кита
class AppRadius {
  AppRadius._();

  static const small = 12.0;
  static const medium = 16.0;
  static const large = 20.0;
  static const card = 24.0;
  static const screen = 28.0;
  static const full = 999.0;
}

/// Шаг сетки: все отступы кратны 4
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 20.0;

  /// Боковые поля экрана — 24 с каждой стороны
  static const screen = 24.0;
  static const xxl = 32.0;
}

/// Тени из кита
class AppShadows {
  AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const floating = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

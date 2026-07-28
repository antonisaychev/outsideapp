import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Тема Outside 2.0 — собрана из токенов Figma (страница «Outside 2.0»).
/// Поля: рамка + метка внутри, подсказка под полем; кнопки-«пилюли»;
/// крупные заголовки в теле экрана (AppBar — только «назад»).
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.coral,
    primary: AppColors.coral,
    error: AppColors.error,
    surface: AppColors.neutral0,
  );

  const radius = AppRadius.medium;
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.neutral0,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displaySmall: AppText.display,
      headlineLarge: AppText.h1,
      headlineMedium: AppText.h2,
      headlineSmall: AppText.h3,
      titleMedium: AppText.title,
      titleSmall: AppText.bodyStrong,
      bodyLarge: AppText.body,
      bodyMedium: AppText.small,
      labelLarge: AppText.button,
      labelMedium: AppText.caption,
      labelSmall: AppText.overline,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neutral0,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.title,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.neutral200,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.neutral200,
        disabledForegroundColor: AppColors.neutral400,
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: AppText.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral800,
        backgroundColor: AppColors.neutral0,
        side: const BorderSide(color: AppColors.neutral300, width: 1.5),
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        textStyle: AppText.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.coral,
        textStyle: AppText.bodyStrong,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.neutral0,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.coral
            : AppColors.neutral300,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.neutral0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.screen),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.neutral0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      titleTextStyle: AppText.h3,
      contentTextStyle: AppText.callout.copyWith(color: AppColors.neutral600),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: AppText.callout.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral0,
      // Метка живёт внутри рамки над значением — приём из макетов
      labelStyle: AppText.caption,
      floatingLabelStyle: AppText.caption,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      hintStyle: AppText.body.copyWith(color: AppColors.neutral400),
      helperStyle: AppText.small,
      helperMaxLines: 3,
      errorMaxLines: 3,
      constraints: const BoxConstraints(minHeight: 56),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(AppColors.neutral300),
      enabledBorder: border(AppColors.neutral300),
      focusedBorder: border(AppColors.coral, 1.5),
      errorBorder: border(AppColors.error, 1.5),
      focusedErrorBorder: border(AppColors.error, 1.5),
      errorStyle: AppText.small.copyWith(color: AppColors.error),
    ),
  );
}

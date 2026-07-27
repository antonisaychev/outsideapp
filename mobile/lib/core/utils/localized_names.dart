import 'package:flutter/widgets.dart';

/// Справочники (города, категории, страны) двуязычные: name_ru / name_en.
/// Выбираем по текущему языку интерфейса, а не жёстко русский.
String localizedName(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'en' ? en : ru;

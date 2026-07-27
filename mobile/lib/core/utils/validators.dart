import 'package:flutter/services.dart';

/// Пароль: только печатаемые латинские символы ASCII (буквы, цифры, знаки),
/// без пробелов и кириллицы — чтобы нельзя было создать пароль не той
/// раскладкой. При входе не применяется (только при создании пароля).
final RegExp asciiPasswordRe = RegExp(r'^[\x21-\x7E]+$');

/// Фильтр ввода: не даёт напечатать/вставить недопустимые символы.
final TextInputFormatter asciiPasswordInputFilter =
    FilteringTextInputFormatter.allow(RegExp(r'[\x21-\x7E]'));

bool isValidNewPassword(String password) =>
    password.length >= 8 && asciiPasswordRe.hasMatch(password);

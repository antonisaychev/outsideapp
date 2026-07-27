import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// 6 ячеек кода: автофокус, автопереход, вставка кода целиком из буфера
/// (docs/Outside_interactions_spec_v1.md, экран 29). Одно скрытое текстовое
/// поле поверх видимых боксов — так системная вставка работает "из коробки".
class CodeInputField extends StatefulWidget {
  const CodeInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  State<CodeInputField> createState() => CodeInputFieldState();
}

class CodeInputFieldState extends State<CodeInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() {
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = digits.length > 6 ? digits.substring(0, 6) : digits;
    if (trimmed != _controller.text) {
      _controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    setState(() {});
    widget.onChanged?.call(trimmed);
    if (trimmed.length == 6) widget.onCompleted(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _buildBox),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  onChanged: _onChanged,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    final text = _controller.text;
    final char = index < text.length ? text[index] : '';
    final isFocused = index == text.length;
    final borderColor = widget.hasError
        ? AppColors.error
        : (isFocused ? AppColors.coral : AppColors.border);
    return Container(
      width: 44,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: borderColor,
          width: isFocused || widget.hasError ? 1.5 : 1,
        ),
      ),
      child: Text(char, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

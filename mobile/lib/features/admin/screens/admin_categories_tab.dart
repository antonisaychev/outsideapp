import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/admin_api.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/services_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_names.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/admin_providers.dart';
import 'admin_screen.dart';

/// Экраны 42 и 44 «Администрирование · Категории».
class AdminCategoriesTab extends ConsumerWidget {
  const AdminCategoriesTab({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const _NewCategoryDialog(),
    );
    if (result == null || !context.mounted) return;
    try {
      await ref.read(adminApiProvider).createCategory(result.$1, result.$2);
      ref.invalidate(adminCategoriesProvider);
      ref.invalidate(categoriesProvider);
      if (context.mounted) _toast(context, l10n.adminCategoryCreated);
    } on ApiException catch (e) {
      if (context.mounted) {
        _toast(
          context,
          (e.errors?.values.contains('DUPLICATE') ?? false)
              ? l10n.adminCategoryDuplicate
              : l10n.genericError,
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminCategory category,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminDeleteCategoryTitle),
        content: Text(localizedName(context, category.nameRu, category.nameEn)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.adminNo),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.adminYes),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(adminApiProvider).deleteCategory(category.id);
      ref.invalidate(adminCategoriesProvider);
      ref.invalidate(categoriesProvider);
      if (context.mounted) _toast(context, l10n.adminCategoryDeleted);
    } on ApiException catch (e) {
      if (context.mounted) {
        _toast(
          context,
          e.error == 'CATEGORY_IN_USE'
              ? l10n.adminCategoryInUse
              : l10n.genericError,
        );
      }
    }
  }

  void _toast(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: AdminList<AdminCategory>(
            async: ref.watch(adminCategoriesProvider),
            emptyText: l10n.adminEmptyServices,
            onRefresh: () => ref.invalidate(adminCategoriesProvider),
            header: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.adminCategoryDeleteNote,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _create(context, ref),
                    child: Text(l10n.adminCreate),
                  ),
                ],
              ),
            ),
            itemBuilder: (context, category) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedName(
                            context,
                            category.nameRu,
                            category.nameEn,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.adminServicesCount(category.servicesCount),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.error),
                    // пустую категорию удаляем сразу, занятую сервер не отдаст
                    onPressed: () => _delete(context, ref, category),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Экран 44 «Новая категория»: два названия — русское и английское.
class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _ru = TextEditingController();
  final _en = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ru.addListener(() => setState(() {}));
    _en.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ru.dispose();
    _en.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valid = _ru.text.trim().isNotEmpty && _en.text.trim().isNotEmpty;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(l10n.adminNewCategoryTitle)),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ru,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.adminCategoryNameRu),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _en,
            decoration: InputDecoration(hintText: l10n.adminCategoryNameEn),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: valid
              ? () => Navigator.of(
                  context,
                ).pop((_ru.text.trim(), _en.text.trim()))
              : null,
          child: Text(l10n.adminCreate),
        ),
      ],
    );
  }
}

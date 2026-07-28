import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_api.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/models.dart';
import '../../../core/api/services_api.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/providers/services_providers.dart';
import '../providers/admin_providers.dart';

/// Экран 41 «Админ — редактирование сервиса».
/// Правки применяются к любой карточке независимо от статуса.
class AdminServiceEditScreen extends ConsumerStatefulWidget {
  const AdminServiceEditScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<AdminServiceEditScreen> createState() =>
      _AdminServiceEditScreenState();
}

class _AdminServiceEditScreenState
    extends ConsumerState<AdminServiceEditScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _website = TextEditingController();
  final _map = TextEditingController();
  int? _categoryId;
  int? _cityId;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _website.dispose();
    _map.dispose();
    super.dispose();
  }

  /// Поля заполняются один раз — дальше их правит админ
  void _fill(ServiceDetail service) {
    if (_loaded) return;
    _loaded = true;
    _title.text = service.title;
    _description.text = service.description;
    _website.text = service.websiteUrl ?? '';
    _map.text = service.mapUrl ?? '';
    _categoryId = service.categoryId;
    _cityId = service.cityId;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref.read(adminApiProvider).updateService(widget.serviceId, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'website_url': _website.text.trim(),
        'map_url': _map.text.trim(),
        if (_categoryId != null) 'category_id': _categoryId,
        if (_cityId != null) 'city_id': _cityId,
      });
      ref.invalidate(adminServicesProvider);
      ref.invalidate(serviceDetailProvider(widget.serviceId));
      ref.invalidate(servicesListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
      context.pop();
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = ref.watch(serviceDetailProvider(widget.serviceId));
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final cities = ref.watch(citiesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminEditServiceTitle)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: TextButton(
            onPressed: () =>
                ref.invalidate(serviceDetailProvider(widget.serviceId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (service) {
          _fill(service);
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Text(
                  l10n.adminEditServiceNote,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(hintText: l10n.serviceNameHint),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.serviceDescriptionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _website,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: l10n.serviceWebsiteHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _map,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(hintText: l10n.serviceMapHint),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.categorySheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in categories)
                      SelectableChip(
                        selected: _categoryId == c.id,
                        onTap: () => setState(() => _categoryId = c.id),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          localizedName(context, c.nameRu, c.nameEn),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.placeLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in cities)
                      SelectableChip(
                        selected: _cityId == c.id,
                        onTap: () => setState(() => _cityId = c.id),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          localizedName(context, c.nameRu, c.nameEn),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.adminSaveChanges,
                  loading: _saving,
                  onPressed: _title.text.trim().isEmpty ? null : _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

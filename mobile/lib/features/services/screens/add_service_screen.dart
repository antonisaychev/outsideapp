import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/models.dart';
import '../../../core/api/services_api.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/services_providers.dart';

/// Экран 06 «Новая рекомендация»: 1-5 фото (первое — обложка), поля,
/// категория (шторка 40), место, проверка дублей (409 → шторка).
class AddServiceScreen extends ConsumerStatefulWidget {
  const AddServiceScreen({super.key});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _mapController = TextEditingController();

  final List<File> _photos = [];
  int? _categoryId;
  int? _cityId;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _photos.isNotEmpty &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _categoryId != null;

  Future<void> _addPhoto() async {
    if (_photos.length >= 5) return;
    // Сжатие на клиенте до 1280px (ТЗ v5.6 §4)
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _photoMenu(int index) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index != 0)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.makeCover),
                onTap: () {
                  setState(() => _photos.insert(0, _photos.removeAt(index)));
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                l10n.deletePhoto,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                setState(() => _photos.removeAt(index));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final categories = await ref.read(categoriesProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  l10n.categorySheetTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              for (final c in categories)
                ListTile(
                  title: Text(c.nameRu),
                  trailing: _categoryId == c.id
                      ? const Icon(Icons.check, color: AppColors.coral)
                      : null,
                  onTap: () => Navigator.of(context).pop(c.id),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (selected != null) setState(() => _categoryId = selected);
  }

  Future<void> _pickCity() async {
    final l10n = AppLocalizations.of(context)!;
    final cities = await ref.read(citiesProvider.future);
    if (!mounted) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                l10n.placeSheetTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            for (final city in cities)
              ListTile(
                leading: Text(city.flag, style: const TextStyle(fontSize: 24)),
                title: Text(city.nameRu),
                onTap: () => Navigator.of(context).pop(city.id),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _cityId = selected);
  }

  Future<void> _submit({bool force = false}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref
          .read(servicesApiProvider)
          .create(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            categoryId: _categoryId!,
            cityId: _cityId ?? ref.read(viewCityIdProvider),
            websiteUrl: _websiteController.text.trim(),
            mapUrl: _mapController.text.trim(),
            photoPaths: _photos.map((f) => f.path).toList(),
            force: force,
          );
      ref.invalidate(servicesListProvider);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sentForReview)));
    } on DuplicateException catch (e) {
      if (mounted) _showDuplicatesSheet(e.candidates);
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showDuplicatesSheet(List<DuplicateCandidate> candidates) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.duplicateSheetTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              for (final c in candidates)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/services/${c.id}');
                  },
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _submit(force: true);
                },
                child: Text(l10n.addAnyway),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <ServiceCategory>[];
    final cities = ref.watch(citiesProvider).valueOrNull ?? const <City>[];
    final effectiveCityId = _cityId ?? ref.watch(viewCityIdProvider);

    String categoryLabel() {
      for (final c in categories) {
        if (c.id == _categoryId) return c.nameRu;
      }
      return l10n.categoryChip;
    }

    String cityLabel() {
      for (final c in cities) {
        if (c.id == effectiveCityId) return c.nameRu;
      }
      return '';
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addServiceTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addServiceSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < _photos.length; i++) ...[
                      GestureDetector(
                        onLongPress: () => _photoMenu(i),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                              child: Image.file(
                                _photos[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (i == 0)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.coral,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.coverBadge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (_photos.length < 5)
                      GestureDetector(
                        onTap: _addPhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.add, color: AppColors.coral),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.photosCaption,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                maxLength: 100,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.serviceNameHint,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.serviceDescriptionHint,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(hintText: l10n.serviceWebsiteHint),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mapController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(hintText: l10n.serviceMapHint),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SelectableChip(
                    selected: _categoryId != null,
                    onTap: _pickCategory,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(categoryLabel()),
                  ),
                  const SizedBox(width: 12),
                  SelectableChip(
                    selected: false,
                    onTap: _pickCity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(l10n.placeChipPrefix(cityLabel())),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.submitForReview,
                loading: _submitting,
                onPressed: _valid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

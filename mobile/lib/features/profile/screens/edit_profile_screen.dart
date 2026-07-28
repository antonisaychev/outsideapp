import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/api/models.dart';
import '../../../core/api/users_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/countries.dart';
import '../../auth/providers/session_controller.dart';
import '../../dating/providers/dating_providers.dart';

/// Экран 32 «Редактировать профиль».
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;
  int? _cityId;
  String? _homeCountry;
  String? _gender;
  DateTime? _birthDate;
  late List<UserPhoto> _photos;
  bool _submitting = false;
  bool _photoBusy = false;

  static const _maxPhotos = 10;

  MeProfile get _profile => ref.read(sessionControllerProvider).profile!;

  @override
  void initState() {
    super.initState();
    final p = _profile;
    _firstNameController = TextEditingController(text: p.firstName ?? '');
    _lastNameController = TextEditingController(text: p.lastName ?? '');
    _bioController = TextEditingController(text: p.bio ?? '');
    _cityId = p.cityId;
    _homeCountry = p.homeCountry;
    _gender = p.gender;
    _birthDate = p.birthDate != null ? DateTime.tryParse(p.birthDate!) : null;
    _photos = List.of(p.photos);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final p = _profile;
    final origBirth = p.birthDate != null
        ? DateTime.tryParse(p.birthDate!)
        : null;
    return _firstNameController.text.trim() != (p.firstName ?? '') ||
        _lastNameController.text.trim() != (p.lastName ?? '') ||
        _bioController.text.trim() != (p.bio ?? '') ||
        _cityId != p.cityId ||
        _homeCountry != p.homeCountry ||
        _gender != p.gender ||
        _birthDate?.toIso8601String().substring(0, 10) !=
            origBirth?.toIso8601String().substring(0, 10);
  }

  bool get _valid =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty;

  /// Фото применяются сразу, отдельно от кнопки «Сохранить»
  Future<void> _runPhotoAction(
    Future<List<UserPhoto>> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _photoBusy = true);
    try {
      final photos = await action();
      if (mounted) setState(() => _photos = photos);
      await ref.read(sessionControllerProvider.notifier).refreshProfile();
      ref.invalidate(datingProfileProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.error == 'TOO_MANY_PHOTOS'
                  ? l10n.photosLimitReached
                  : l10n.avatarUploadFailed,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked == null) return;
    await _runPhotoAction(
      () => ref.read(usersApiProvider).addPhoto(picked.path),
    );
  }

  /// Тап по фото: сделать главным или удалить
  Future<void> _photoMenu(UserPhoto photo, bool isMain) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMain)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l10n.makeMainPhoto),
                onTap: () => Navigator.of(context).pop('main'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                l10n.deletePhoto,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'main') {
      await _runPhotoAction(
        () => ref.read(usersApiProvider).makeMainPhoto(photo.id),
      );
    } else if (action == 'delete') {
      await _runPhotoAction(
        () => ref.read(usersApiProvider).deletePhoto(photo.id),
      );
    }
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
                title: Text(localizedName(context, city.nameRu, city.nameEn)),
                onTap: () => Navigator.of(context).pop(city.id),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _cityId = selected);
  }

  Future<void> _pickCountry() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CountrySheet(l10n: AppLocalizations.of(context)!),
    );
    if (code != null) setState(() => _homeCountry = code);
  }

  Future<void> _pickGender() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.genderMale),
              onTap: () => Navigator.of(context).pop('male'),
            ),
            ListTile(
              title: Text(l10n.genderFemale),
              onTap: () => Navigator.of(context).pop('female'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _gender = selected);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref.read(sessionControllerProvider.notifier).updateProfile({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        if (_cityId != null) 'city_id': _cityId,
        if (_homeCountry != null) 'home_country': _homeCountry,
        if (_gender != null) 'gender': _gender,
        if (_birthDate != null)
          'birth_date': _birthDate!.toIso8601String().substring(0, 10),
      });
      // Анкета знакомств зависит от фото/пола/даты — её кэш устарел
      ref.invalidate(datingProfileProvider);
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _onExit(bool didPop, Object? result) async {
    if (didPop) return;
    final l10n = AppLocalizations.of(context)!;
    if (!_hasChanges) {
      context.pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.leaveWithoutSaving,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // следим за профилем: фото могли обновиться из другого места
    ref.watch(sessionControllerProvider.select((s) => s.profile?.photos.length));
    final cities = ref.watch(citiesProvider).valueOrNull ?? [];

    String cityName(int? id) {
      for (final c in cities) {
        if (c.id == id) return localizedName(context, c.nameRu, c.nameEn);
      }
      return '';
    }

    String countryLabel(String? code) {
      if (code == null) return '';
      for (final c in allCountries) {
        if (c.code == code) {
          return '${c.flag} ${localizedName(context, c.nameRu, c.nameEn)}';
        }
      }
      return code;
    }

    String birthLabel() {
      if (_birthDate == null) return '';
      final d = _birthDate!;
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: _onExit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.photosLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.photosHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _PhotoGrid(
                  photos: _photos,
                  busy: _photoBusy,
                  canAdd: _photos.length < _maxPhotos,
                  onAdd: _addPhoto,
                  onTapPhoto: _photoMenu,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _firstNameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(hintText: l10n.firstNameHint),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(hintText: l10n.lastNameHint),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  maxLines: null,
                  maxLength: 300,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.bioHint,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 8),
                _PickerRow(
                  label: l10n.placeLabel,
                  value: cityName(_cityId),
                  onTap: _pickCity,
                ),
                _PickerRow(
                  label: l10n.countryLabel,
                  value: countryLabel(_homeCountry),
                  onTap: _pickCountry,
                ),
                _PickerRow(
                  label: l10n.genderLabel,
                  value: _gender == 'male'
                      ? l10n.genderMale
                      : _gender == 'female'
                      ? l10n.genderFemale
                      : '',
                  onTap: _pickGender,
                ),
                _PickerRow(
                  label: l10n.birthDateLabel,
                  value: birthLabel(),
                  onTap: _pickBirthDate,
                ),
              ],
            ),
          ),
        ),
        // Кнопка закреплена снизу: в скролле её перекрывала системная зона
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: PrimaryButton(
            label: l10n.save,
            loading: _submitting,
            onPressed: _hasChanges && _valid ? _save : null,
          ),
        ),
      ),
    );
  }
}

/// Сетка фото профиля: до 10 штук, первое — главное
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.busy,
    required this.canAdd,
    required this.onAdd,
    required this.onTapPhoto,
  });

  final List<UserPhoto> photos;
  final bool busy;
  final bool canAdd;
  final VoidCallback onAdd;
  final void Function(UserPhoto photo, bool isMain) onTapPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < photos.length; i++)
          GestureDetector(
            onTap: busy ? null : () => onTapPhoto(photos[i], i == 0),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: CachedNetworkImage(
                      imageUrl: absoluteFileUrl(photos[i].url),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.surface),
                      errorWidget: (context, url, error) =>
                          Container(color: AppColors.surface),
                    ),
                  ),
                  if (i == 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.mainPhotoBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (canAdd)
          GestureDetector(
            onTap: busy ? null : onAdd,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: AppColors.border),
              ),
              child: busy
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(
                      Icons.add,
                      size: 28,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.l10n});
  final AppLocalizations l10n;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = allCountries
        .where(
          (c) =>
              c.nameRu.toLowerCase().contains(_query.toLowerCase()) ||
              c.nameEn.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: widget.l10n.searchCountry,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final c = filtered[index];
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(localizedName(context, c.nameRu, c.nameEn)),
                    onTap: () => Navigator.of(context).pop(c.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

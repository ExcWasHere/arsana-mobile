import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/services/product_tour_service.dart';
import '../../core/services/product_tour_step.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/product_tour_dialog.dart';
import 'pin_setup_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const routeName = '/profile-setup';

  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _schoolController = TextEditingController();
  final _formFieldsKey = GlobalKey();
  DateTime? _birthDate;
  int? _selectedGrade;
  bool _isLoading = false;

  static const _gradeOptions = [1, 2, 3, 4, 5, 6];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProductTourDialog.showIfNeeded(
        context,
        tourKey: 'profile_setup_tour',
        store: ProductTourService.instance,
        steps: [
          const ProductTourStep(
            videoAssetPath: 'assets/videos/Script3.mov',
            title: 'Lengkapi Data Dirimu',
          ),
          ProductTourStep(
            videoAssetPath: 'assets/videos/Script3.mov',
            title: 'Isi Data di Sini',
            targetKey: _formFieldsKey,
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi')),
      );
      return;
    }
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas wajib dipilih')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post('/profile', {
        'fullName': _nameController.text.trim(),
        'birthDate': _birthDate!.toIso8601String(),
        'city': _cityController.text.trim(),
        'school': _schoolController.text.trim(),
        'grade': _selectedGrade,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal simpan profil, coba lagi ya')),
        );
        return;
      }

      await AuthStorageService.instance.setProfileComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PinSetupScreen.routeName);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _birthDate == null
        ? 'Pilih tanggal lahir'
        : DateFormat('d MMMM yyyy', 'id_ID').format(_birthDate!);

    return Scaffold(
      appBar: AppBar(),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lengkapi profil kamu', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 6),
                  Text(
                    'Data ini bantu kami sesuaikan pengalaman belajarmu',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  Column(
                    key: _formFieldsKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickBirthDate,
                        borderRadius: BorderRadius.circular(14),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal lahir',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          child: Text(dateLabel),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Kota asal',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Kota asal wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _schoolController,
                        decoration: const InputDecoration(
                          labelText: 'Asal sekolah',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Asal sekolah wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        items: _gradeOptions
                            .map(
                              (grade) => DropdownMenuItem(
                                value: grade,
                                child: Text('Kelas $grade SD'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedGrade = value),
                        validator: (v) =>
                            v == null ? 'Kelas wajib dipilih' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Lanjut'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
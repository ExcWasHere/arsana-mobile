import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
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
  DateTime? _birthDate;
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    // TODO: kirim data profil (nama, tgl lahir, kota, sekolah) ke backend
    await Future.delayed(const Duration(milliseconds: 600));
    await AuthStorageService.instance.setProfileComplete(true);

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(PinSetupScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _birthDate == null
        ? 'Pilih tanggal lahir'
        : DateFormat('d MMMM yyyy', 'id_ID').format(_birthDate!);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Kota asal wajib diisi' : null,
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
    );
  }
}
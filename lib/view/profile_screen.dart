import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/utils/app_textstyles.dart';
import 'package:get/get.dart';
import 'package:wolvystore/view/home_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = false;
  String? _imagePath;
  String? _errorMsg;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMsg = 'Pengguna tidak ditemukan. Silakan login ulang.';
      });
      return;
    }

    userEmail = user.email;

    final data =
        await supabase
            .from('user_acc')
            .select()
            .eq('email', userEmail!)
            .maybeSingle();

    if (data != null) {
      setState(() {
        _namaController.text = data['nama'] ?? '';
        _noHpController.text = data['no_hp'] ?? '';
        _alamatController.text = data['alamat_kirim'] ?? '';
        _imagePath = data['foto_profil'];
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    Navigator.pop(context, image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    Navigator.pop(context, image);
                  },
                ),
              ],
            ),
          ),
    );

    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? uploadedImageUrl = _imagePath;

    if (_imagePath != null && !_imagePath!.startsWith('http')) {
      try {
        final file = File(_imagePath!);
        final fileBytes = await file.readAsBytes();
        final fileName = 'foto-${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('fotoprofil')
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: const FileOptions(upsert: true),
            );

        uploadedImageUrl = supabase.storage
            .from('fotoprofil')
            .getPublicUrl(fileName);
      } catch (e) {
        setState(() {
          _errorMsg = 'Gagal mengunggah foto: $e';
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await supabase
          .from('user_acc')
          .update({
            'nama': _namaController.text.trim(),
            'no_hp': _noHpController.text.trim(),
            'alamat_kirim': _alamatController.text.trim(),
            'foto_profil': uploadedImageUrl,
          })
          .eq('email', userEmail!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      setState(() => _errorMsg = 'Gagal memperbarui profil: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              width: double.infinity,
              color: accentColor,
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.offAll(() => const HomeWrapper()),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Profil',
                    style: AppTextstyles.withColor(
                      AppTextstyles.h3,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                userEmail == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage:
                                        _imagePath != null
                                            ? _imagePath!.startsWith('http')
                                                ? NetworkImage(_imagePath!)
                                                : FileImage(File(_imagePath!))
                                                    as ImageProvider
                                            : null,
                                    backgroundColor: Colors.grey[300],
                                    child:
                                        _imagePath == null
                                            ? const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildTextField(
                              controller: _namaController,
                              label: 'Nama Lengkap',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: TextEditingController(
                                text: userEmail,
                              ),
                              label: 'Email',
                              icon: Icons.email_outlined,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _noHpController,
                              label: 'Nomor Telepon',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _alamatController,
                              label: 'Alamat Pengiriman',
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 32),
                            if (_errorMsg != null)
                              Text(
                                _errorMsg!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        )
                                        : const Text(
                                          'Simpan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

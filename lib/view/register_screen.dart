import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/utils/app_textstyles.dart';
import 'package:wolvystore/view/login_screen.dart';
import 'package:wolvystore/view/home_wrapper.dart';
import 'package:wolvystore/utils/session_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _noHpController.text = '+62-';
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final noHpRaw = _noHpController.text.trim();

    String noHpDigitsOnly = noHpRaw.replaceAll(RegExp(r'\D'), '');
    if (noHpDigitsOnly.startsWith('62')) {
      noHpDigitsOnly = noHpDigitsOnly.substring(2);
    }

    try {
      final existingEmail =
          await supabase
              .from('user_acc')
              .select()
              .eq('email', email)
              .maybeSingle();
      if (existingEmail != null) {
        setState(() {
          _errorMsg = 'Email sudah terdaftar. Gunakan email lain.';
          _isLoading = false;
        });
        return;
      }

      final existingHp =
          await supabase
              .from('user_acc')
              .select()
              .eq('no_hp', noHpDigitsOnly)
              .maybeSingle();
      if (existingHp != null) {
        setState(() {
          _errorMsg = 'Nomor HP sudah terdaftar. Gunakan nomor lain.';
          _isLoading = false;
        });
        return;
      }

      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        setState(() {
          _errorMsg = 'Gagal mendaftar ke Supabase Auth';
          _isLoading = false;
        });
        return;
      }

      final uid = authResponse.user!.id;

      await supabase.from('user_acc').insert({
        'uid': uid,
        'nama': nama,
        'email': email,
        'no_hp': noHpDigitsOnly,
        'foto_profil': null,
        'password': hashPassword(password),
      });

      await SessionManager.saveSession(uid: uid, email: email);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeWrapper()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal mendaftar: ${e.toString()}';
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFFFFFFF);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);
    final inputColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFA6E3E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Daftar',
                  style: AppTextstyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mari Buat Akun mu",
                  style: AppTextstyles.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 220,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      controller: _namaController,
                      fillColor: inputColor,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: inputColor,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Email wajib diisi';
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(val.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      fillColor: inputColor,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Password wajib diisi';
                        if (val.length < 6) return 'Minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'No HP',
                      icon: Icons.phone_android,
                      controller: _noHpController,
                      keyboardType: TextInputType.phone,
                      fillColor: inputColor,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Nomor HP wajib diisi';
                        if (!val.startsWith('+62-'))
                          return 'Nomor harus diawali dengan +62-';
                        final digits = val.replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 10 || digits.length > 14)
                          return 'Nomor HP tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Daftar',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMsg!,
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah Memiliki Akun?",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Masuk",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
    Color? fillColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

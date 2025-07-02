import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/utils/app_textstyles.dart';
import 'package:wolvystore/view/register_screen.dart';
import 'package:wolvystore/utils/session_manager.dart';
import 'package:wolvystore/view/home_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  final supabase = Supabase.instance.client;

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final email = _emailController.text.trim();
      final rawPassword = _passwordController.text.trim();
      final hashedPassword = hashPassword(rawPassword);

      final authRes = await supabase.auth.signInWithPassword(
        email: email,
        password: rawPassword,
      );

      if (authRes.user == null) {
        setState(() {
          _errorMsg = 'Gagal login ke Supabase Auth.';
        });
        return;
      }

      final uid = authRes.user!.id;

      final userRes =
          await supabase
              .from('user_acc')
              .select('uid')
              .eq('email', email)
              .eq('password', hashedPassword)
              .maybeSingle();

      if (userRes == null || userRes['uid'] != uid) {
        setState(() {
          _errorMsg = 'Email atau password salah.';
        });
        return;
      }

      await SessionManager.saveSession(uid: uid, email: email);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeWrapper()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMsg = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final inputColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFA6E3E9);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);

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
                  'Masuk',
                  style: AppTextstyles.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Selamat Datang Kembali, Silakan Masuk",
                  style: AppTextstyles.body.copyWith(color: Colors.white70),
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
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Password wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginUser,
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
                                  'Masuk Sekarang',
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
                          "Belum memiliki akun?",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Daftar sekarang",
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

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/utils/app_textstyles.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  final supabase = Supabase.instance.client;

  /// Hash password dengan SHA256
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final hashedPassword = hashPassword(newPassword);

    try {
      final userRes =
          await supabase
              .from('user_acc')
              .select('uid')
              .eq('email', email)
              .maybeSingle();

      if (userRes == null || userRes['uid'] == null) {
        setState(() {
          _errorMsg = 'Email tidak ditemukan di sistem.';
          _isLoading = false;
        });
        return;
      }

      final uid = userRes['uid'];

      await supabase
          .from('user_acc')
          .update({'password': hashedPassword})
          .eq('uid', uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diperbarui. Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: AppTextstyles.withColor(
                    AppTextstyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email terdaftar dan password baru kamu',
                  style: AppTextstyles.withColor(
                    AppTextstyles.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(val)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (val.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Text(
                              'Perbarui Password',
                              style: AppTextstyles.withColor(
                                AppTextstyles.buttonMedium,
                                Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMsg != null)
                  Text(_errorMsg!, style: TextStyle(color: Colors.red[400])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

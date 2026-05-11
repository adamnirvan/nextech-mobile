import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reset_password_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLoginMode = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: isPassword,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: colorScheme.onSurface.withOpacity(0.5),
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        isDense: true, 
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 45),
              Image.asset(
                'assets/icon/nextech_logo_black.png',
                height: 30,
                fit: BoxFit.contain,
                color: colorScheme.onSurface,
              ),

              const SizedBox(height: 50),
              Text(
                isLoginMode ? "Login to your account" : "Create an account",
                style: AppText.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              //SLIDER TOGGLE
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => isLoginMode = true,
                        ), // Ubah ingatan jadi Login
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isLoginMode
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Login",
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isLoginMode
                                  ? colorScheme.onPrimary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => isLoginMode = false,
                        ), // Ubah ingatan jadi Register
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isLoginMode
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Register",
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: !isLoginMode
                                  ? colorScheme.onPrimary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- LOGIKA PEMANGGILAN FORM (AKTOR) ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('login'),
      children: [
        // Menggunakan helper custom text field
        _buildCustomTextField(
          controller: _emailController,
          hint: "E-mail address",
          icon: Icons.email_rounded,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _passwordController,
          hint: "Password",
          icon: Icons.lock_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 8),

        // --- TOMBOL FORGOT PASSWORD ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              );
            },
            child: Text(
              "Forgot password?",
              style: AppText.body.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- TOMBOL SIGN IN ---
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              backgroundColor: colorScheme.onSurface,
            ),

            // LOGIKA ROUTING BERDASARKAN ROLE
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      _isLoading = true; // Nyalakan loading
                    });

                    try {
                      // 1. Auth ke Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                      // 2. Ambil data user dari Firestore berdasarkan UID
                      DocumentSnapshot userDoc = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .get();

                      String role = 'customer'; // Default role

                      // 3. Cek apakah dokumennya ada dan baca role-nya
                      if (userDoc.exists) {
                        final data = userDoc.data() as Map<String, dynamic>;
                        role = data['role'] ?? 'customer';
                      }

                      if (!mounted) return;

                      // 4. PENGKONDISIAN NAVIGASI (HIDDEN ADMIN MODE)
                      if (role == 'admin') {
                        // Jika Admin, lempar ke rute Admin Main
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.adminMain,
                        );
                      } else {
                        // Jika Customer biasa, lempar ke Main (Home) seperti biasa
                        Navigator.pushReplacementNamed(context, AppRoutes.main);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message ?? "Login gagal. Coba lagi!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false; // Matikan loading
                        });
                      }
                    }
                  },

            // Ubah teks jadi spinner jika sedang loading
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Login",
                    style: AppText.body.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('register'),
      children: [
        // Menggunakan helper custom text field
        _buildCustomTextField(
          controller: _nameController,
          hint: "Full Name",
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _emailController,
          hint: "E-mail address",
          icon: Icons.email_rounded,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _passwordController,
          hint: "Password",
          icon: Icons.lock_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 32),

        // --- TOMBOL SIGN UP ---
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty ||
                  _emailController.text.trim().isEmpty ||
                  _passwordController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All fields must be filled!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set({
                      'name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'role': 'customer',
                      'created_at': FieldValue.serverTimestamp(),
                    });

                if (!mounted) return;

                await FirebaseAuth.instance.signOut();
                _nameController.clear();
                _passwordController.clear();

                setState(() {
                  isLoginMode = true;
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Registrasi berhasil! Silakan Login."),
                    backgroundColor: Colors.green,
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Gagal mendaftar!"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },

            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Sign Up",
              style: AppText.body.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

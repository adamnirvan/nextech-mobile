import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLoginMode = true;
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
                  borderRadius: BorderRadius.circular(12),
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
              // AnimatedSwitcher: Memberikan efek fade saat berganti form
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
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "E-mail address",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.email_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.lock_rounded),
          ),
        ),
        const SizedBox(height: 8),

        // --- TOMBOL FORGOT PASSWORD ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
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
            // Menambahkan style untuk mengubah warna
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              backgroundColor: colorScheme.onSurface,
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, AppRoutes.main);
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Login gagal. Coba lagi!"),
                  ),
                );
              }
            },

            child: Text(
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
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Full Name",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "E-mail address",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.lock),
          ),
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
                    content: Text("All field must be fill!"),
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
                  SnackBar(content: Text(e.message ?? "Gagal mendaftar!"),
                  backgroundColor: Colors.red,),
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

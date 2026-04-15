import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:nextech_mobile/core/theme/app_text.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // ==========================================
  // STATE (INGATAN APLIKASI)
  // ==========================================
  // isLoginMode: Penentu apakah layar menampilkan Login (true) atau Register (false)
  bool isLoginMode = true;

  // Controller: Bertugas menangkap teks yang diketik user di dalam kotak input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // dispose: Wajib ada untuk "membuang" controller saat halaman ditutup
  // Tujuannya agar aplikasi tidak bocor memori (Memory Leak) dan lemot
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ==========================================
  // 1. MAIN BUILD (SI SUTRADARA)
  // Tugas: Menyusun kerangka halaman dan mengatur form mana yang tampil
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // SafeArea: Agar tampilan tidak tertutup "poni" kamera HP
      body: SafeArea(
        // SingleChildScrollView: Agar layar bisa di-scroll saat keyboard HP muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Bikin elemen melebar penuhi layar
            children: [
              const SizedBox(height: 45),

              // --- HEADER (Judul & Subjudul) ---
              Image.asset(
                'assets/icon/nextech_logo_black.png', // Ganti dengan lokasi dan nama file logomu!
                height:
                    30, // Atur tingginya di sini biar nggak kebesaran/kekecilan
                fit: BoxFit.contain,
                color: colorScheme.onSurface 
              ),

              const SizedBox(height: 50),
              Text(
                isLoginMode ? "Login to your account" : "Create an account",
                style: AppText.heading2, 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- SLIDER TOGGLE (Tombol ganti mode) ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      Colors.grey.shade100, // Warna background lintasan slider
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Tombol Kiri: Login
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
                              color: isLoginMode ? colorScheme.onPrimary : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tombol Kanan: Register
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
                              color: !isLoginMode ? colorScheme.onPrimary : Colors.grey,
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
                child: isLoginMode
                    ? _buildLoginForm(context)
                    : _buildRegisterForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. AKTOR: FORM LOGIN
  // Tugas: Menampilkan kotak Email, Password, dan tombol Sign In
  // ==========================================
  Widget _buildLoginForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey(
        'login',
      ), // Key ini wajib agar AnimatedSwitcher tahu form telah berubah
      children: [

      TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText:  "E-mail address",
            hintStyle: AppText.body.copyWith(
              color: colorScheme.onSurface, 
              fontSize: 15
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
              fontSize: 15
            ),
            prefixIcon: Icon(Icons.lock_rounded),
          ),
        ), 
        const SizedBox(height: 8),

        // --- TOMBOL FORGOT PASSWORD ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed:
                () {
                  print("Tombol forgot password diklik");
                }, 
            child: Text(
              "Forgot password?",
              style: AppText.body.copyWith(
                color: colorScheme.onSurface
              ),
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
                borderRadius: BorderRadiusGeometry.circular(8)
              ),
              backgroundColor: colorScheme.onSurface
       // Menggunakan warna custom Anda
            ),
            onPressed: () {
              if (_emailController.text.toLowerCase().contains("admin")) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminDashboard,
                );
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.main);
              }
            },
            child: Text(
              "Login",
              style: AppText.body.copyWith(
                color : colorScheme.onPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.bold
                
              ),
              ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. AKTOR: FORM REGISTER
  // Tugas: Menampilkan kotak Nama, Email, Password, dan tombol Sign Up
  // ==========================================

  // ==========================================
  // 4. TUKANG JAHIT: CUSTOM INPUT
  // Tugas: Fungsi "cetakan" agar desain TextField rapi, seragam, dan kodenya tidak diulang-ulang
  // ==========================================
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
              fontSize: 15
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
              fontSize: 15
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
              fontSize: 15
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
            onPressed: () {
              setState(() {
                isLoginMode = true;
              });
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              )
            ),
            child: Text(
              "Sign Up",
              style: AppText.body.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.bold
              ),
              ),
          ),
        ),
      ],
    );
  }
}
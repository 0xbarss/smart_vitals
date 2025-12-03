import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo or Icon (Optional, added for visual balance like the React mock)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, size: 40, color: Color(0xFF2563EB)),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                "Welcome to SmartVitals",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, // text-3xl approx
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // text-gray-800
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                "Monitor your health metrics, track vitals, and get personalized insights.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600, // text-gray-600
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // --- BUTTONS ---

              // Login Button (Solid Blue)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(RouteNames.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // bg-blue-600
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // rounded-2xl
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Create Account Button (Outlined)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.goNamed(RouteNames.register),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2563EB), // text-blue-600
                    side: const BorderSide(color: Color(0xFF2563EB), width: 2), // border-2 border-blue-600
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // rounded-2xl
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
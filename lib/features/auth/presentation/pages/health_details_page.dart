import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../widgets/auth_field.dart';

class HealthDetailsPage extends StatefulWidget {
  const HealthDetailsPage({super.key});

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onCompleteSetup() {
    context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
      body: Column(
        children: [
          // --- HEADER (Matches TSX Gradient) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF9333EA)], // Blue to Purple
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                ]
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Let's get to know you better",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- BODY ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Inputs
                  AuthField(
                    controller: _ageController,
                    hintText: "Age",
                    icon: Icons.calendar_today,
                  ),
                  AuthField(
                    controller: _weightController,
                    hintText: "Weight (kg)",
                    icon: Icons.monitor_weight_outlined,
                  ),

                  const SizedBox(height: 20),

                  // Complete Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onCompleteSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // bg-blue-600
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Complete Setup",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
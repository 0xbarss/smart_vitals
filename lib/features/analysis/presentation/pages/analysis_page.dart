import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isHighContrast = settings.highContrast;

        return Scaffold(
          backgroundColor: isHighContrast ? Colors.black : const Color(0xFFF9FAFB),
          body: Column(
            children: [
              // --- HEADER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: BoxDecoration(
                  color: isHighContrast ? Colors.black : null,
                  gradient: isHighContrast
                      ? null
                      : const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  border: isHighContrast ? const Border(bottom: BorderSide(color: Colors.white, width: 2)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Health Risk Analysis",
                      style: TextStyle(
                          color: isHighContrast ? Colors.yellowAccent : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "AI-driven insights based on your data",
                      style: TextStyle(
                          color: isHighContrast ? Colors.white : Colors.white70,
                          fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),

              // --- CONTENT ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildRiskCard(
                        condition: "Type 2 Diabetes", percentage: 15, riskLevel: "Low", color: Colors.green, isHighContrast: isHighContrast
                    ),
                    _buildRiskCard(
                        condition: "Hypertension", percentage: 45, riskLevel: "Moderate", color: Colors.orange, isHighContrast: isHighContrast
                    ),
                    _buildRiskCard(
                        condition: "Heart Disease", percentage: 20, riskLevel: "Low", color: Colors.green, isHighContrast: isHighContrast
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskCard({
    required String condition, required int percentage, required String riskLevel, required MaterialColor color, required bool isHighContrast,
  }) {
    // Dynamic Colors
    final bgColor = isHighContrast ? Colors.black : color.shade50;
    final borderColor = isHighContrast ? Colors.white : color.shade100;
    final titleColor = isHighContrast ? Colors.white : const Color(0xFF1F2937);
    final percentColor = isHighContrast ? Colors.yellowAccent : color.shade700;
    final descColor = isHighContrast ? Colors.white70 : color.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(condition, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
              Text("$percentage%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: percentColor)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: isHighContrast ? Colors.grey[800] : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(isHighContrast ? Colors.yellowAccent : color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: descColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  riskLevel == "Low" ? "Your current indicators show minimal risk." : "Some factors may increase risk.",
                  style: TextStyle(fontSize: 12, color: descColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
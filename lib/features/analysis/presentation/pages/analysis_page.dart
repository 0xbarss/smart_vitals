import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
          backgroundColor: isHighContrast ? Colors.black : const Color(
              0xFFF9FAFB),
          body: Column(
            children: [
              _buildHeader(isHighContrast),

              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is Authenticated) {
                      final user = authState.user;

                      final double diabetesScore = user.diabetesRiskScore ??
                          0.0;
                      final double hyperScore = user.hypertensionRiskScore ??
                          0.0;
                      final double heartScore = user.heartRiskScore ?? 0.0;

                      return ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildRiskCard(
                            condition: "Type 2 Diabetes",
                            percentage: diabetesScore.round(),
                            isHighContrast: isHighContrast,
                          ),
                          _buildRiskCard(
                            condition: "Hypertension",
                            percentage: hyperScore.round(),
                            isHighContrast: isHighContrast,
                          ),
                          _buildRiskCard(
                            condition: "Heart Attack",
                            percentage: heartScore.round(),
                            isHighContrast: isHighContrast,
                          ),
                          const SizedBox(height: 20),
                          _buildAIShowcaseTile(isHighContrast),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isHighContrast) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast
            ? null
            : const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: isHighContrast ? const Border(
            bottom: BorderSide(color: Colors.white, width: 2)) : null,
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
            "AI-driven insights based on your bio-data",
            style: TextStyle(
                color: isHighContrast ? Colors.white : Colors.white70,
                fontSize: 14
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard({
    required String condition,
    required int percentage,
    required bool isHighContrast,
  }) {
    MaterialColor color;
    String riskLevel;
    String recommendation;

    if (percentage < 30) {
      color = Colors.green;
      riskLevel = "Low Risk";
      recommendation = "Your current indicators show minimal risk.";
    } else if (percentage < 60) {
      color = Colors.orange;
      riskLevel = "Moderate Risk";
      recommendation = "Some factors may increase risk. Monitor your glucose.";
    } else {
      color = Colors.red;
      riskLevel = "High Risk";
      recommendation = "Significant indicators detected. Consult a physician.";
    }

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(condition, style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor)),
                  Text(riskLevel, style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: percentColor)),
                ],
              ),
              Text("$percentage%", style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: percentColor)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: isHighContrast ? Colors.grey[900] : Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isHighContrast ? Colors.yellowAccent : color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: percentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation,
                  style: TextStyle(fontSize: 12,
                      color: descColor,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAIShowcaseTile(bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.grey[900] : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isHighContrast ? Border.all(color: Colors.white24) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.memory,
              color: isHighContrast ? Colors.yellowAccent : Colors.deepPurple),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Powered by XGBoost Machine Learning model trained on clinical data.",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
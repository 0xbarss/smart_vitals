import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/vital_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isSensorConnected = false;

  void _toggleSensor() {
    setState(() => isSensorConnected = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pulse Sensor Connected via Bluetooth!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
              ]
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red.shade600),
              ),
              const SizedBox(height: 20),

              const Text(
                  "Emergency Alert",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))
              ),
              const SizedBox(height: 8),

              Text(
                "Broadcasting location and vitals to emergency contacts.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Calling 112..."), backgroundColor: Colors.red)
                    );
                  },
                  child: const Text("Call 112", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHighContrast = settings.highContrast;

        final Color bgColor = isHighContrast ? Colors.black : const Color(0xFFF9FAFB);
        final Color textColor = isHighContrast ? Colors.yellowAccent : const Color(0xFF1F2937);
        final Color cardColor = isHighContrast ? Colors.black : Colors.white;
        final Color borderColor = isHighContrast ? Colors.white : Colors.transparent;

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              _buildHeader(isHighContrast),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSensorButton(isHighContrast),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Vitals",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Icon(Icons.arrow_forward, size: 20, color: isHighContrast ? Colors.white : Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildVitalsGrid(isHighContrast),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Goals",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Text(
                          "Manage",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isHighContrast ? Colors.white : Colors.blue.shade600
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGoalsList(cardColor, borderColor, textColor, isHighContrast),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isHighContrast) {
    final authState = context.read<AuthBloc>().state;
    String userName = "User";

    if (authState is Authenticated) {
      userName = authState.user.name ?? "User";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast
            ? null
            : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: isHighContrast ? const Border(bottom: BorderSide(color: Colors.white, width: 2)) : null,
        boxShadow: isHighContrast ? null : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: isHighContrast ? Colors.yellowAccent : Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              Text(
                "SmartVitals",
                style: TextStyle(
                    color: isHighContrast ? Colors.yellowAccent : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),

              GestureDetector(
                onTap: _showSOSDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(20),
                    border: isHighContrast ? Border.all(color: Colors.white) : null,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: isHighContrast ? Colors.black : Colors.white,
                  shape: BoxShape.circle,
                  border: isHighContrast ? Border.all(color: Colors.white) : null,
                ),
                child: Icon(Icons.person, color: isHighContrast ? Colors.yellowAccent : const Color(0xFF2563EB), size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${userName.split(' ')[0]}",
                    style: TextStyle(
                        color: isHighContrast ? Colors.white : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Overall Health Score: 85/100",
                    style: TextStyle(
                        color: isHighContrast ? Colors.yellowAccent : Colors.white70,
                        fontSize: 14
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSensorButton(bool isHighContrast) {
    return GestureDetector(
      onTap: _toggleSensor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isHighContrast
              ? Colors.black
              : (isSensorConnected ? const Color(0xFFECFDF5) : Colors.white),
          border: Border.all(
            color: isHighContrast
                ? (isSensorConnected ? Colors.greenAccent : Colors.white)
                : (isSensorConnected ? const Color(0xFF10B981) : const Color(0xFFBFDBFE)),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth,
              color: isHighContrast
                  ? (isSensorConnected ? Colors.greenAccent : Colors.yellowAccent)
                  : (isSensorConnected ? const Color(0xFF047857) : const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 8),
            Text(
              isSensorConnected ? "Sensor Connected" : "Connect Pulse Sensor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighContrast
                    ? (isSensorConnected ? Colors.greenAccent : Colors.yellowAccent)
                    : (isSensorConnected ? const Color(0xFF047857) : const Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid(bool isHighContrast) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        VitalCard(
          title: "Heart Rate", value: "72", unit: "bpm",
          icon: Icons.favorite, iconBgColor: Colors.red, iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () => context.goNamed(RouteNames.metricDetail),
        ),
        VitalCard(
          title: "Blood Pressure", value: "120/80", unit: "mmHg",
          icon: Icons.show_chart, iconBgColor: Colors.blue, iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
        VitalCard(
          title: "Blood Sugar", value: "95", unit: "mg/dL",
          icon: Icons.water_drop, iconBgColor: Colors.purple, iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
        VitalCard(
          title: "Step Count", value: "8,547", unit: "steps",
          icon: Icons.directions_walk, iconBgColor: Colors.green, iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGoalsList(Color cardColor, Color borderColor, Color textColor, bool isHighContrast) {
    return Column(
      children: [
        _buildGoalItem("Daily Calories", "2150", "2000 kcal", 1.0, Colors.orange, cardColor, borderColor, textColor, isHighContrast),
        _buildGoalItem("Body Fat", "22", "18 %", 0.7, Colors.purple, cardColor, borderColor, textColor, isHighContrast),
        _buildGoalItem("Water Intake", "6", "8 glasses", 0.75, Colors.blue, cardColor, borderColor, textColor, isHighContrast),
      ],
    );
  }

  Widget _buildGoalItem(String label, String current, String target, double progress, Color color, Color bgColor, Color borderColor, Color textColor, bool isHighContrast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isHighContrast ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              Text("$current / $target", style: TextStyle(fontSize: 12, color: isHighContrast ? Colors.white70 : Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isHighContrast ? Colors.grey[800] : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(isHighContrast ? Colors.yellowAccent : color),
              minHeight: 8,
            ),
          )
        ],
      ),
    );
  }
}
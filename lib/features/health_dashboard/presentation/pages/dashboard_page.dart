import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../../../injection_container.dart' as di;
import '../../../../config/routes/route_names.dart';
import '../../../../core/services/step_counter_service.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../widgets/vital_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isSensorConnected = false;
  String stepCount = "0";
  late StepCounterService _stepService;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _stepService = di.sl<StepCounterService>();

    _loadStepsFromFirestore();

    _initSteps();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _fetchSteps(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initSteps() async {
    bool permitted = await _stepService.requestPermissions();
    if (permitted) {
      await _fetchSteps();
    }
  }

  Future<void> _loadStepsFromFirestore() async {
    try {
      final healthRepo = di.sl<HealthRepository>();

      int savedSteps = await healthRepo.getDailySteps(DateTime.now());

      if (savedSteps > 0 && mounted) {
        debugPrint("Loaded cached steps: $savedSteps");
        setState(() {
          stepCount = savedSteps.toString();
        });
      }
    } catch (e) {
      debugPrint("Error loading cached steps: $e");
    }
  }

  Future<void> _fetchSteps() async {
    int liveSteps = await _stepService.getTodaySteps();

    int currentUiSteps = int.tryParse(stepCount.replaceAll(',', '')) ?? 0;

    if (liveSteps > currentUiSteps) {
      if (mounted) {
        setState(() {
          stepCount = liveSteps.toString();
        });
        _saveStepsToCloud(liveSteps);
      }
    }
  }

  Future<void> _saveStepsToCloud(int steps) async {
    final healthRepo = di.sl<HealthRepository>();
    await healthRepo.saveDailySteps(steps);
  }

  void _toggleSensor() {
    setState(() => isSensorConnected = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pulse Sensor Connected via Bluetooth!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  Future<void> _sendEmergencyEmail() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final email = authState.user.emergencyEmail;
      final name = authState.user.name;

      if (email == null || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Emergency Email set in Settings!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
        query: _encodeQueryParameters(<String, String>{
          'subject': 'URGENT: SOS Alert from $name',
          'body':
              'Emergency Alert!\n\nUser $name has triggered an SOS.\n\nCurrent Status:\n- Heart Rate: 72 bpm\n- Blood Pressure: 120/80\n\nPlease contact them immediately or call emergency services.\n\nSent from SmartVitals App.',
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not launch email app"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.red.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.red,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Emergency Alert",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    FlutterRingtonePlayer().playNotification(
                      looping: false,
                      volume: 1.0,
                      asAlarm: false,
                    );
                    _sendEmergencyEmail();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Calling 112..."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: const Text(
                    "Call 112",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getModeGradient(AppMode mode) {
    switch (mode) {
      case AppMode.sports:
        return [const Color(0xFFEA580C), const Color(0xFFC2410C)];
      case AppMode.sleep:
        return [const Color(0xFF312E81), const Color(0xFF1E1B4B)];
      case AppMode.normal:
        return [const Color(0xFF2563EB), const Color(0xFF4F46E5)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHighContrast = settings.highContrast;
        final AppMode currentMode = settings.appMode;

        final Color bgColor = isHighContrast
            ? Colors.black
            : const Color(0xFFF9FAFB);
        final Color textColor = isHighContrast
            ? Colors.yellowAccent
            : const Color(0xFF1F2937);
        final Color cardColor = isHighContrast ? Colors.black : Colors.white;
        final Color borderColor = isHighContrast
            ? Colors.white
            : Colors.transparent;

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              _buildHeader(isHighContrast, currentMode),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildModeSelector(currentMode, isHighContrast),
                    const SizedBox(height: 24),

                    _buildSensorButton(isHighContrast),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Vitals",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: isHighContrast ? Colors.white : Colors.grey,
                        ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Manage",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isHighContrast
                                ? Colors.white
                                : Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGoalsList(
                      cardColor,
                      borderColor,
                      textColor,
                      isHighContrast,
                    ),
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

  Widget _buildModeSelector(AppMode currentMode, bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighContrast ? Border.all(color: Colors.white) : null,
        boxShadow: isHighContrast
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
      ),
      child: Row(
        children: [
          _buildModeBtn(
            AppMode.normal,
            "Normal",
            Icons.person,
            currentMode,
            isHighContrast,
          ),
          _buildModeBtn(
            AppMode.sports,
            "Sports",
            Icons.directions_run,
            currentMode,
            isHighContrast,
          ),
          _buildModeBtn(
            AppMode.sleep,
            "Sleep",
            Icons.bedtime,
            currentMode,
            isHighContrast,
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(
    AppMode mode,
    String label,
    IconData icon,
    AppMode currentMode,
    bool isHighContrast,
  ) {
    final isSelected = mode == currentMode;
    Color activeColor;
    if (isHighContrast) {
      activeColor = Colors.yellowAccent;
    } else {
      switch (mode) {
        case AppMode.sports:
          activeColor = Colors.orange;
          break;
        case AppMode.sleep:
          activeColor = Colors.indigo;
          break;
        default:
          activeColor = Colors.blue;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SettingsBloc>().add(ChangeAppMode(mode));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isHighContrast ? 0.2 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: activeColor, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? activeColor
                    : (isHighContrast ? Colors.white : Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? activeColor
                      : (isHighContrast ? Colors.white : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isHighContrast, AppMode mode) {
    final authState = context.read<AuthBloc>().state;
    String userName = "User";
    if (authState is Authenticated) {
      userName = authState.user.name ?? "User";
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getModeGradient(mode),
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: isHighContrast
            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isHighContrast ? Colors.yellowAccent : Colors.white,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              Text(
                "SmartVitals",
                style: TextStyle(
                  color: isHighContrast ? Colors.yellowAccent : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _showSOSDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(20),
                    border: isHighContrast
                        ? Border.all(color: Colors.white)
                        : null,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isHighContrast ? Colors.black : Colors.white,
                  shape: BoxShape.circle,
                  border: isHighContrast
                      ? Border.all(color: Colors.white)
                      : null,
                ),
                child: Icon(
                  Icons.person,
                  color: isHighContrast
                      ? Colors.yellowAccent
                      : _getModeGradient(mode)[0],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${userName.split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode == AppMode.sleep
                        ? "Sleep Monitoring Active"
                        : mode == AppMode.sports
                        ? "Tracking Workout"
                        : "Overall Health Score: 85/100",
                    style: TextStyle(
                      color: isHighContrast
                          ? Colors.yellowAccent
                          : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                : (isSensorConnected
                      ? const Color(0xFF10B981)
                      : const Color(0xFFBFDBFE)),
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
                  ? (isSensorConnected
                        ? Colors.greenAccent
                        : Colors.yellowAccent)
                  : (isSensorConnected
                        ? const Color(0xFF047857)
                        : const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 8),
            Text(
              isSensorConnected ? "Sensor Connected" : "Connect Pulse Sensor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighContrast
                    ? (isSensorConnected
                          ? Colors.greenAccent
                          : Colors.yellowAccent)
                    : (isSensorConnected
                          ? const Color(0xFF047857)
                          : const Color(0xFF2563EB)),
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
          title: "Heart Rate",
          value: "72",
          unit: "bpm",
          icon: Icons.favorite,
          iconBgColor: Colors.red,
          iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () => context.goNamed(RouteNames.metricDetail),
        ),
        VitalCard(
          title: "Blood Pressure",
          value: "120/80",
          unit: "mmHg",
          icon: Icons.show_chart,
          iconBgColor: Colors.blue,
          iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
        VitalCard(
          title: "Blood Sugar",
          value: "95",
          unit: "mg/dL",
          icon: Icons.water_drop,
          iconBgColor: Colors.purple,
          iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
        VitalCard(
          title: "Step Count",
          value: stepCount,
          unit: "steps",
          icon: Icons.directions_walk,
          iconBgColor: Colors.green,
          iconColor: Colors.white,
          isHighContrast: isHighContrast,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGoalsList(
    Color cardColor,
    Color borderColor,
    Color textColor,
    bool isHighContrast,
  ) {
    return Column(
      children: [
        _buildGoalItem(
          "Daily Calories",
          "2150",
          "2000 kcal",
          1.0,
          Colors.orange,
          cardColor,
          borderColor,
          textColor,
          isHighContrast,
        ),
        _buildGoalItem(
          "Body Fat",
          "22",
          "18 %",
          0.7,
          Colors.purple,
          cardColor,
          borderColor,
          textColor,
          isHighContrast,
        ),
        _buildGoalItem(
          "Water Intake",
          "6",
          "8 glasses",
          0.75,
          Colors.blue,
          cardColor,
          borderColor,
          textColor,
          isHighContrast,
        ),
      ],
    );
  }

  Widget _buildGoalItem(
    String label,
    String current,
    String target,
    double progress,
    Color color,
    Color bgColor,
    Color borderColor,
    Color textColor,
    bool isHighContrast,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isHighContrast
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                "$current / $target",
                style: TextStyle(
                  fontSize: 12,
                  color: isHighContrast ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isHighContrast
                  ? Colors.grey[800]
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isHighContrast ? Colors.yellowAccent : color,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

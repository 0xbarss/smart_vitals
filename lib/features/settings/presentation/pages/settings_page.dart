import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_event.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? expandedSection;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _emEmailController;
  late TextEditingController _emPhoneController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  bool _isSavingProfile = false;

  Map<String, bool> notifications = {
    'push': true,
    'email': true,
    'reports': false,
  };

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    int age = 0;
    double weight = 0.0;
    double height = 0.0;
    String initialName = "";
    String initialEmail = "";

    if (authState is Authenticated) {
      initialName = authState.user.name ?? "";
      initialEmail = authState.user.email;
      age = authState.user.age ?? 0;
      weight = authState.user.weight ?? 0.0;
      height = authState.user.height ?? 0.0;
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _emEmailController = TextEditingController(
      text: authState is Authenticated ? authState.user.emergencyEmail : "",
    );
    _emPhoneController = TextEditingController(
      text: authState is Authenticated ? authState.user.emergencyPhone : "",
    );
    _ageController = TextEditingController(text: age > 0 ? age.toString() : "");
    _weightController = TextEditingController(text: weight > 0 ? weight.toString() : "");
    _heightController = TextEditingController(text: height > 0 ? height.toString() : "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emEmailController.dispose();
    _emPhoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _toggleAccordion(String section) {
    setState(() {
      expandedSection = expandedSection == section ? null : section;
    });
  }

  void _updateProfile() {
    if (_nameController.text.isEmpty) return;

    final int age = int.tryParse(_ageController.text) ?? 0;
    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    final double height = double.tryParse(_heightController.text) ?? 0.0;

    if (age <= 0 || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid bio-data"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSavingProfile = true);

    context.read<AuthBloc>().add(
      AuthUpdateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        emergencyEmail: _emEmailController.text.trim(),
        emergencyPhone: _emPhoneController.text.trim(),
        age: age,
        weight: weight,
        height: height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() => _isSavingProfile = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AuthError) {
          setState(() => _isSavingProfile = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },

      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isHighContrast = settingsState.highContrast;

          Color getIconColor(Color original) =>
              isHighContrast ? Colors.yellowAccent : original;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.grey[900] : null,
                    gradient: isHighContrast
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF374151), Color(0xFF1F2937)],
                          ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: isHighContrast
                        ? const Border(
                            bottom: BorderSide(color: Colors.white, width: 1),
                          )
                        : null,
                  ),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: isHighContrast
                          ? Colors.yellowAccent
                          : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildAccordionItem(
                        id: 'profile',
                        icon: Icons.security,

                        iconColor: getIconColor(Colors.blue.shade600),
                        title: "Profile & Security",
                        isHighContrast: isHighContrast,
                        child: Column(
                          children: [
                            _buildProfileField(
                              "Full Name",
                              Icons.person_outline,
                              _nameController,
                              isHighContrast,
                            ),
                            _buildProfileField(
                              "Age",
                              Icons.calendar_today,
                              _ageController,
                              isHighContrast,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildProfileField(
                              "Weight (kg)",
                              Icons.monitor_weight_outlined,
                              _weightController,
                              isHighContrast,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildProfileField(
                              "Height (cm)",
                              Icons.height,
                              _heightController,
                              isHighContrast,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildProfileField(
                              "Email",
                              Icons.email_outlined,
                              _emailController,
                              isHighContrast,
                            ),
                            const SizedBox(height: 12),
                            _buildProfileField(
                              "Emergency Email",
                              Icons.email,
                              _emEmailController,
                              isHighContrast,
                              hint: "contact@example.com",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              "Emergency Phone",
                              Icons.phone_in_talk,
                              _emPhoneController,
                              isHighContrast,
                              hint: "+90 555...",
                              keyboardType: TextInputType.phone,
                              formatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+\s-]'),
                                ),
                                LengthLimitingTextInputFormatter(20),
                              ],
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSavingProfile
                                    ? null
                                    : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isHighContrast
                                      ? Colors.black
                                      : const Color(0xFF2563EB),
                                  side: isHighContrast
                                      ? const BorderSide(
                                          color: Colors.yellowAccent,
                                        )
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: _isSavingProfile
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Update Profile",
                                        style: TextStyle(
                                          color: isHighContrast
                                              ? Colors.yellowAccent
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildAccordionItem(
                        id: 'diet',
                        icon: Icons.restaurant,
                        iconColor: getIconColor(Colors.green.shade600),
                        title: "Dietary & Health",
                        isHighContrast: isHighContrast,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dietary Preferences",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: settingsState.dietary.keys
                                  .map(
                                    (k) => _buildFilterChip(
                                      k,
                                      settingsState.dietary,
                                      isHighContrast
                                          ? Colors.yellow
                                          : Colors.green,
                                      isHighContrast,
                                      false,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Allergies",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: settingsState.allergies.keys
                                  .map(
                                    (k) => _buildFilterChip(
                                      k,
                                      settingsState.allergies,
                                      isHighContrast
                                          ? Colors.yellow
                                          : Colors.red,
                                      isHighContrast,
                                      true,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildAccordionItem(
                        id: 'notif',
                        icon: Icons.notifications_active,
                        iconColor: getIconColor(Colors.orange.shade500),
                        title: "Notifications",
                        isHighContrast: isHighContrast,
                        child: Column(
                          children: [
                            _buildSwitchRow(
                              "Push Notifications",
                              "Alerts on screen",
                              'push',
                              isHighContrast,
                            ),
                            Divider(color: isHighContrast ? Colors.grey : null),
                            _buildSwitchRow(
                              "Email Alerts",
                              "Weekly summaries",
                              'email',
                              isHighContrast,
                            ),
                            Divider(color: isHighContrast ? Colors.grey : null),
                            _buildSwitchRow(
                              "Weekly Reports",
                              "Health analysis PDF",
                              'reports',
                              isHighContrast,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isHighContrast
                              ? Border.all(color: Colors.white)
                              : null,
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
                              children: [
                                Icon(
                                  Icons.accessibility_new,
                                  color: getIconColor(Colors.purple.shade600),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Accessibility",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Font Size"),
                                const Icon(Icons.text_fields, size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildFontBtn(
                                  "A",
                                  1.0,
                                  settingsState.fontSizeLevel,
                                  isHighContrast,
                                ),
                                const SizedBox(width: 8),
                                _buildFontBtn(
                                  "A+",
                                  1.1,
                                  settingsState.fontSizeLevel,
                                  isHighContrast,
                                ),
                                const SizedBox(width: 8),
                                _buildFontBtn(
                                  "A++",
                                  1.25,
                                  settingsState.fontSizeLevel,
                                  isHighContrast,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _buildAccessSwitch(
                              "High Contrast",
                              Icons.contrast,
                              settingsState.highContrast,
                              isHighContrast,
                              (val) => context.read<SettingsBloc>().add(
                                ToggleHighContrast(val),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAccessSwitch(
                              "Reduce Motion",
                              Icons.motion_photos_off,
                              settingsState.reduceMotion,
                              isHighContrast,
                              (val) => context.read<SettingsBloc>().add(
                                ToggleReduceMotion(val),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            context.goNamed(RouteNames.welcome);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccordionItem({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    required bool isHighContrast,
  }) {
    final isExpanded = expandedSection == id;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isHighContrast
            ? Border.all(color: Colors.white)
            : Border.all(color: Colors.transparent),
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
          InkWell(
            onTap: () => _toggleAccordion(id),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isHighContrast ? Colors.yellowAccent : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isHighContrast
                        ? Colors.white54
                        : const Color(0xFFF3F4F6),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    IconData icon,
    TextEditingController ctrl,
    bool isHighContrast, {
    bool isPassword = false,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isHighContrast ? Colors.grey[900] : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighContrast ? Colors.white54 : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            obscureText: isPassword,
            decoration: InputDecoration(
              icon: Icon(
                icon,
                size: 18,
                color: isHighContrast ? Colors.yellowAccent : Colors.grey,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14),
            ),
            style: TextStyle(
              fontSize: 14,
              color: isHighContrast ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String key,
    Map<String, bool> map,
    MaterialColor color,
    bool isHighContrast,
    bool isAllergy,
  ) {
    final isSelected = map[key]!;
    final activeColor = isHighContrast ? Colors.yellowAccent : color;

    return GestureDetector(
      onTap: () {
        if (isAllergy) {
          context.read<SettingsBloc>().add(
            UpdateAllergyPreference(key, !isSelected),
          );
        } else {
          context.read<SettingsBloc>().add(
            UpdateDietaryPreference(key, !isSelected),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighContrast ? Colors.grey[900] : color.shade50)
              : (isHighContrast ? Colors.black : Colors.white),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isHighContrast ? Colors.white54 : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          key[0].toUpperCase() + key.substring(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? activeColor
                : (isHighContrast ? Colors.white : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    String key,
    bool isHighContrast,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isHighContrast ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
        Switch(
          value: notifications[key]!,
          activeThumbColor: isHighContrast
              ? Colors.yellowAccent
              : Colors.blue.shade600,
          onChanged: (v) => setState(() => notifications[key] = v),
        ),
      ],
    );
  }

  Widget _buildFontBtn(
    String label,
    double val,
    double currentLevel,
    bool isHighContrast,
  ) {
    final isSelected = currentLevel == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<SettingsBloc>().add(SetFontSize(val)),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isHighContrast ? Colors.yellowAccent : Colors.blue.shade600)
                : (isHighContrast ? Colors.grey[800] : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
            border: isHighContrast && !isSelected
                ? Border.all(color: Colors.white54)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isHighContrast ? Colors.black : Colors.white)
                  : (isHighContrast ? Colors.white : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessSwitch(
    String label,
    IconData icon,
    bool val,
    bool isHighContrast,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isHighContrast ? Colors.white70 : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isHighContrast ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        Switch(
          value: val,
          activeThumbColor: isHighContrast
              ? Colors.yellowAccent
              : Colors.blue.shade600,
          trackColor: isHighContrast
              ? WidgetStateProperty.all(Colors.grey[800])
              : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

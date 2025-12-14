import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes/route_names.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = "Guest";
    String email = "";

    if (authState is Authenticated) {
      name = authState.user.name ?? "User";
      email = authState.user.email;
    }

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHighContrast = settings.highContrast;

        final Color drawerBg = isHighContrast ? Colors.black : Colors.white;
        final Color headerBg = isHighContrast
            ? Colors.grey[900]!
            : const Color(0xFFF3F4F6);
        final Color primaryText = isHighContrast
            ? Colors.yellowAccent
            : Colors.black;
        final Color secondaryText = isHighContrast
            ? Colors.white70
            : Colors.grey[600]!;
        final Color iconColor = isHighContrast
            ? Colors.yellowAccent
            : Colors.grey[700]!;
        final Color listTextColor = isHighContrast
            ? Colors.white
            : Colors.grey[800]!;

        return Drawer(
          backgroundColor: drawerBg,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                decoration: BoxDecoration(
                  color: headerBg,
                  border: isHighContrast
                      ? const Border(
                          bottom: BorderSide(color: Colors.white, width: 1),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isHighContrast
                          ? Colors.white
                          : const Color(0xFFDBEAFE),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: isHighContrast
                            ? Colors.black
                            : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildDrawerItem(
                context,
                Icons.dashboard_outlined,
                "Dashboard",
                RouteNames.home,
                iconColor,
                listTextColor,
              ),
              _buildDrawerItem(
                context,
                Icons.analytics_outlined,
                "Health Analysis",
                RouteNames.analysis,
                iconColor,
                listTextColor,
              ),
              _buildDrawerItem(
                context,
                Icons.restaurant_menu,
                "Meal Plans",
                RouteNames.recipes,
                iconColor,
                listTextColor,
              ),
              _buildDrawerItem(
                context,
                Icons.description_outlined,
                "Reports",
                RouteNames.reports,
                iconColor,
                listTextColor,
              ),
              _buildDrawerItem(
                context,
                Icons.settings_outlined,
                "Settings",
                RouteNames.settings,
                iconColor,
                listTextColor,
              ),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String routeName,
    Color iconColor,
    Color textColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        context.pop();
        context.goNamed(routeName);
      },
    );
  }
}

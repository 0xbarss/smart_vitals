import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes/route_names.dart';
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

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFDBEAFE),
                  child: Icon(Icons.person, size: 30, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          ),
          _buildDrawerItem(
            context,
            Icons.analytics_outlined,
            "Health Analysis",
            RouteNames.analysis,
          ),
          _buildDrawerItem(
            context,
            Icons.restaurant_menu,
            "Meal Plans",
            RouteNames.recipes,
          ),
          _buildDrawerItem(
            context,
            Icons.description_outlined,
            "Reports",
            RouteNames.reports,
          ),
          _buildDrawerItem(
            context,
            Icons.settings_outlined,
            "Settings",
            RouteNames.settings,
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String routeName,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
      ),
      onTap: () {
        context.pop();
        context.goNamed(routeName);
      },
    );
  }
}

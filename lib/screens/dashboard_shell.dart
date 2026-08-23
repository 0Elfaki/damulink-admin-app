import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_repository.dart';
import 'dashboard_screen.dart';
import 'campaigns_admin_screen.dart';
import 'blood_requests_admin_screen.dart';
import 'lab_reports_admin_screen.dart';
import 'users_admin_screen.dart';

class DashboardShell extends StatefulWidget {
  final VoidCallback onSignedOut;
  const DashboardShell({super.key, required this.onSignedOut});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  final _authRepository = AuthRepository();

  static const _destinations = [
    (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.campaign_outlined, selectedIcon: Icons.campaign, label: 'Campaigns'),
    (icon: Icons.bloodtype_outlined, selectedIcon: Icons.bloodtype, label: 'Blood Requests'),
    (icon: Icons.biotech_outlined, selectedIcon: Icons.biotech, label: 'Lab Reports'),
    (icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Users'),
  ];

  final _screens = const [
    DashboardScreen(),
    CampaignsAdminScreen(),
    BloodRequestsAdminScreen(),
    LabReportsAdminScreen(),
    UsersAdminScreen(),
  ];

  Future<void> _signOut() async {
    await _authRepository.signOut();
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 240,
                  color: AppColors.sidebarBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bloodtype, color: AppColors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'DamuLink',
                              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _destinations.length,
                          itemBuilder: (context, index) {
                            final d = _destinations[index];
                            final selected = _selectedIndex == index;
                            return ListTile(
                              onTap: () => setState(() => _selectedIndex = index),
                              leading: Icon(
                                selected ? d.selectedIcon : d.icon,
                                color: selected ? AppColors.primary : AppColors.sidebarText,
                              ),
                              title: Text(
                                d.label,
                                style: TextStyle(
                                  color: selected ? AppColors.white : AppColors.sidebarText,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              selected: selected,
                              selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
                            );
                          },
                        ),
                      ),
                      ListTile(
                        onTap: _signOut,
                        leading: const Icon(Icons.logout, color: AppColors.sidebarText),
                        title: const Text('Sign Out', style: TextStyle(color: AppColors.sidebarText)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          );
        }

        // Mobile / narrow layout
        return Scaffold(
          appBar: AppBar(
            title: Text(_destinations[_selectedIndex].label),
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
            ],
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: _destinations
                .map((d) => NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label))
                .toList(),
          ),
        );
      },
    );
  }
}

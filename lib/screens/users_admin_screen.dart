import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/staff_profile.dart';
import '../services/user_admin_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/app_card.dart';
import '../widgets/list_state.dart';
import '../widgets/section_header.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  final _repository = UserAdminRepository();
  List<StaffProfile> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final _roles = ['donor', 'organizer', 'lab', 'admin', 'health_staff'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final users = await _repository.getAllUsers(searchQuery: _searchQuery);
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeRole(StaffProfile user, String newRole) async {
    final isSelf = user.id == SupabaseService.currentUser?.id;
    if (isSelf && newRole != 'admin') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove your own admin access?'),
          content: const Text('You will lose access to this dashboard immediately.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CONFIRM')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      await _repository.updateUserRole(user.id, newRole);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.fullName} is now $newRole.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.critical;
      case 'organizer':
        return AppColors.warning;
      case 'lab':
        return AppColors.primaryDark;
      case 'health_staff':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _roleLabel(String role) {
    if (role == 'health_staff') return 'Health Staff';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(title: 'Users'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _load();
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const LoadingState()
            else if (_users.isEmpty)
              const EmptyState(message: 'No users found.')
            else
              ..._users.map(_buildUserCard),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(StaffProfile user) {
    final color = _roleColor(user.role);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('${user.points} points', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: user.role,
            underline: const SizedBox.shrink(),
            items: _roles
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(_roleLabel(r)),
                    ))
                .toList(),
            onChanged: (newRole) {
              if (newRole != null && newRole != user.role) _changeRole(user, newRole);
            },
          ),
        ],
      ),
    );
  }
}

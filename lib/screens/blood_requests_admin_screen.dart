import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/blood_request_admin.dart';
import '../services/blood_request_admin_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/list_state.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

class BloodRequestsAdminScreen extends StatefulWidget {
  const BloodRequestsAdminScreen({super.key});

  @override
  State<BloodRequestsAdminScreen> createState() => _BloodRequestsAdminScreenState();
}

class _BloodRequestsAdminScreenState extends State<BloodRequestsAdminScreen> {
  final _repository = BloodRequestAdminRepository();
  List<BloodRequestAdmin> _requests = [];
  bool _isLoading = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final requests = await _repository.getAllRequests(statusFilter: _statusFilter);
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _setStatus(BloodRequestAdmin request, String status) async {
    await _repository.setStatus(request.id, status);
    _load();
  }

  Color _urgencyColor(String level) {
    switch (level) {
      case 'Emergency':
        return AppColors.critical;
      case 'Urgent':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
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
            const SectionHeader(title: 'Blood Requests'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  _buildFilterChip('Open', 'open'),
                  _buildFilterChip('Fulfilled', 'fulfilled'),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const LoadingState()
            else if (_requests.isEmpty)
              const EmptyState(message: 'No requests found.')
            else
              ..._requests.map(_buildRequestCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _load();
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestAdmin request) {
    final color = _urgencyColor(request.urgency);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: request.urgency, color: color),
              const Spacer(),
              Text(
                DateFormat.yMMMd().add_jm().format(request.createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${request.bloodTypesLabel} needed${request.hospital.isNotEmpty ? ' at ${request.hospital}' : ''}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Requested by ${request.requesterName ?? 'Unknown'} · ${request.unitsNeeded} unit(s) · ${request.responseCount} offer(s)',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (request.status == 'open') ...[
                ElevatedButton(
                  onPressed: () => _setStatus(request, 'fulfilled'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: const Text('MARK FULFILLED', style: TextStyle(fontSize: 11, color: AppColors.white)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _setStatus(request, 'cancelled'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.critical)),
                  child: const Text('CANCEL', style: TextStyle(fontSize: 11, color: AppColors.critical)),
                ),
              ] else
                StatusPill(label: request.status, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

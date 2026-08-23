import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/blood_request_admin.dart';
import '../services/blood_request_admin_repository.dart';

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
            const Text(
              'Blood Requests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('No requests found.', style: TextStyle(color: AppColors.textSecondary))),
              )
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(request.urgency.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd().add_jm().format(request.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

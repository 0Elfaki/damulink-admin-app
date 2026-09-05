import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/campaign.dart';
import '../services/campaign_admin_repository.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/list_state.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

class CampaignsAdminScreen extends StatefulWidget {
  const CampaignsAdminScreen({super.key});

  @override
  State<CampaignsAdminScreen> createState() => _CampaignsAdminScreenState();
}

class _CampaignsAdminScreenState extends State<CampaignsAdminScreen> {
  final _repository = CampaignAdminRepository();
  List<Campaign> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final campaigns = await _repository.getAllCampaigns();
    if (mounted) {
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(Campaign campaign) async {
    final newStatus = campaign.status == 'active' ? 'closed' : 'active';
    await _repository.setStatus(campaign.id, newStatus);
    _load();
  }

  void _openCreateSheet() {
    showDialog(
      context: context,
      builder: (context) => _CampaignFormDialog(onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('NEW CAMPAIGN', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const LoadingState()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                children: [
                  const SectionHeader(title: 'Campaigns'),
                  const SizedBox(height: 16),
                  if (_campaigns.isEmpty)
                    const EmptyState(message: 'No campaigns yet.')
                  else
                    ..._campaigns.map(_buildCampaignCard),
                ],
              ),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final isActive = campaign.status == 'active';
    final progress = campaign.targetDonations > 0
        ? (campaign.participantCount / campaign.targetDonations).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(campaign.title, style: AppTextStyles.bodyBold),
              ),
              StatusPill(
                label: campaign.status,
                color: isActive ? AppColors.success : AppColors.textSecondary,
              ),
            ],
          ),
          if (campaign.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(campaign.location, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 8),
          if (campaign.targetDonations > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.background,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '${campaign.participantCount} / ${campaign.targetDonations} participants · started ${DateFormat.yMMMd().format(campaign.startDate)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _toggleStatus(campaign),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isActive ? AppColors.critical : AppColors.success),
                ),
                child: Text(
                  isActive ? 'CLOSE CAMPAIGN' : 'REOPEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.critical : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampaignFormDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const _CampaignFormDialog({required this.onSaved});

  @override
  State<_CampaignFormDialog> createState() => _CampaignFormDialogState();
}

class _CampaignFormDialogState extends State<_CampaignFormDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _targetController = TextEditingController();
  final _repository = CampaignAdminRepository();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Give the campaign a title.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await _repository.createCampaign(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        targetDonations: int.tryParse(_targetController.text.trim()) ?? 0,
        startDate: DateTime.now(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _error = "Couldn't create the campaign.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Campaign'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 12),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Participant goal'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
              : const Text('CREATE'),
        ),
      ],
    );
  }
}

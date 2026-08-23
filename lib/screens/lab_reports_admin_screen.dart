import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/lab_report_admin.dart';
import '../models/staff_profile.dart';
import '../services/lab_report_admin_repository.dart';

class LabReportsAdminScreen extends StatefulWidget {
  const LabReportsAdminScreen({super.key});

  @override
  State<LabReportsAdminScreen> createState() => _LabReportsAdminScreenState();
}

class _LabReportsAdminScreenState extends State<LabReportsAdminScreen> {
  final _repository = LabReportAdminRepository();
  List<LabReportAdmin> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final reports = await _repository.getAllReports();
    if (mounted) {
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _LabReportFormDialog(onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('NEW REPORT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          children: [
            const Text(
              'Lab Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_reports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('No lab reports yet.', style: TextStyle(color: AppColors.textSecondary))),
              )
            else
              ..._reports.map(_buildReportCard),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(LabReportAdmin report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.biotech, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.donorName ?? 'Unknown donor',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                if (report.bloodTypeConfirmed != null || report.hemoglobinLevel != null)
                  Text(
                    [
                      if (report.bloodTypeConfirmed != null) 'Type: ${report.bloodTypeConfirmed}',
                      if (report.hemoglobinLevel != null) 'Hb: ${report.hemoglobinLevel} g/dL',
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                Text(DateFormat.yMMMd().format(report.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabReportFormDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const _LabReportFormDialog({required this.onSaved});

  @override
  State<_LabReportFormDialog> createState() => _LabReportFormDialogState();
}

class _LabReportFormDialogState extends State<_LabReportFormDialog> {
  final _repository = LabReportAdminRepository();
  final _searchController = TextEditingController();
  final _hemoglobinController = TextEditingController();
  final _notesController = TextEditingController();

  List<StaffProfile> _donorResults = [];
  StaffProfile? _selectedDonor;
  String? _bloodType;
  bool _isSubmitting = false;
  String? _error;

  final _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _donorResults = []);
      return;
    }
    final results = await _repository.searchDonors(query.trim());
    if (mounted) setState(() => _donorResults = results);
  }

  Future<void> _submit() async {
    if (_selectedDonor == null) {
      setState(() => _error = 'Select a donor first.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await _repository.createReport(
        donorId: _selectedDonor!.id,
        bloodTypeConfirmed: _bloodType,
        hemoglobinLevel: double.tryParse(_hemoglobinController.text.trim()),
        screeningNotes: _notesController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      setState(() => _error = "Couldn't save the report.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Lab Report'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedDonor == null) ...[
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(labelText: 'Search donor by name'),
                  onChanged: _search,
                ),
                const SizedBox(height: 8),
                ..._donorResults.map((donor) => ListTile(
                      title: Text(donor.fullName),
                      onTap: () => setState(() {
                        _selectedDonor = donor;
                        _donorResults = [];
                      }),
                    )),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.lightPink, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(child: Text(_selectedDonor!.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedDonor = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _bloodTypes.map((type) {
                    final isSelected = _bloodType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _bloodType = type),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textPrimary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _hemoglobinController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Hemoglobin level (g/dL)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Screening notes'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}

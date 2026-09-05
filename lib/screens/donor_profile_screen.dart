import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/donor.dart';
import '../models/donor_donation.dart';
import '../models/donor_list_item.dart';
import '../services/donor_repository.dart';
import '../widgets/app_card.dart';
import '../widgets/status_pill.dart';

/// Full profile for one donor. Walk-in donors (registered by staff) are
/// editable here -- health status and donation history. App-registered
/// donors are shown read-only, since their record lives in `profiles`
/// and is managed through the donor app itself.
class DonorProfileScreen extends StatefulWidget {
  final String? walkInDonorId;
  final DonorListItem? appDonorItem;

  const DonorProfileScreen({super.key, required String donorId})
      : walkInDonorId = donorId,
        appDonorItem = null;

  const DonorProfileScreen.appDonor({super.key, required DonorListItem item})
      : walkInDonorId = null,
        appDonorItem = item;

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _repository = DonorRepository();
  Donor? _donor;
  List<DonorDonation> _history = [];
  bool _isLoading = true;

  bool get _isWalkIn => widget.walkInDonorId != null;

  @override
  void initState() {
    super.initState();
    if (_isWalkIn) {
      _load();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final donor = await _repository.getDonorDetail(widget.walkInDonorId!);
    final history = await _repository.getDonationHistory(widget.walkInDonorId!);
    if (mounted) {
      setState(() {
        _donor = donor;
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _editHealthStatus() async {
    final donor = _donor!;
    String status = donor.healthStatus;
    final notesController = TextEditingController(text: donor.healthNotes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Health status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<String>(
                groupValue: status,
                onChanged: (v) => setDialogState(() => status = v ?? 'eligible'),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'eligible',
                      activeColor: AppColors.success,
                      title: Text('Eligible'),
                    ),
                    RadioListTile<String>(
                      value: 'deferred',
                      activeColor: AppColors.critical,
                      title: Text('Deferred'),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('SAVE')),
          ],
        ),
      ),
    );

    if (saved == true) {
      await _repository.updateHealthStatus(
        donor.id,
        healthStatus: status,
        healthNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );
      _load();
    }
  }

  Future<void> _logDonation() async {
    final locationController = TextEditingController(text: _donor?.registrationLocation ?? '');
    DateTime date = DateTime.now();

    final logged = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log a donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(DateTime.now().year - 2),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => date = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Donation date'),
                  child: Text(DateFormat.yMMMd().format(date)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('LOG')),
          ],
        ),
      ),
    );

    if (logged == true) {
      await _repository.logDonation(
        donorId: _donor!.id,
        donationDate: date,
        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        campaignId: _donor!.campaignId,
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    if (!_isWalkIn) {
      return _buildAppDonorView(widget.appDonorItem!);
    }

    final donor = _donor;
    if (donor == null) {
      return const Scaffold(body: Center(child: Text('Donor not found.')));
    }
    return _buildWalkInView(donor);
  }

  Widget _buildWalkInView(Donor donor) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Donor Profile')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(
              fullName: donor.fullName,
              donorId: donor.donorId,
              isEligible: donor.isEligible,
              nextEligibleDate: donor.nextEligibleDate,
              bloodType: donor.bloodType,
            ),
            const SizedBox(height: 16),
            _buildCard('Identity', [
              _field('Phone', donor.phone),
              _field('Gender', donor.gender),
              _field('Date of birth', donor.dateOfBirth != null ? DateFormat.yMMMd().format(donor.dateOfBirth!) : null),
              _field(donor.idType, donor.nationalId),
              _field('District', donor.district),
            ]),
            const SizedBox(height: 12),
            _buildCard('Registration', [
              _field('Registered', DateFormat.yMMMd().add_jm().format(donor.createdAt)),
              _field('Campaign', donor.campaignName),
              _field('Location', donor.registrationLocation),
            ]),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Health status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(onPressed: _editHealthStatus, child: const Text('EDIT')),
                    ],
                  ),
                  Row(
                    children: [
                      StatusPill(
                        label: donor.healthStatus == 'eligible' ? 'Eligible' : 'Deferred',
                        color: donor.healthStatus == 'eligible' ? AppColors.success : AppColors.critical,
                      ),
                    ],
                  ),
                  if (donor.healthNotes != null && donor.healthNotes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(donor.healthNotes!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Donation history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton.icon(
                        onPressed: _logDonation,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('LOG DONATION'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No donations logged yet.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ..._history.map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.bloodtype, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(DateFormat.yMMMd().format(d.donationDate))),
                              if (d.location != null) Text(d.location!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDonorView(DonorListItem item) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Donor Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(
            fullName: item.fullName,
            donorId: item.donorId ?? '—',
            isEligible: item.isEligible,
            nextEligibleDate: item.nextEligibleDate,
            bloodType: item.bloodType,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(10)),
            child: const Row(
              children: [
                Icon(Icons.smartphone, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Registered through the DamuLink app -- managed by the donor, shown read-only here.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard('Identity', [
            _field('Phone', item.phone),
            _field('Gender', item.gender),
            _field('Date of birth', item.dateOfBirth != null ? DateFormat.yMMMd().format(item.dateOfBirth!) : null),
            _field('District', item.district),
            _field('Last donation', item.lastDonationDate != null ? DateFormat.yMMMd().format(item.lastDonationDate!) : 'None on record'),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required String fullName,
    required String donorId,
    required bool isEligible,
    DateTime? nextEligibleDate,
    String? bloodType,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
              if (bloodType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(bloodType, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('ID: $donorId', style: const TextStyle(color: AppColors.white, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isEligible ? AppColors.success : AppColors.critical).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isEligible ? Icons.check_circle : Icons.block, size: 16, color: AppColors.white),
                const SizedBox(width: 6),
                Text(
                  isEligible
                      ? 'Eligible to donate'
                      : 'Not eligible${nextEligibleDate != null ? ' until ${DateFormat.yMMMd().format(nextEligibleDate)}' : ''}',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> fields) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...fields,
        ],
      ),
    );
  }

  Widget _field(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : 'Not on file', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}


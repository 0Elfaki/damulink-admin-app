import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/donor_list_item.dart';
import '../services/donor_repository.dart';
import '../widgets/app_card.dart';
import '../widgets/list_state.dart';
import '../widgets/section_header.dart';
import 'donor_profile_screen.dart';
import 'register_donor_screen.dart';

/// Every donor in the system -- walk-ins registered by staff and
/// app-registered donors together -- with a green/red eligibility
/// indicator computed from health status and days since last donation.
class DonorsListScreen extends StatefulWidget {
  const DonorsListScreen({super.key});

  @override
  State<DonorsListScreen> createState() => _DonorsListScreenState();
}

class _DonorsListScreenState extends State<DonorsListScreen> {
  final _repository = DonorRepository();
  List<DonorListItem> _donors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _eligibleOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final donors = await _repository.getAllDonors(searchQuery: _searchQuery);
    if (mounted) {
      setState(() {
        _donors = donors;
        _isLoading = false;
      });
    }
  }

  List<DonorListItem> get _visibleDonors =>
      _eligibleOnly ? _donors.where((d) => d.isEligible).toList() : _donors;

  void _openDonor(DonorListItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => item.source == DonorSource.walkIn
            ? DonorProfileScreen(donorId: item.id)
            : DonorProfileScreen.appDonor(item: item),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final donors = _visibleDonors;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterDonorScreen()))
              .then((_) => _load());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: AppColors.white),
        label: const Text('REGISTER DONOR', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          children: [
            const SectionHeader(title: 'Donors'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, donor ID, or phone',
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
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  label: const Text('Eligible only'),
                  selected: _eligibleOnly,
                  selectedColor: AppColors.lightGreen,
                  onSelected: (v) => setState(() => _eligibleOnly = v),
                ),
                const SizedBox(width: 8),
                Text('${donors.length} donor${donors.length == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const LoadingState()
            else if (donors.isEmpty)
              const EmptyState(message: 'No donors found.')
            else
              ...donors.map(_buildDonorCard),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(DonorListItem donor) {
    final eligibilityColor = donor.isEligible ? AppColors.success : AppColors.critical;
    return InkWell(
      onTap: () => _openDonor(donor),
      borderRadius: AppCard.radius,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        border: Border(left: BorderSide(color: eligibilityColor, width: 4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          donor.fullName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                      Icon(
                        donor.source == DonorSource.app ? Icons.smartphone : Icons.badge_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    donor.donorId ?? 'No donor ID',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _metaRow(Icons.event, DateFormat.yMMMd().add_jm().format(donor.createdAt)),
                      if (donor.campaignName != null) _metaRow(Icons.campaign_outlined, donor.campaignName!),
                      if (donor.registrationLocation != null) _metaRow(Icons.place_outlined, donor.registrationLocation!),
                      if (donor.bloodType != null) _metaRow(Icons.bloodtype_outlined, donor.bloodType!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: eligibilityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Icon(donor.isEligible ? Icons.check_circle : Icons.block, size: 16, color: eligibilityColor),
                  const SizedBox(height: 2),
                  Text(
                    donor.isEligible ? 'Eligible' : 'Not yet',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: eligibilityColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

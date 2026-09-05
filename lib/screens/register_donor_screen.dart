import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/campaign.dart';
import '../models/donor.dart';
import '../services/campaign_admin_repository.dart';
import '../services/donor_repository.dart';
import '../widgets/app_card.dart';
import '../widgets/section_header.dart';
import 'donor_profile_screen.dart';

/// Lets health staff register a donor who doesn't have a smartphone --
/// they fill this in on the donor's behalf, on the spot, and the donor
/// gets a system-generated Donor ID at the end.
class RegisterDonorScreen extends StatefulWidget {
  const RegisterDonorScreen({super.key});

  @override
  State<RegisterDonorScreen> createState() => _RegisterDonorScreenState();
}

class _RegisterDonorScreenState extends State<RegisterDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorRepository = DonorRepository();
  final _campaignRepository = CampaignAdminRepository();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _districtController = TextEditingController();
  final _locationController = TextEditingController();
  final _healthNotesController = TextEditingController();

  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  static const _genders = ['Male', 'Female'];
  static const _idTypes = ['National ID', 'Passport', 'Other'];

  String? _bloodType;
  String? _gender;
  String _idType = 'National ID';
  DateTime? _dateOfBirth;
  String _healthStatus = 'eligible';
  Campaign? _selectedCampaign;

  List<Campaign> _campaigns = [];
  bool _isLoadingCampaigns = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final campaigns = await _campaignRepository.getAllCampaigns();
    if (mounted) {
      setState(() {
        _campaigns = campaigns.where((c) => c.status == 'active').toList();
        _isLoadingCampaigns = false;
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 16),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _phoneController.clear();
    _nationalIdController.clear();
    _districtController.clear();
    _locationController.clear();
    _healthNotesController.clear();
    setState(() {
      _bloodType = null;
      _gender = null;
      _idType = 'National ID';
      _dateOfBirth = null;
      _healthStatus = 'eligible';
      _selectedCampaign = null;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final donor = await _donorRepository.registerDonor(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        bloodType: _bloodType,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        nationalId: _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
        idType: _idType,
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        campaignId: _selectedCampaign?.id,
        registrationLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        healthStatus: _healthStatus,
        healthNotes: _healthNotesController.text.trim().isEmpty ? null : _healthNotesController.text.trim(),
      );
      if (mounted) _showSuccess(donor);
    } catch (e) {
      setState(() => _error = "Couldn't register this donor. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess(Donor donor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Donor registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(donor.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_outlined, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Donor ID: ${donor.donorId}',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('REGISTER ANOTHER'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DonorProfileScreen(donorId: donor.id)),
              );
            },
            child: const Text('VIEW PROFILE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(
            title: 'Register Donor',
            subtitle: "For donors without a smartphone -- fill this in on their behalf.",
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Identity'),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full name *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone number'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Date of birth'),
                            child: Text(
                              _dateOfBirth == null
                                  ? 'Select'
                                  : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _idType,
                          decoration: const InputDecoration(labelText: 'ID type'),
                          items: _idTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _idType = v ?? 'National ID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(controller: _nationalIdController, decoration: const InputDecoration(labelText: 'ID number')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _districtController, decoration: const InputDecoration(labelText: 'District / area')),

                  const SizedBox(height: 20),
                  const _SectionLabel('Health'),
                  DropdownButtonFormField<String>(
                    initialValue: _bloodType,
                    decoration: const InputDecoration(labelText: 'Blood type'),
                    items: _bloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (v) => setState(() => _bloodType = v),
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
                    groupValue: _healthStatus,
                    onChanged: (v) => setState(() => _healthStatus = v ?? 'eligible'),
                    child: const Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: 'eligible',
                            activeColor: AppColors.success,
                            title: Text('Eligible', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: 'deferred',
                            activeColor: AppColors.critical,
                            title: Text('Deferred', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_healthStatus == 'deferred') ...[
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _healthNotesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Reason for deferral'),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const _SectionLabel('Registration'),
                  _isLoadingCampaigns
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(color: AppColors.primary),
                        )
                      : DropdownButtonFormField<Campaign?>(
                          initialValue: _selectedCampaign,
                          decoration: const InputDecoration(labelText: 'Campaign (optional)'),
                          items: [
                            const DropdownMenuItem<Campaign?>(value: null, child: Text('Not tied to a campaign')),
                            ..._campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c.title))),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _selectedCampaign = v;
                              if (v != null && _locationController.text.trim().isEmpty) {
                                _locationController.text = v.location;
                              }
                            });
                          },
                        ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Registration location')),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                            )
                          : const Text('REGISTER DONOR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
      ),
    );
  }
}

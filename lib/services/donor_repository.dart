import 'supabase_service.dart';
import '../models/donor.dart';
import '../models/donor_donation.dart';
import '../models/donor_list_item.dart';

class DonorRepository {
  final _client = SupabaseService.client;

  /// All donors -- walk-ins registered by staff plus app-registered
  /// donors -- merged into one list, newest first.
  Future<List<DonorListItem>> getAllDonors({String? searchQuery}) async {
    final walkInRows = await _client
        .from('donors_with_eligibility')
        .select()
        .order('created_at', ascending: false);
    final appRows = await _client.rpc('list_app_donors_for_staff');

    final combined = <DonorListItem>[
      ...(walkInRows as List).map((r) => DonorListItem.fromDonorMap(r as Map<String, dynamic>)),
      ...(appRows as List).map((r) => DonorListItem.fromAppDonorMap(r as Map<String, dynamic>)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final q = searchQuery?.trim().toLowerCase();
    if (q == null || q.isEmpty) return combined;
    return combined.where((d) {
      return d.fullName.toLowerCase().contains(q) ||
          (d.donorId?.toLowerCase().contains(q) ?? false) ||
          (d.phone?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<Donor> getDonorDetail(String id) async {
    final row = await _client.from('donors_with_eligibility').select().eq('id', id).single();
    return Donor.fromMap(row);
  }

  Future<List<DonorDonation>> getDonationHistory(String donorId) async {
    final rows = await _client
        .from('donor_donations')
        .select()
        .eq('donor_id', donorId)
        .order('donation_date', ascending: false);
    return (rows as List).map((r) => DonorDonation.fromMap(r as Map<String, dynamic>)).toList();
  }

  /// Registers a new walk-in donor and returns the created record
  /// (including the auto-generated donor ID and eligibility fields).
  Future<Donor> registerDonor({
    required String fullName,
    String? phone,
    String? bloodType,
    DateTime? dateOfBirth,
    String? gender,
    String? nationalId,
    String idType = 'National ID',
    String? district,
    String? campaignId,
    String? registrationLocation,
    String healthStatus = 'eligible',
    String? healthNotes,
  }) async {
    final staffId = SupabaseService.currentUser?.id;
    final inserted = await _client
        .from('donors')
        .insert({
          'full_name': fullName,
          'phone': phone,
          'blood_type': bloodType,
          'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
          'gender': gender,
          'national_id': nationalId,
          'id_type': idType,
          'district': district,
          'campaign_id': campaignId,
          'registration_location': registrationLocation,
          'health_status': healthStatus,
          'health_notes': healthNotes,
          'registered_by': staffId,
        })
        .select('id')
        .single();
    return getDonorDetail(inserted['id'] as String);
  }

  Future<void> updateHealthStatus(
    String donorId, {
    required String healthStatus,
    String? healthNotes,
  }) async {
    await _client.from('donors').update({
      'health_status': healthStatus,
      'health_notes': healthNotes,
    }).eq('id', donorId);
  }

  Future<void> logDonation({
    required String donorId,
    required DateTime donationDate,
    String? location,
    String donationType = 'Whole Blood',
    String? campaignId,
  }) async {
    final staffId = SupabaseService.currentUser?.id;
    await _client.from('donor_donations').insert({
      'donor_id': donorId,
      'donation_date': donationDate.toIso8601String().split('T').first,
      'location': location,
      'donation_type': donationType,
      'campaign_id': campaignId,
      'logged_by': staffId,
    });
  }
}

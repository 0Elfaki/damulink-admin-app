import 'supabase_service.dart';
import '../models/campaign.dart';

class CampaignAdminRepository {
  final _client = SupabaseService.client;

  Future<List<Campaign>> getAllCampaigns() async {
    final rows = await _client.from('campaigns').select().order('start_date', ascending: false);
    final participantRows = await _client.from('campaign_participants').select('campaign_id');
    final Map<String, int> counts = {};
    for (final row in (participantRows as List)) {
      final id = row['campaign_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return (rows as List).map((row) {
      final map = row as Map<String, dynamic>;
      return Campaign.fromMap(map, participantCount: counts[map['id']] ?? 0);
    }).toList();
  }

  Future<void> createCampaign({
    required String title,
    required String description,
    required String location,
    required int targetDonations,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('Not signed in');
    await _client.from('campaigns').insert({
      'title': title,
      'description': description,
      'location': location,
      'target_donations': targetDonations,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'organizer_id': userId,
    });
  }

  Future<void> updateCampaign(Campaign campaign) async {
    await _client.from('campaigns').update({
      'title': campaign.title,
      'description': campaign.description,
      'location': campaign.location,
      'target_donations': campaign.targetDonations,
      'end_date': campaign.endDate?.toIso8601String(),
    }).eq('id', campaign.id);
  }

  Future<void> setStatus(String campaignId, String status) async {
    await _client.from('campaigns').update({'status': status}).eq('id', campaignId);
  }
}

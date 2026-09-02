import 'supabase_service.dart';
import '../models/staff_kpis.dart';

class StaffKpiRepository {
  Future<StaffKpis> getKpis() async {
    final result = await SupabaseService.client.rpc('get_staff_dashboard_kpis');
    return StaffKpis.fromMap(result as Map<String, dynamic>);
  }
}

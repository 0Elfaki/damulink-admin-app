import 'supabase_service.dart';
import '../models/dashboard_kpis.dart';

class KpiRepository {
  Future<DashboardKpis> getKpis() async {
    final result = await SupabaseService.client.rpc('get_dashboard_kpis');
    return DashboardKpis.fromMap(result as Map<String, dynamic>);
  }
}

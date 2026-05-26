import 'dashboard_entity.dart';
import 'dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository repository;

  GetDashboardUseCase(this.repository);

  Future<DashboardEntity> call() async {
    return await repository.getDashboard();
  }
}

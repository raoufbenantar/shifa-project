import 'dashboard_entity.dart';
import 'dashboard_remote_datasource.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardEntity> getDashboard() async {
    return await remoteDataSource.getDashboard();
  }
}

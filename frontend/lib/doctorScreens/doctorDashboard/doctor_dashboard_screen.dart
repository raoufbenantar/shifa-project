import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'dashboard_bloc.dart';
import 'dashboard_entity.dart';
import 'dashboard_event.dart';
import 'dashboard_remote_datasource.dart';
import 'dashboard_repository_impl.dart';
import 'dashboard_state.dart';
import 'dashboard_usecase.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(
        GetDashboardUseCase(
          DashboardRepositoryImpl(
            DashboardRemoteDataSourceImpl(),
          ),
        ),
      )..add(LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: AppTextStyles.fieldLabel,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardBloc>().add(RefreshDashboard()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.white)),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardContent(dashboard: state.dashboard);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardEntity dashboard;
  const _DashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(dashboard.doctor, dashboard)),

          // ── Stats Grid ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildStatsGrid(dashboard.stats),
                ],
              ),
            ),
          ),

          // ── Today's Appointments ─────────────────
          SliverToBoxAdapter(
            child: _buildSection(
              title: "Today's Appointments",
              icon: Icons.calendar_today,
              appointments: dashboard.todayAppointments,
              emptyMessage: 'No appointments today',
            ),
          ),

          // ── Pending Appointments ─────────────────
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Pending Requests',
              icon: Icons.pending_actions,
              appointments: dashboard.pendingAppointments,
              emptyMessage: 'No pending requests',
              statusColor: Colors.orange,
            ),
          ),

          // ── Upcoming Appointments ────────────────
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'Upcoming (7 days)',
              icon: Icons.schedule,
              appointments: dashboard.upcomingAppointments,
              emptyMessage: 'No upcoming appointments',
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(DoctorInfo doctor, DashboardEntity dashboard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.white.withOpacity(0.3),
                child: doctor.image != null
                    ? ClipOval(
                        child: Image.network(doctor.image!,
                            width: 56, height: 56, fit: BoxFit.cover))
                    : const Icon(Icons.person, color: AppColors.white, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${doctor.fullName}',
                        style: AppTextStyles.loginTitle),
                    const SizedBox(height: 4),
                    Text(doctor.specialization,
                        style: AppTextStyles.loginSubtitle),
                  ],
                ),
              ),
              // Notification badge
              Stack(
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.white, size: 28),
                  if (dashboard.unreadNotifications > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${dashboard.unreadNotifications}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Verification badge
          if (doctor.verificationStatus != 'approved')
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Account ${doctor.verificationStatus}',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          // Quick stats row
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat(
                  '${dashboard.unreadMessages}', 'Messages', Icons.message),
              _buildQuickStat('${dashboard.stats.totalClinics}', 'Clinics',
                  Icons.local_hospital),
              _buildQuickStat(
                  dashboard.stats.avgRating != null
                      ? '${dashboard.stats.avgRating}'
                      : 'N/A',
                  'Rating',
                  Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: AppColors.white, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total', '${stats.totalAppointments}',
            Icons.calendar_month, AppColors.primary),
        _buildStatCard('Completed', '${stats.completed}',
            Icons.check_circle_outline, Colors.green),
        _buildStatCard(
            'Pending', '${stats.pending}', Icons.pending, Colors.orange),
        _buildStatCard('Completion', '${stats.completionRate}%',
            Icons.trending_up, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<AppointmentEntity> appointments,
    required String emptyMessage,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const Spacer(),
              Text('${appointments.length}',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          if (appointments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emptyMessage,
                  style: AppTextStyles.fieldHint,
                  textAlign: TextAlign.center),
            )
          else
            ...appointments.map((a) => _buildAppointmentCard(a, statusColor)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
      AppointmentEntity appointment, Color? statusColor) {
    final color = statusColor ?? _statusColor(appointment.status);
    final time = _formatTime(appointment.scheduledDatetime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.patientName,
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(time, style: AppTextStyles.cardSubtitle),
                    const SizedBox(width: 10),
                    const Icon(Icons.videocam_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      appointment.consultationType == 'teleconsultation'
                          ? 'Video'
                          : 'In-person',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appointment.status,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(String datetime) {
    try {
      final dt = DateTime.parse(datetime).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return datetime;
    }
  }
}

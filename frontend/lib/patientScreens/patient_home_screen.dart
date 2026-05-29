import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'patient_dashboard/patient_dashboard_bloc.dart';
import 'patient_dashboard/patient_dashboard_entity.dart';
import 'patient_dashboard/patient_dashboard_event.dart';
import 'patient_dashboard/patient_dashboard_remote_datasource.dart';
import 'patient_dashboard/patient_dashboard_repository_impl.dart';
import 'patient_dashboard/patient_dashboard_state.dart';
import 'patient_dashboard/patient_dashboard_usecase.dart';
import 'booking/my_appointments_screen.dart';
import 'booking/doctor_list_screen.dart';
import 'medical_records/medical_records_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientDashboardBloc(
        GetPatientDashboardUseCase(
          PatientDashboardRepositoryImpl(
            PatientDashboardRemoteDataSourceImpl(),
          ),
        ),
      )..add(LoadPatientDashboard()),
      child: const _PatientHomeView(),
    );
  }
}

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDashboardBloc, PatientDashboardState>(
      builder: (context, state) {
        if (state is PatientDashboardLoading || state is PatientDashboardInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is PatientDashboardError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(state.message,
                        style: AppTextStyles.fieldLabel,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<PatientDashboardBloc>()
                        .add(RefreshPatientDashboard()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is PatientDashboardLoaded) {
          return _PatientDashboardContent(dashboard: state.dashboard);
        }
        return const Scaffold(body: SizedBox());
      },
    );
  }
}

class _PatientDashboardContent extends StatelessWidget {
  final PatientDashboardEntity dashboard;
  const _PatientDashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<PatientDashboardBloc>().add(RefreshPatientDashboard()),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildOverviewSection()),
          if (dashboard.upcomingAppointment != null)
            SliverToBoxAdapter(child: _buildUpcomingCard(context)),
          if (dashboard.recentPrescriptions.isNotEmpty)
            SliverToBoxAdapter(child: _buildPrescriptionsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final p = dashboard.patient;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3ECCAF), Color(0xFF29A88E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(p),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,',
                            style: AppTextStyles.loginSubtitle
                                .copyWith(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(p.fullName,
                            style: AppTextStyles.loginTitle
                                .copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  _buildNotificationBell(context),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickStat(
                        '${dashboard.unreadMessagesCount}',
                        'Messages',
                        Icons.chat_bubble_outline),
                    _buildDivider(),
                    _buildQuickStat(
                        '${dashboard.stats.totalAppointments}',
                        'Appointments',
                        Icons.calendar_month_outlined),
                    _buildDivider(),
                    _buildQuickStat(
                        '${dashboard.recentPrescriptions.length}',
                        'Prescriptions',
                        Icons.medication_outlined),
                    _buildDivider(),
                    _buildQuickStat(
                        '${dashboard.stats.completed}',
                        'Completed',
                        Icons.check_circle_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(PatientInfo p) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white.withOpacity(0.3),
        child: Text(
          p.fullName.isNotEmpty ? p.fullName[0].toUpperCase() : 'P',
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 24),
        ),
        if (dashboard.unreadNotificationsCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: Color(0xFFEF4444), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  dashboard.unreadNotificationsCount > 9
                      ? '9+'
                      : '${dashboard.unreadNotificationsCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                fontFamily: 'Inter')),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 10, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 36, color: Colors.white30);
  }

  // ── Quick Actions ────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          _buildActionCard(
            context,
            icon: Icons.search_rounded,
            label: 'Find Doctor',
            color: AppColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DoctorListScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionCard(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'My Appointments',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MyAppointmentsScreen()),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionCard(
            context,
            icon: Icons.medical_services_rounded,
            label: 'Medical Records',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MedicalRecordsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF374151)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats Overview ───────────────────────────────────────────
  Widget _buildOverviewSection() {
    final s = dashboard.stats;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF111827))),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.65,
            children: [
              _buildStatCard('Total', '${s.totalAppointments}',
                  Icons.calendar_month_outlined, AppColors.primary),
              _buildStatCard('Completed', '${s.completed}',
                  Icons.check_circle_outline, const Color(0xFF10B981)),
              _buildStatCard('Pending', '${s.pending}',
                  Icons.hourglass_top_outlined, const Color(0xFFF59E0B)),
              _buildStatCard('Confirmed', '${s.confirmed}',
                  Icons.event_available_outlined, const Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upcoming Appointment ─────────────────────────────────────
  Widget _buildUpcomingCard(BuildContext context) {
    final a = dashboard.upcomingAppointment!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text('Upcoming Appointment',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.02)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${a.doctorName}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 3),
                      Text(a.doctorSpecialization,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Inter')),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(_formatDateTime(a.scheduledDatetime),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: 'Inter')),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(a.clinicName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Inter'),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Prescriptions ─────────────────────────────────────
  Widget _buildPrescriptionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              const Text('Recent Prescriptions',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 12),
          ...dashboard.recentPrescriptions.map(_buildPrescriptionCard),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionSummaryEntity p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_outlined,
                color: Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.medicationName,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text('${p.dosage} · ${p.durationDays} days',
                    style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter')),
                Text('by Dr. ${p.doctorName}',
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          Text(_formatDateShort(p.date),
              style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _formatDateTime(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      final day = '${d.day}/${d.month}/${d.year}';
      final time =
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      return '$day at $time';
    } catch (_) {
      return dt;
    }
  }

  String _formatDateShort(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return '${d.day}/${d.month}';
    } catch (_) {
      return dt;
    }
  }
}

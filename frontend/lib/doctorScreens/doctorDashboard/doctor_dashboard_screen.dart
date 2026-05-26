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
          DashboardRepositoryImpl(DashboardRemoteDataSourceImpl()),
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is DashboardError) {
          return Center(
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
                  onPressed: () =>
                      context.read<DashboardBloc>().add(RefreshDashboard()),
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
          );
        }
        if (state is DashboardLoaded) {
          return _DashboardContent(dashboard: state.dashboard);
        }
        return const SizedBox();
      },
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
      onRefresh: () async =>
          context.read<DashboardBloc>().add(RefreshDashboard()),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildOverviewSection()),
          SliverToBoxAdapter(child: _buildAppointmentSection(
            context,
            title: "Today's Appointments",
            icon: Icons.today_outlined,
            appointments: dashboard.todayAppointments,
            emptyMessage: 'No appointments today',
            accentColor: AppColors.primary,
          )),
          SliverToBoxAdapter(child: _buildAppointmentSection(
            context,
            title: 'Pending Requests',
            icon: Icons.pending_actions_outlined,
            appointments: dashboard.pendingAppointments,
            emptyMessage: 'No pending requests',
            accentColor: const Color(0xFFF59E0B),
          )),
          SliverToBoxAdapter(child: _buildAppointmentSection(
            context,
            title: 'Upcoming (7 days)',
            icon: Icons.schedule_outlined,
            appointments: dashboard.upcomingAppointments,
            emptyMessage: 'No upcoming appointments',
            accentColor: const Color(0xFF6366F1),
          )),
          if (dashboard.recentReviews.isNotEmpty)
            SliverToBoxAdapter(child: _buildReviewsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Gradient header ──────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final d = dashboard.doctor;
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
              // Top row: avatar + name + notification bell
              Row(
                children: [
                  _buildAvatar(d),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${d.fullName}',
                            style: AppTextStyles.loginTitle
                                .copyWith(fontSize: 20)),
                        const SizedBox(height: 3),
                        Text(d.specialization,
                            style: AppTextStyles.loginSubtitle
                                .copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildNotificationBell(context),
                ],
              ),

              // Verification warning
              if (d.verificationStatus != 'approved') ...[
                const SizedBox(height: 12),
                _buildVerificationBadge(d.verificationStatus),
              ],

              const SizedBox(height: 20),

              // Quick stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickStat('${dashboard.unreadMessages}',
                        'Messages', Icons.chat_bubble_outline),
                    _buildDivider(),
                    _buildQuickStat('${dashboard.stats.totalClinics}',
                        'Clinics', Icons.local_hospital_outlined),
                    _buildDivider(),
                    _buildQuickStat(
                        dashboard.stats.avgRating != null
                            ? dashboard.stats.avgRating!.toStringAsFixed(1)
                            : 'N/A',
                        'Rating',
                        Icons.star_outline_rounded),
                    _buildDivider(),
                    _buildQuickStat('${dashboard.stats.totalReviews}',
                        'Reviews', Icons.rate_review_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(DoctorInfo d) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white.withOpacity(0.3),
        child: d.image != null
            ? ClipOval(
                child: Image.network(d.image!,
                    width: 56, height: 56, fit: BoxFit.cover))
            : const Icon(Icons.person, color: Colors.white, size: 32),
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
        if (dashboard.unreadNotifications > 0)
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
                  dashboard.unreadNotifications > 9
                      ? '9+'
                      : '${dashboard.unreadNotifications}',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 15),
          const SizedBox(width: 6),
          Text('Account ${status[0].toUpperCase()}${status.substring(1)}',
              style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
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

  // ── Stats overview ───────────────────────────────────────────
  Widget _buildOverviewSection() {
    final s = dashboard.stats;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
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
              _buildStatCard('Rate', '${s.completionRate}%',
                  Icons.trending_up_rounded, const Color(0xFF6366F1)),
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

  // ── Appointment section ──────────────────────────────────────
  Widget _buildAppointmentSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<AppointmentEntity> appointments,
    required String emptyMessage,
    required Color accentColor,
  }) {
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
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF111827))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${appointments.length}',
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontFamily: 'Inter')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (appointments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Icon(icon, color: const Color(0xFFD1D5DB), size: 32),
                  const SizedBox(height: 6),
                  Text(emptyMessage,
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'Inter',
                          fontSize: 14)),
                ],
              ),
            )
          else
            ...appointments.map((a) => _buildAppointmentCard(a, accentColor)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity a, Color accentColor) {
    final time = _formatTime(a.scheduledDatetime);
    final statusColor = _statusColor(a.status);
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.patientName,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF111827))),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 3),
                    Text(time,
                        style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontFamily: 'Inter')),
                    const SizedBox(width: 10),
                    Icon(
                      a.consultationType == 'teleconsultation'
                          ? Icons.videocam_outlined
                          : Icons.local_hospital_outlined,
                      size: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      a.consultationType == 'teleconsultation'
                          ? 'Video'
                          : 'In-person',
                      style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              a.status[0].toUpperCase() + a.status.substring(1),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent reviews ───────────────────────────────────────────
  Widget _buildReviewsSection() {
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
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 16),
              ),
              const SizedBox(width: 8),
              const Text('Recent Reviews',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF111827))),
              const Spacer(),
              if (dashboard.stats.avgRating != null)
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFBBF24), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      dashboard.stats.avgRating!.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFFFBBF24),
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...dashboard.recentReviews.map(_buildReviewCard),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewSummaryEntity r) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStars(r.avgRating),
              const Spacer(),
              Text(
                _formatDate(r.createdAt),
                style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontFamily: 'Inter'),
              ),
            ],
          ),
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.comment!,
                style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    fontFamily: 'Inter')),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              color: Color(0xFFFBBF24), size: 16);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              color: Color(0xFFFBBF24), size: 16);
        } else {
          return const Icon(Icons.star_outline_rounded,
              color: Color(0xFFD1D5DB), size: 16);
        }
      }),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':  return const Color(0xFF10B981);
      case 'pending':    return const Color(0xFFF59E0B);
      case 'canceled':   return const Color(0xFFEF4444);
      case 'completed':  return AppColors.primary;
      case 'rejected':   return const Color(0xFFEF4444);
      default:           return const Color(0xFF6B7280);
    }
  }

  String _formatTime(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dt;
    }
  }
}

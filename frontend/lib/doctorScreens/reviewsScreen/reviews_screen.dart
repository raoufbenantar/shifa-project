import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import 'reviews_cubit.dart';
import 'reviews_entity.dart';
import 'reviews_remote_datasource.dart';
import 'reviews_repository_impl.dart';
import 'reviews_usecase.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final ds = ReviewsRemoteDataSourceImpl();
        final repo = ReviewsRepositoryImpl(ds);
        return ReviewsCubit(GetReviewsUseCase(repo))..load();
      },
      child: const _ReviewsView(),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3ECCAF), Color(0xFF29A88E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reviews & Ratings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter')),
              SizedBox(height: 2),
              Text('What patients are saying',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Inter')),
            ],
          ),
          const Spacer(),
          BlocBuilder<ReviewsCubit, ReviewsState>(
            builder: (ctx, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => ctx.read<ReviewsCubit>().load(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ReviewsCubit, ReviewsState>(
      builder: (ctx, state) {
        if (state is ReviewsLoading || state is ReviewsInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ReviewsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  onPressed: () => ctx.read<ReviewsCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ReviewsLoaded) {
          final items = state.list;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No reviews yet',
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                          fontSize: 15)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctx.read<ReviewsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(state),
                const SizedBox(height: 20),
                const Text('Patient Feedback',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF111827))),
                const SizedBox(height: 10),
                ...items.map((r) => _ReviewItemCard(item: r)),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryCard(ReviewsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      state.overallAvg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 48,
                          color: Color(0xFF111827)),
                    ),
                    _buildStars(state.overallAvg, size: 20),
                    const SizedBox(height: 6),
                    Text(
                      'Based on ${state.list.length} reviews',
                      style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 80, color: const Color(0xFFE5E7EB)),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSubRatingRow(
                        'Waiting time', state.avgWaiting, const Color(0xFFF59E0B)),
                    const SizedBox(height: 8),
                    _buildSubRatingRow(
                        'Hygiene', state.avgHygiene, const Color(0xFF10B981)),
                    const SizedBox(height: 8),
                    _buildSubRatingRow(
                        'Attentiveness', state.avgAttentiveness, const Color(0xFF6366F1)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubRatingRow(String label, double rating, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500)),
            Text(rating.toStringAsFixed(1),
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rating / 5.0,
            color: color,
            backgroundColor: color.withOpacity(0.12),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStars(double rating, {double size = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, color: const Color(0xFFFBBF24), size: size);
        } else {
          return Icon(Icons.star_outline_rounded, color: const Color(0xFFD1D5DB), size: size);
        }
      }),
    );
  }
}

class _ReviewItemCard extends StatelessWidget {
  final ReviewEntity item;
  const _ReviewItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: const Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.patientName,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(date,
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFBBF24), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      item.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.comment != null && item.comment!.trim().isNotEmpty) ...[
            Text(
              item.comment!,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  height: 1.4,
                  color: Color(0xFF374151)),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricText('Wait Time', item.ratingWaiting),
              _buildMetricText('Hygiene', item.ratingHygiene),
              _buildMetricText('Attention', item.ratingAttentiveness),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricText(String label, int val) {
    return Row(
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
        Text('$val/5',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151))),
      ],
    );
  }

  String _formatDate(String dtStr) {
    try {
      final d = DateTime.parse(dtStr).toLocal();
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dtStr;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'patient_profile_bloc.dart';
import 'patient_profile_event.dart';
import 'patient_profile_state.dart';
import 'patient_profile_entity.dart';
import 'patient_profile_remote_datasource.dart';
import 'patient_profile_repository_impl.dart';
import 'get_patient_profile_usecase.dart';
import 'update_patient_profile_usecase.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientProfileBloc(
        GetPatientProfileUseCase(
          PatientProfileRepositoryImpl(
            PatientProfileRemoteDataSourceImpl(),
          ),
        ),
        UpdatePatientProfileUseCase(
          PatientProfileRepositoryImpl(
            PatientProfileRemoteDataSourceImpl(),
          ),
        ),
      )..add(const LoadPatientProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientProfileBloc, PatientProfileState>(
      listener: (context, state) {
        if (state is PatientProfileSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is PatientProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        if (state is PatientProfileSaveFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PatientProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is PatientProfileError && state is! PatientProfileLoaded) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
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
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<PatientProfileBloc>()
                          .add(const LoadPatientProfile()),
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
            ),
          );
        }
        if (state is PatientProfileLoaded) {
          return _ProfileForm(profile: state.profile, isEditing: state.isEditing, isSaving: false);
        }
        if (state is PatientProfileSaving) {
          return _ProfileForm(profile: state.profile, isEditing: true, isSaving: true);
        }
        if (state is PatientProfileSaveFailure) {
          return _ProfileForm(profile: state.profile, isEditing: true, isSaving: false);
        }
        return const Scaffold(body: SizedBox());
      },
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final PatientProfileEntity profile;
  final bool isEditing;
  final bool isSaving;

  const _ProfileForm({
    required this.profile,
    required this.isEditing,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(child: _buildAvatarSection(context)),
          SliverToBoxAdapter(child: _buildInfoCard(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('My Profile',
                    style: AppTextStyles.loginTitle
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 44),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final bloc = context.read<PatientProfileBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildField(
            label: 'Full Name',
            value: profile.fullName,
            icon: Icons.person_outline,
            field: ProfileField.fullName,
            bloc: bloc,
            readOnly: !isEditing,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'Phone Number',
            value: profile.phoneNumber,
            icon: Icons.phone_outlined,
            field: ProfileField.phoneNumber,
            bloc: bloc,
            readOnly: !isEditing,
          ),
          const SizedBox(height: 12),
          _buildReadOnlyField(
            label: 'Email',
            value: profile.email ?? '—',
            icon: Icons.email_outlined,
          ),
          if (profile.nationalId != null) ...[
            const SizedBox(height: 12),
            _buildField(
              label: 'National ID',
              value: profile.nationalId!,
              icon: Icons.badge_outlined,
              field: ProfileField.nationalId,
              bloc: bloc,
              readOnly: !isEditing,
            ),
          ],
          if (profile.dateOfBirth != null) ...[
            const SizedBox(height: 12),
            _buildField(
              label: 'Date of Birth',
              value: profile.dateOfBirth!,
              icon: Icons.calendar_today_outlined,
              field: ProfileField.dateOfBirth,
              bloc: bloc,
              readOnly: !isEditing,
            ),
          ],
          const SizedBox(height: 12),
          _buildGenderField(context, bloc),
          const SizedBox(height: 24),
          _buildActionButtons(context, bloc, isSaving),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required IconData icon,
    required ProfileField field,
    required PatientProfileBloc bloc,
    bool readOnly = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.fieldLabel
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          readOnly
              ? Text(value,
                  style: AppTextStyles.fieldLabel
                      .copyWith(fontSize: 16, color: const Color(0xFF111827)))
              : TextFormField(
                  initialValue: value,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF111827)),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) =>
                      bloc.add(UpdatePatientProfileField(field, v)),
                ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.fieldLabel
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.fieldLabel
                  .copyWith(fontSize: 16, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildGenderField(BuildContext context, PatientProfileBloc bloc) {
    final genderValue = profile.gender ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wc_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Gender',
                  style: AppTextStyles.fieldLabel
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          isEditing
              ? DropdownButtonFormField<String>(
                  value: genderValue.isEmpty ? null : genderValue,
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Male')),
                    DropdownMenuItem(value: 'F', child: Text('Female')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      bloc.add(
                          UpdatePatientProfileField(ProfileField.gender, v));
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                )
              : Text(
                  genderValue == 'M'
                      ? 'Male'
                      : genderValue == 'F'
                          ? 'Female'
                          : '—',
                  style: AppTextStyles.fieldLabel.copyWith(
                      fontSize: 16, color: const Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, PatientProfileBloc bloc, bool saving) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: OutlinedButton(
              onPressed: saving
                  ? null
                  : () => bloc.add(const ToggleEditMode(false)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
          ),
        if (isEditing) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: saving
                ? null
                : () {
                    if (isEditing) {
                      bloc.add(const SavePatientProfile());
                    } else {
                      bloc.add(const ToggleEditMode(true));
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    isEditing ? 'Save Changes' : 'Edit Profile',
                    style: const TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

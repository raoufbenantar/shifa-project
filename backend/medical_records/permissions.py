from rest_framework.permissions import BasePermission


class IsAdminOrDoctorOrPatientOwner(BasePermission):
    """
    Custom permission:
    - Admin/Doctor: full access to all records
    - Patient: read-only access to their own records
    """

    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        role = getattr(request.user, 'role', None)
        role_name = role.name if role else ''
        if role_name in ['admin', 'doctor']:
            return True
        if role_name == 'patient' and view.action in ['list', 'retrieve']:
            return True
        return False

    def has_object_permission(self, request, view, obj):
        role_name = getattr(request.user.role, 'name', '')
        if role_name == 'admin':
            return True
        if role_name == 'doctor':
            return True
        # Patient can only access their own medical record
        if role_name == 'patient':
            patient = getattr(request.user, 'patient_profile', None)
            if patient is None:
                return False
            # Navigate through relations to find the patient
            if hasattr(obj, 'patient'):
                return obj.patient == patient
            if hasattr(obj, 'medical_record'):
                return obj.medical_record.patient == patient
            if hasattr(obj, 'consultation'):
                return obj.consultation.medical_record.patient == patient
        return False


class IsPatientOwner(BasePermission):
    """Allow patients to access their own records only."""

    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        role_name = getattr(request.user.role, 'name', '')
        if role_name == 'patient' and view.action in ['list', 'retrieve']:
            return True
        return False

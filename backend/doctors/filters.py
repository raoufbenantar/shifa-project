import django_filters
from .models import DoctorProfile, Clinic


class DoctorFilter(django_filters.FilterSet):
    specialization = django_filters.CharFilter(
        field_name='specialization', lookup_expr='icontains'
    )
    min_fee = django_filters.NumberFilter(
        field_name='consultation_fee', lookup_expr='gte'
    )
    max_fee = django_filters.NumberFilter(
        field_name='consultation_fee', lookup_expr='lte'
    )
    min_experience = django_filters.NumberFilter(
        field_name='experience_years', lookup_expr='gte'
    )
    city = django_filters.CharFilter(
        field_name='clinics__clinic__city', lookup_expr='iexact'
    )
    available_on = django_filters.CharFilter(
        field_name='availability__day_of_week', lookup_expr='iexact'
    )

    class Meta:
        model = DoctorProfile
        fields = ['specialization', 'is_active', 'min_fee', 'max_fee',
                  'min_experience', 'city', 'available_on']


class ClinicFilter(django_filters.FilterSet):
    city = django_filters.CharFilter(
        field_name='city', lookup_expr='icontains'
    )
    type = django_filters.CharFilter(
        field_name='type', lookup_expr='iexact'
    )
    name = django_filters.CharFilter(
        field_name='name', lookup_expr='icontains'
    )

    class Meta:
        model = Clinic
        fields = ['city', 'type', 'name']
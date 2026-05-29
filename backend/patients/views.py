from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from users.permissions import IsAdminRole, IsAuthenticated
from .models import PatientProfile
from .serializers import PatientSerializer


class PatientViewSet(viewsets.ModelViewSet):
    queryset = PatientProfile.objects.all()
    serializer_class = PatientSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['gender']
    search_fields = ['full_name', 'phone_number']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAdminRole()]  # only admin can list all patients
        return [IsAuthenticated()]

    @action(detail=False, methods=['get', 'patch'])
    def me(self, request):
        try:
            patient = PatientProfile.objects.get(user_id=request.user.id)
        except PatientProfile.DoesNotExist:
            return Response(
                {'error': 'Patient profile not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        if request.method == 'GET':
            serializer = self.get_serializer(patient)
            return Response(serializer.data)

        serializer = self.get_serializer(
            patient, data=request.data, partial=True,
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

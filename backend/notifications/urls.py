from django.urls import path
from . import views

urlpatterns = [
    path('register-token/', views.register_device_token, name='register-device-token'),
    path('unregister-token/', views.unregister_device_token, name='unregister-device-token'),
]

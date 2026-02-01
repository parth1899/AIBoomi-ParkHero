from django.urls import path
from . import views

urlpatterns = [
    path('validate/', views.validate_access, name='validate-access'),
    path('qr/<int:booking_id>/', views.get_qr_code, name='get-qr-code'),
    path('barrier/validate/', views.validate_barrier, name='validate-barrier'),
]

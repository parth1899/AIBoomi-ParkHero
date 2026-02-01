from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'facilities', views.MobileFacilityViewSet, basename='mobile-facility')
router.register(r'floors', views.MobileFloorViewSet, basename='mobile-floor')

urlpatterns = [
    path('', include(router.urls)),
    path('bookings/', views.create_mobile_booking, name='mobile-create-booking'),
    path('bookings/me/', views.my_mobile_bookings, name='mobile-my-bookings'),
    path('access/validate/', views.validate_mobile_access, name='mobile-validate-access'),
]

"""
URL configuration for parkhero project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    # Admin panel
    path('admin/', admin.site.urls),
    
    # Authentication
    path('api/auth/token/', obtain_auth_token, name='api-token-auth'),
    
    # Internal APIs (for admin/management)
    path('api/atlas/', include('apps.atlas.urls')),
    path('api/orbit/', include('apps.orbit.urls')),
    path('api/lockbox/', include('apps.lockbox.urls')),
    
    # Mobile-facing API (aggregation layer)
    path('api/mobile/', include('apps.frontier_api.urls')),
    
    # DRF browsable API auth
    path('api-auth/', include('rest_framework.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

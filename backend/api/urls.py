from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from . import views

urlpatterns = [
    # Health
    path('health/', views.health, name='health'),

    # Auth
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/profile/', views.ProfileView.as_view(), name='profile'),

    # Stories
    path('stories/', views.StoryListView.as_view(), name='story-list'),
    path('stories/<int:pk>/', views.StoryDetailView.as_view(), name='story-detail'),
    path('stories/create/', views.StoryCreateView.as_view(), name='story-create'),

    # Categories
    path('categories/', views.CategoryListView.as_view(), name='category-list'),

    # Purchases
    path('stories/<int:story_id>/purchase/', views.purchase_story, name='purchase-story'),
    path('my-purchases/', views.my_purchases, name='my-purchases'),
]

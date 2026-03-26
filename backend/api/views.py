from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Category, Story, Purchase
from .serializers import (
    CategorySerializer,
    StorySerializer,
    StoryCreateSerializer,
    UserSerializer,
)

User = get_user_model()


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        username = request.data.get('username', '').strip()
        email = request.data.get('email', '').strip()
        password = request.data.get('password', '')

        if not username or not password:
            return Response(
                {'detail': 'username and password are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if User.objects.filter(username=username).exists():
            return Response(
                {'detail': 'Username already taken.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.create_user(username=username, email=email, password=password)
        refresh = RefreshToken.for_user(user)
        return Response(
            {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user': UserSerializer(user).data,
            },
            status=status.HTTP_201_CREATED,
        )


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


# ---------------------------------------------------------------------------
# Categories
# ---------------------------------------------------------------------------

class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]


# ---------------------------------------------------------------------------
# Stories
# ---------------------------------------------------------------------------

class StoryListView(generics.ListAPIView):
    serializer_class = StorySerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        qs = Story.objects.select_related('author', 'category')
        category = self.request.query_params.get('category')
        search = self.request.query_params.get('search')
        featured = self.request.query_params.get('featured')

        if category:
            qs = qs.filter(category__name__iexact=category)
        if search:
            qs = qs.filter(title__icontains=search)
        if featured == 'true':
            qs = qs.filter(is_featured=True)
        return qs


class StoryDetailView(generics.RetrieveAPIView):
    queryset = Story.objects.select_related('author', 'category')
    serializer_class = StorySerializer
    permission_classes = [permissions.AllowAny]


class StoryCreateView(generics.CreateAPIView):
    queryset = Story.objects.all()
    serializer_class = StoryCreateSerializer
    permission_classes = [permissions.IsAuthenticated]


# ---------------------------------------------------------------------------
# Purchases
# ---------------------------------------------------------------------------

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def purchase_story(request, story_id):
    try:
        story = Story.objects.get(pk=story_id)
    except Story.DoesNotExist:
        return Response({'detail': 'Story not found.'}, status=status.HTTP_404_NOT_FOUND)

    _, created = Purchase.objects.get_or_create(user=request.user, story=story)
    if created:
        return Response({'detail': 'Purchase successful.'}, status=status.HTTP_201_CREATED)
    return Response({'detail': 'Already purchased.'}, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def my_purchases(request):
    purchases = Purchase.objects.filter(user=request.user).select_related('story')
    stories = [p.story for p in purchases]
    serializer = StorySerializer(stories, many=True, context={'request': request})
    return Response(serializer.data)


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def health(request):
    return Response({'status': 'ok', 'service': 'StoryZoo API'})

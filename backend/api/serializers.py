from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import Category, Story, Purchase

User = get_user_model()


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']


class StorySerializer(serializers.ModelSerializer):
    author_id = serializers.SerializerMethodField()
    author = serializers.SerializerMethodField()
    category = serializers.SerializerMethodField()
    is_purchased = serializers.SerializerMethodField()

    class Meta:
        model = Story
        fields = [
            'id',
            'title',
            'description',
            'author',
            'author_id',
            'category',
            'cover_image',
            'price',
            'rating',
            'total_reviews',
            'is_purchased',
            'has_audio',
            'audio_duration',
            'published_date',
        ]

    def get_author_id(self, obj):
        return str(obj.author_id) if obj.author_id else ''

    def get_author(self, obj):
        if obj.author_name:
            return obj.author_name
        if obj.author:
            return obj.author.get_full_name() or obj.author.username
        return ''

    def get_category(self, obj):
        return obj.category.name if obj.category else ''

    def get_is_purchased(self, obj):
        request = self.context.get('request')
        if request and request.user and request.user.is_authenticated:
            return Purchase.objects.filter(user=request.user, story=obj).exists()
        return False


class StoryCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Story
        fields = [
            'title',
            'description',
            'author_name',
            'category',
            'cover_image',
            'price',
            'has_audio',
            'audio_duration',
        ]

    def create(self, validated_data):
        request = self.context.get('request')
        validated_data['author'] = request.user
        return super().create(validated_data)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']

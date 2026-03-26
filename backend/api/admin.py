from django.contrib import admin
from .models import Category, Story, Purchase


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']
    search_fields = ['name']


@admin.register(Story)
class StoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'author_name', 'category', 'price', 'rating', 'published_date', 'is_featured']
    list_filter = ['category', 'is_featured', 'has_audio']
    search_fields = ['title', 'description', 'author_name']
    list_editable = ['is_featured']


@admin.register(Purchase)
class PurchaseAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'story', 'purchased_at']
    list_filter = ['purchased_at']
    search_fields = ['user__username', 'story__title']

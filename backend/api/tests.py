from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Category, Story, Purchase

User = get_user_model()


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return str(refresh.access_token)


class HealthCheckTest(APITestCase):
    def test_health_endpoint_returns_ok(self):
        url = reverse('health')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'ok')


class AuthTests(APITestCase):
    def test_register_creates_user_and_returns_tokens(self):
        url = reverse('register')
        data = {'username': 'testuser', 'email': 'test@example.com', 'password': 'pass1234'}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_register_duplicate_username_returns_400(self):
        User.objects.create_user(username='dup', password='pass')
        url = reverse('register')
        response = self.client.post(url, {'username': 'dup', 'password': 'pass2'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_returns_tokens(self):
        User.objects.create_user(username='loginuser', password='mypass')
        url = reverse('token_obtain_pair')
        response = self.client.post(url, {'username': 'loginuser', 'password': 'mypass'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)

    def test_profile_requires_auth(self):
        url = reverse('profile')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_profile_returns_user_data(self):
        user = User.objects.create_user(username='profileuser', password='pass')
        token = get_tokens_for_user(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        url = reverse('profile')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['username'], 'profileuser')


class StoryTests(APITestCase):
    def setUp(self):
        self.category = Category.objects.create(name='Folklore')
        self.user = User.objects.create_user(username='author', password='pass')
        self.story = Story.objects.create(
            title='Test Hadithi',
            description='Maelezo ya hadithi',
            author=self.user,
            author_name='Author Name',
            category=self.category,
            price=0,
        )

    def test_story_list_is_public(self):
        url = reverse('story-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_story_list_returns_stories(self):
        url = reverse('story-list')
        response = self.client.get(url)
        self.assertEqual(len(response.data['results']), 1)
        self.assertEqual(response.data['results'][0]['title'], 'Test Hadithi')

    def test_story_detail_is_public(self):
        url = reverse('story-detail', args=[self.story.pk])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Test Hadithi')

    def test_story_filter_by_category(self):
        other_cat = Category.objects.create(name='Adventure')
        Story.objects.create(
            title='Adventure Story',
            description='desc',
            author=self.user,
            author_name='Author',
            category=other_cat,
            price=0,
        )
        url = reverse('story-list') + '?category=Folklore'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_story_search(self):
        url = reverse('story-list') + '?search=Test'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_create_story_requires_auth(self):
        url = reverse('story-create')
        response = self.client.post(url, {'title': 'New', 'description': 'desc', 'price': 0})
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_story_authenticated(self):
        token = get_tokens_for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        url = reverse('story-create')
        data = {
            'title': 'New Story',
            'description': 'A new story',
            'author_name': 'Author',
            'category': self.category.pk,
            'price': 0,
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)


class PurchaseTests(APITestCase):
    def setUp(self):
        self.category = Category.objects.create(name='Adventure')
        self.user = User.objects.create_user(username='buyer', password='pass')
        self.story = Story.objects.create(
            title='Purchasable',
            description='desc',
            author=self.user,
            author_name='Author',
            category=self.category,
            price=100,
        )
        self.token = get_tokens_for_user(self.user)

    def test_purchase_requires_auth(self):
        url = reverse('purchase-story', args=[self.story.pk])
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_purchase_story(self):
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        url = reverse('purchase-story', args=[self.story.pk])
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_duplicate_purchase_returns_200(self):
        Purchase.objects.create(user=self.user, story=self.story)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        url = reverse('purchase-story', args=[self.story.pk])
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_my_purchases_requires_auth(self):
        url = reverse('my-purchases')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_my_purchases_returns_purchased_stories(self):
        Purchase.objects.create(user=self.user, story=self.story)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        url = reverse('my-purchases')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['title'], 'Purchasable')

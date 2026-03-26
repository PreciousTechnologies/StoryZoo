"""
Management command: seed_data
Creates sample categories and stories for development.
Usage: python manage.py seed_data
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from api.models import Category, Story

User = get_user_model()

CATEGORIES = [
    'Adventure', 'Love', 'Folklore', 'Moral Stories',
    'Fairy Tales', 'Mystery', 'Science Fiction', 'Historical',
]

SAMPLE_STORIES = [
    {
        'title': 'Simba na Paka',
        'description': 'Hadithi ya simba mkubwa na paka mdogo waliokuwa marafiki wa karibu katika msitu wa Afrika.',
        'author_name': 'Amina Hassan',
        'category': 'Folklore',
        'cover_image': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800&q=80',
        'price': 0,
        'has_audio': True,
        'audio_duration': 720,
        'is_featured': True,
    },
    {
        'title': 'Safari ya Bahari',
        'description': 'Msafiri mdogo anasafiri baharini na kupata maarifa mengi kuhusu ulimwengu.',
        'author_name': 'Juma Mwangi',
        'category': 'Adventure',
        'cover_image': 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=800&q=80',
        'price': 150,
        'has_audio': False,
        'is_featured': True,
    },
    {
        'title': 'Moyo wa Upendo',
        'description': 'Hadithi ya mapenzi kati ya vijana wawili toka vijiji tofauti.',
        'author_name': 'Fatuma Ally',
        'category': 'Love',
        'cover_image': 'https://images.unsplash.com/photo-1474552226712-ac0f0961a954?w=800&q=80',
        'price': 200,
        'has_audio': True,
        'audio_duration': 1800,
        'is_featured': False,
    },
    {
        'title': 'Hekima ya Mzee',
        'description': 'Mzee mwenye hekima anafundisha vijana wa kijiji mambo muhimu ya maisha.',
        'author_name': 'Ibrahim Salim',
        'category': 'Moral Stories',
        'cover_image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
        'price': 0,
        'has_audio': False,
        'is_featured': False,
    },
    {
        'title': 'Ndoto za Usiku',
        'description': 'Mtoto mdogo anapitia safari za ajabu katika ndoto zake za usiku.',
        'author_name': 'Zainab Omar',
        'category': 'Fairy Tales',
        'cover_image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
        'price': 100,
        'has_audio': True,
        'audio_duration': 540,
        'is_featured': True,
    },
]


class Command(BaseCommand):
    help = 'Seeds the database with sample categories and stories.'

    def handle(self, *args, **options):
        # Categories
        for name in CATEGORIES:
            cat, created = Category.objects.get_or_create(name=name)
            if created:
                self.stdout.write(self.style.SUCCESS(f'  Created category: {name}'))

        # Admin user
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin', 'admin@storyzoo.com', 'admin1234')
            self.stdout.write(self.style.SUCCESS('  Created superuser: admin / admin1234'))

        # Stories
        for data in SAMPLE_STORIES:
            category_name = data.pop('category')
            category = Category.objects.get(name=category_name)
            _, created = Story.objects.get_or_create(
                title=data['title'],
                defaults={**data, 'category': category},
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f"  Created story: {data['title']}"))

        self.stdout.write(self.style.SUCCESS('Seed data complete.'))

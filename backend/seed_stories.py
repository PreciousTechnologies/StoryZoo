from datetime import timedelta
from random import Random

from django.utils import timezone

from stories.models import Story


randomizer = Random(20260326)
now = timezone.now()
stories_per_category = 10

categories = [
    'Watoto',
    'Elimu',
    'Imani',
    'Hadithi',
    'Biashara',
    'Adventure',
    'Love',
    'Folklore',
    'Moral Stories',
    'Fairy Tales',
    'Mystery',
    'Science Fiction',
    'Historical',
]

cover_pool = {
    'Watoto': [
        'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800&q=80',
        'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=800&q=80',
        'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=800&q=80',
    ],
    'Elimu': [
        'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&q=80',
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
        'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&q=80',
    ],
    'Imani': [
        'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80',
        'https://images.unsplash.com/photo-1478145787956-f6f12c59624d?w=800&q=80',
        'https://images.unsplash.com/photo-1521336575822-6da63fb45455?w=800&q=80',
    ],
    'Hadithi': [
        'https://images.unsplash.com/photo-1455885666463-9b7f32d8f2ee?w=800&q=80',
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
        'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?w=800&q=80',
    ],
    'Biashara': [
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&q=80',
        'https://images.unsplash.com/photo-1444653614773-995cb1ef9efa?w=800&q=80',
    ],
    'Adventure': [
        'https://images.unsplash.com/photo-1535338454770-6f8c583cd0a4?w=800&q=80',
        'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=800&q=80',
        'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800&q=80',
    ],
    'Love': [
        'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=800&q=80',
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=800&q=80',
        'https://images.unsplash.com/photo-1494774157365-9e04c6720e47?w=800&q=80',
    ],
    'Folklore': [
        'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800&q=80',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80',
        'https://images.unsplash.com/photo-1462536943532-57a629f6cc60?w=800&q=80',
    ],
    'Moral Stories': [
        'https://images.unsplash.com/photo-1551316679-9c6ae9dec224?w=800&q=80',
        'https://images.unsplash.com/photo-1474552226712-ac0f0961a954?w=800&q=80',
        'https://images.unsplash.com/photo-1516637090014-cb1ab0d08fc7?w=800&q=80',
    ],
    'Fairy Tales': [
        'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&q=80',
        'https://images.unsplash.com/photo-1456086272160-b28b0645b729?w=800&q=80',
        'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=800&q=80',
    ],
    'Mystery': [
        'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
        'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&q=80',
        'https://images.unsplash.com/photo-1465101162946-4377e57745c3?w=800&q=80',
    ],
    'Science Fiction': [
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
        'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800&q=80',
        'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=800&q=80',
    ],
    'Historical': [
        'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=800&q=80',
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80',
        'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800&q=80',
    ],
}

style_ranges = {
    'Watoto': {'price': (500, 1800), 'rating': (4.2, 5.0), 'reviews': (40, 260)},
    'Elimu': {'price': (700, 2200), 'rating': (4.1, 5.0), 'reviews': (30, 220)},
    'Imani': {'price': (600, 2000), 'rating': (4.0, 5.0), 'reviews': (20, 180)},
    'Hadithi': {'price': (700, 2500), 'rating': (3.9, 4.9), 'reviews': (25, 200)},
    'Biashara': {'price': (1500, 4200), 'rating': (3.8, 4.8), 'reviews': (15, 160)},
    'Adventure': {'price': (1200, 3200), 'rating': (4.0, 4.9), 'reviews': (35, 240)},
    'Love': {'price': (1000, 2800), 'rating': (3.9, 4.9), 'reviews': (20, 190)},
    'Folklore': {'price': (900, 2600), 'rating': (4.1, 5.0), 'reviews': (30, 220)},
    'Moral Stories': {'price': (800, 2200), 'rating': (4.2, 5.0), 'reviews': (35, 250)},
    'Fairy Tales': {'price': (1100, 3000), 'rating': (4.0, 4.9), 'reviews': (18, 180)},
    'Mystery': {'price': (1300, 3500), 'rating': (3.7, 4.8), 'reviews': (15, 170)},
    'Science Fiction': {'price': (1400, 3800), 'rating': (3.8, 4.9), 'reviews': (12, 150)},
    'Historical': {'price': (1000, 2900), 'rating': (3.9, 4.9), 'reviews': (22, 190)},
}

descriptions = {
    'Watoto': 'Hadithi fupi kwa watoto yenye mafunzo ya tabia njema na furaha.',
    'Elimu': 'Hadithi ya kujifunza maarifa mapya kupitia safari ya maarifa.',
    'Imani': 'Hadithi ya matumaini, subira, na imani katika maisha ya kila siku.',
    'Hadithi': 'Hadithi ya kusisimua inayochanganya hekima na ubunifu.',
    'Biashara': 'Hadithi ya ujasiriamali, mikakati, na maamuzi ya biashara.',
    'Adventure': 'Safari ya kusisimua iliyojaa changamoto na ushindi.',
    'Love': 'Hadithi ya upendo, heshima, na uaminifu kati ya wahusika.',
    'Folklore': 'Hadithi ya jadi inayotunza urithi wa jamii na mila.',
    'Moral Stories': 'Hadithi ya maadili inayofundisha haki na huruma.',
    'Fairy Tales': 'Hadithi ya kichawi yenye wahusika wa kufikirika na mafunzo.',
    'Mystery': 'Hadithi ya fumbo na uchunguzi wa siri iliyojificha.',
    'Science Fiction': 'Hadithi ya sayansi na teknolojia ya wakati ujao.',
    'Historical': 'Hadithi inayotokana na matukio ya kale na historia halisi.',
}

authors = [
    ('Juma Bakari', 'author1'),
    ('Amina Hassan', 'author2'),
    ('Mohamed Ali', 'author3'),
    ('Fatuma Said', 'author4'),
    ('Hassan Mwinyi', 'author5'),
    ('Neema Salum', 'author6'),
    ('Khalid Omari', 'author7'),
]


def build_story(category: str, index: int) -> dict:
    author_name, author_id = randomizer.choice(authors)
    style = style_ranges[category]
    base_price = randomizer.randint(style['price'][0], style['price'][1])
    rating = round(randomizer.uniform(style['rating'][0], style['rating'][1]), 1)
    reviews = randomizer.randint(style['reviews'][0], style['reviews'][1])
    has_audio = randomizer.choice([True, False])
    cover_image = randomizer.choice(cover_pool[category])
    published_at = now - timedelta(days=randomizer.randint(0, 120), hours=randomizer.randint(0, 23))

    return {
        'title': f'{category} Story {index + 1}',
        'description': descriptions[category],
        'author': author_name,
        'author_id': author_id,
        'category': category,
        'cover_image': cover_image,
        'price': base_price,
        'rating': rating,
        'total_reviews': reviews,
        'has_audio': has_audio,
        'is_published': True,
        'published_at': published_at,
    }


for category in categories:
    for i in range(stories_per_category):
        story = build_story(category, i)
        Story.objects.update_or_create(
            title=story['title'],
            defaults=story,
        )

total_published = Story.objects.filter(is_published=True).count()
print(f'seeded_ok total_published={total_published}')
for category in categories:
    count = Story.objects.filter(is_published=True, category=category).count()
    print(f'category={category} count={count}')

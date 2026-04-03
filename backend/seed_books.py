from django.contrib.auth import get_user_model
from django.utils import timezone

from stories.models import Book, Chapter, Story

User = get_user_model()

author, _ = User.objects.get_or_create(
    username='author_seed',
    defaults={'email': 'author_seed@storyzoo.local', 'is_staff': True},
)

stories = Story.objects.filter(is_published=True)
created_books = 0
created_chapters = 0

for story in stories:
    book, created = Book.objects.update_or_create(
        id=story.id,
        defaults={
            'title': story.title,
            'description': story.description,
            'category': story.category,
            'price': story.price,
            'author': author,
            'status': Book.Status.APPROVED,
        },
    )
    if created:
        created_books += 1

    chapter_1 = (
        f"Sura ya Kwanza\n\n"
        f"{story.description}\n\n"
        "Hii ni sehemu ya utangulizi wa kitabu."
    )
    chapter_2 = (
        "Sura ya Pili\n\n"
        "Mhusika mkuu anakabiliana na changamoto mpya na kujifunza mbinu za kushinda."
    )
    chapter_3 = (
        "Sura ya Tatu\n\n"
        "Hitimisho la hadithi na funzo kuu la maisha kwa wasomaji."
    )

    for order, content in enumerate([chapter_1, chapter_2, chapter_3], start=1):
        _, c_created = Chapter.objects.update_or_create(
            book=book,
            order=order,
            defaults={
                'title': f'{story.title} - Sura {order}',
                'content': content,
            },
        )
        if c_created:
            created_chapters += 1

print(f'seed_books_ok total_books={Book.objects.count()} created_books={created_books}')
print(f'seed_books_ok total_chapters={Chapter.objects.count()} created_chapters={created_chapters}')

import os

import django


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from stories.models import Book, Chapter  # noqa: E402


TEMPLATE_SEED_SENTENCES = {
    'A': (
        'At sunrise a brave reader steps into a living map where every path offers discovery, '
        'gentle danger, smart choices, and meaningful lessons about courage and loyalty. '
        'Each page reveals vivid landscapes, quick decisions, resilient heroes, and warm moments '
        'that reward patience, attention, and imagination in equal measure. '
    ),
    'B': (
        'In a quiet village of storytellers, people trade dreams, memories, and promises that '
        'teach kindness, trust, and empathy through heartfelt dialogue and hopeful turns. '
        'The narrative moves with calm rhythm, thoughtful reflection, and emotional clarity, '
        'guiding listeners toward connection, healing, and deeper understanding. '
    ),
    'C': (
        'Beyond the old city walls, curious minds investigate riddles, forgotten symbols, and '
        'mysterious signals while balancing logic, wonder, and moral responsibility. '
        'Every chapter combines clear reasoning, surprising discoveries, and practical wisdom, '
        'encouraging careful observation, creativity, and forward-thinking action. '
    ),
}

CATEGORY_TEMPLATE_MAP = {
    'Adventure': 'A',
    'Historical': 'A',
    'Watoto': 'A',
    'Moral Stories': 'B',
    'Love': 'B',
    'Fairy Tales': 'B',
    'Folklore': 'B',
    'Imani': 'B',
    'Mystery': 'C',
    'Science Fiction': 'C',
    'Biashara': 'C',
    'Elimu': 'C',
    'Hadithi': 'A',
}


def build_english_text(seed_sentence: str, word_count: int = 1000) -> str:
    words = seed_sentence.split()

    result = []
    while len(result) < word_count:
        remaining = word_count - len(result)
        result.extend(words[:remaining])

    return ' '.join(result)


def main():
    templates = {
        key: build_english_text(seed_sentence=value, word_count=1000)
        for key, value in TEMPLATE_SEED_SENTENCES.items()
    }

    updated = 0
    created = 0
    template_usage = {'A': 0, 'B': 0, 'C': 0}

    for book in Book.objects.all().iterator():
        template_key = CATEGORY_TEMPLATE_MAP.get(book.category)
        if template_key is None:
            fallback_index = (sum(ord(ch) for ch in (book.category or '')) % 3)
            template_key = ['A', 'B', 'C'][fallback_index]

        text = templates[template_key]

        chapter, was_created = Chapter.objects.get_or_create(
            book=book,
            order=1,
            defaults={
                'title': 'Chapter 1 - Piper TTS Test',
                'content': text,
            },
        )

        if was_created:
            created += 1
        else:
            chapter.title = 'Chapter 1 - Piper TTS Test'
            chapter.content = text
            chapter.save(update_fields=['title', 'content'])
            updated += 1

        template_usage[template_key] += 1

    print(f'Books processed: {Book.objects.count()}')
    print(f'Chapter 1 created: {created}')
    print(f'Chapter 1 updated: {updated}')
    print('Template usage:', template_usage)
    print('Word count per template:', {k: len(v.split()) for k, v in templates.items()})


if __name__ == '__main__':
    main()

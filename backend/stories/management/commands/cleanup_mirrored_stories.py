from __future__ import annotations

from dataclasses import dataclass

from django.core.management.base import BaseCommand

from stories.models import Book, Story


@dataclass
class MirrorCandidate:
    story_id: int
    story_title: str
    score: int
    reasons: list[str]


class Command(BaseCommand):
    help = (
        'One-time cleanup for old mirrored Story rows that duplicate Book rows. '
        'Runs in dry-run mode by default.'
    )

    def add_arguments(self, parser):
        parser.add_argument(
            '--apply',
            action='store_true',
            help='Actually delete matched mirrored Story rows. Without this flag, command is dry-run.',
        )
        parser.add_argument(
            '--id-match-only',
            action='store_true',
            help='Treat any Story with the same id as a Book as a duplicate mirror candidate.',
        )
        parser.add_argument(
            '--min-score',
            type=int,
            default=3,
            help='Minimum similarity score to delete when not using --id-match-only (default: 3).',
        )

    def handle(self, *args, **options):
        apply_changes = options['apply']
        id_match_only = options['id_match_only']
        min_score = int(options['min_score'])

        books_by_id = {book.id: book for book in Book.objects.all()}
        if not books_by_id:
            self.stdout.write(self.style.WARNING('No books found. Nothing to clean.'))
            return

        stories = Story.objects.filter(id__in=books_by_id.keys())
        candidates: list[MirrorCandidate] = []

        for story in stories:
            book = books_by_id.get(story.id)
            if not book:
                continue

            reasons: list[str] = []
            score = 0

            if self._same(story.title, book.title):
                score += 1
                reasons.append('title')
            if self._same(story.description, book.description):
                score += 1
                reasons.append('description')
            if self._same(story.author_id, str(book.author_id)):
                score += 1
                reasons.append('author_id')
            if self._same(story.category, book.category):
                score += 1
                reasons.append('category')
            if self._same(story.language, book.language):
                score += 1
                reasons.append('language')

            if id_match_only or score >= min_score:
                candidates.append(
                    MirrorCandidate(
                        story_id=story.id,
                        story_title=story.title,
                        score=score,
                        reasons=reasons,
                    )
                )

        if not candidates:
            self.stdout.write(self.style.SUCCESS('No mirrored Story duplicates found.'))
            return

        self.stdout.write(f'Found {len(candidates)} mirrored Story candidate(s):')
        for item in candidates:
            reason_text = ', '.join(item.reasons) if item.reasons else 'id-match-only'
            self.stdout.write(
                f'  - story_id={item.story_id} title="{item.story_title}" score={item.score} reasons=[{reason_text}]'
            )

        if not apply_changes:
            self.stdout.write(self.style.WARNING('Dry run only. Re-run with --apply to delete these rows.'))
            return

        ids_to_delete = [item.story_id for item in candidates]
        deleted_count, _ = Story.objects.filter(id__in=ids_to_delete).delete()
        self.stdout.write(self.style.SUCCESS(f'Deleted {deleted_count} Story row(s).'))

    @staticmethod
    def _same(left, right) -> bool:
        return (str(left or '').strip().lower()) == (str(right or '').strip().lower())

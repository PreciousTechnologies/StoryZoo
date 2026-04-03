import uuid

from django.conf import settings
from django.db import models

from stories.models import Book


class Payment(models.Model):
    class Purpose(models.TextChoices):
        BOOK_UNLOCK = 'book_unlock', 'Book Unlock'
        SUBSCRIPTION = 'subscription', 'Subscription'

    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order_tracking_id = models.CharField(max_length=128, blank=True)
    merchant_reference = models.CharField(max_length=64, unique=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=8, default='TZS')
    email = models.EmailField()
    purpose = models.CharField(max_length=24, choices=Purpose.choices, default=Purpose.BOOK_UNLOCK)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payments', null=True, blank=True)
    book = models.ForeignKey(Book, on_delete=models.SET_NULL, related_name='payments', null=True, blank=True)
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.merchant_reference} ({self.status})'

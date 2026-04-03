from rest_framework import serializers


class PaymentInitiateSerializer(serializers.Serializer):
    book_id = serializers.IntegerField(min_value=1)
    email = serializers.EmailField(required=False)

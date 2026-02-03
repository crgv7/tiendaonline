from rest_framework import serializers
from .models import Publication


class PublicationSerializer(serializers.ModelSerializer):
    """
    Serializador para el modelo Publication.
    Incluye validaciones personalizadas.
    """
    image_url = serializers.SerializerMethodField()
    whatsapp_link = serializers.SerializerMethodField()

    class Meta:
        model = Publication
        fields = [
            'id',
            'title',
            'description',
            'phone_number',
            'image',
            'image_url',
            'price',
            'is_active',
            'whatsapp_link',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'image_url', 'whatsapp_link']

    def get_image_url(self, obj):
        """Retorna la URL relativa de la imagen (compatible con Docker/Codespaces)."""
        if obj.image:
            # Retornar URL relativa para que funcione con proxy Nginx
            return obj.image.url
        return None

    def get_whatsapp_link(self, obj):
        """Genera el enlace de WhatsApp API."""
        phone = obj.phone_number.replace(' ', '').replace('-', '').replace('+', '')
        message = f"Hola, me interesa el producto: {obj.title}"
        return f"https://wa.me/{phone}?text={message}"

    def validate_phone_number(self, value):
        """Valida que el número de teléfono tenga formato correcto."""
        cleaned = value.replace(' ', '').replace('-', '').replace('+', '')
        if not cleaned.isdigit():
            raise serializers.ValidationError(
                "El número de teléfono solo debe contener dígitos."
            )
        if len(cleaned) < 10:
            raise serializers.ValidationError(
                "El número de teléfono debe tener al menos 10 dígitos."
            )
        return value

    def validate_price(self, value):
        """Valida que el precio sea positivo."""
        if value <= 0:
            raise serializers.ValidationError(
                "El precio debe ser mayor a 0."
            )
        return value


class PublicationListSerializer(serializers.ModelSerializer):
    """
    Serializador simplificado para listados públicos.
    """
    image_url = serializers.SerializerMethodField()
    whatsapp_link = serializers.SerializerMethodField()

    class Meta:
        model = Publication
        fields = [
            'id',
            'title',
            'description',
            'image_url',
            'price',
            'whatsapp_link',
        ]

    def get_image_url(self, obj):
        """Retorna la URL relativa de la imagen."""
        if obj.image:
            return obj.image.url
        return None

    def get_whatsapp_link(self, obj):
        phone = obj.phone_number.replace(' ', '').replace('-', '').replace('+', '')
        message = f"Hola, me interesa el producto: {obj.title}"
        return f"https://wa.me/{phone}?text={message}"

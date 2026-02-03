from django.db import models


class Publication(models.Model):
    """
    Modelo para productos/publicaciones del catálogo.
    """
    title = models.CharField(
        max_length=200,
        verbose_name='Título'
    )
    description = models.TextField(
        verbose_name='Descripción'
    )
    phone_number = models.CharField(
        max_length=20,
        verbose_name='Número WhatsApp',
        help_text='Número de teléfono para contacto por WhatsApp (incluir código de país)'
    )
    image = models.ImageField(
        upload_to='publications/',
        verbose_name='Imagen',
        blank=True,
        null=True
    )
    price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        verbose_name='Precio'
    )
    is_active = models.BooleanField(
        default=True,
        verbose_name='Activo'
    )
    created_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name='Fecha de creación'
    )
    updated_at = models.DateTimeField(
        auto_now=True,
        verbose_name='Última actualización'
    )

    class Meta:
        verbose_name = 'Publicación'
        verbose_name_plural = 'Publicaciones'
        ordering = ['-created_at']

    def __str__(self):
        return self.title

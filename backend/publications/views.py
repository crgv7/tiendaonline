from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Publication
from .serializers import PublicationSerializer, PublicationListSerializer


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Permiso personalizado que permite lectura a cualquiera,
    pero solo escritura a administradores.
    """
    def has_permission(self, request, view):
        # Permitir GET, HEAD, OPTIONS a todos
        if request.method in permissions.SAFE_METHODS:
            return True
        # Solo admins pueden crear/editar/eliminar
        return request.user and request.user.is_staff


class PublicationViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestionar publicaciones/productos.
    
    - GET /api/publications/ - Lista pública de productos activos
    - POST /api/publications/ - Crear producto (solo admin)
    - PUT /api/publications/{id}/ - Actualizar producto (solo admin)
    - DELETE /api/publications/{id}/ - Eliminar producto (solo admin)
    """
    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        """
        Retorna solo publicaciones activas para usuarios no autenticados.
        Admins pueden ver todas.
        """
        if self.request.user.is_authenticated and self.request.user.is_staff:
            return Publication.objects.all()
        return Publication.objects.filter(is_active=True)

    def get_serializer_class(self):
        """
        Usa serializador simplificado para listados públicos,
        completo para admin.
        """
        if self.action == 'list' and not (
            self.request.user.is_authenticated and self.request.user.is_staff
        ):
            return PublicationListSerializer
        return PublicationSerializer

    def create(self, request, *args, **kwargs):
        """Crear nueva publicación."""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(
            serializer.data,
            status=status.HTTP_201_CREATED
        )

    @action(detail=False, methods=['get'])
    def all(self, request):
        """
        Endpoint para admins: ver todas las publicaciones incluyendo inactivas.
        """
        if not request.user.is_authenticated or not request.user.is_staff:
            return Response(
                {'detail': 'No tiene permisos para esta acción.'},
                status=status.HTTP_403_FORBIDDEN
            )
        queryset = Publication.objects.all()
        serializer = PublicationSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)

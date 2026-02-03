# Frontend Flutter Dockerfile
# Etapa 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS build

WORKDIR /app

# Copiar archivos de configuración primero (mejor cache)
COPY pubspec.yaml ./

# Obtener dependencias
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Compilar para web en modo release
RUN flutter build web --release

# Etapa 2: Servir con Nginx
FROM nginx:alpine

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar archivos compilados desde la etapa de build
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer puerto
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

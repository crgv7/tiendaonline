import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/publication.dart';

/// Servicio para comunicación con la API del backend
class ApiService {
  // URL relativa - funciona con proxy Nginx en Docker/Codespaces
  // Para desarrollo local sin Docker, usar: 'http://localhost:8000/api'
  static const String baseUrl = '/api';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Keys para almacenamiento seguro
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Obtiene el token de acceso almacenado
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Guarda los tokens JWT
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Elimina los tokens (logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Headers con autenticación
  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (requireAuth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// Login - obtener tokens JWT
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['access'], data['refresh']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await clearTokens();
  }

  /// Verificar si hay sesión activa
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// Obtener lista de publicaciones (público)
  Future<List<Publication>> getPublications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/publications/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Manejar respuesta paginada o lista directa
        final List<dynamic> results = data is List ? data : (data['results'] ?? []);
        return results.map((json) => Publication.fromJson(json)).toList();
      }
      throw Exception('Error al cargar publicaciones');
    } catch (e) {
      print('Error en getPublications: $e');
      rethrow;
    }
  }

  /// Obtener todas las publicaciones (admin)
  Future<List<Publication>> getAllPublications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/publications/all/'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Publication.fromJson(json)).toList();
      }
      throw Exception('Error al cargar publicaciones');
    } catch (e) {
      print('Error en getAllPublications: $e');
      rethrow;
    }
  }

  /// Crear publicación (admin) con soporte para imagen
  Future<Publication> createPublication(Map<String, dynamic> data, {String? imagePath, Uint8List? imageBytes, String? imageName}) async {
    try {
      final token = await getAccessToken();
      
      if (imageBytes != null && imageName != null) {
        // Usar multipart para subir imagen
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/publications/'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        
        // Agregar campos
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Agregar imagen
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 201) {
          return Publication.fromJson(jsonDecode(response.body));
        }
        throw Exception('Error al crear publicación: ${response.body}');
      } else {
        // Sin imagen - usar JSON normal
        final response = await http.post(
          Uri.parse('$baseUrl/publications/'),
          headers: await _getHeaders(requireAuth: true),
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          return Publication.fromJson(jsonDecode(response.body));
        }
        throw Exception('Error al crear publicación: ${response.body}');
      }
    } catch (e) {
      print('Error en createPublication: $e');
      rethrow;
    }
  }

  /// Actualizar publicación (admin) con soporte para imagen
  Future<Publication> updatePublication(int id, Map<String, dynamic> data, {String? imagePath, Uint8List? imageBytes, String? imageName}) async {
    try {
      final token = await getAccessToken();
      
      if (imageBytes != null && imageName != null) {
        // Usar multipart para subir imagen
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/publications/$id/'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        
        // Agregar campos
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Agregar imagen
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          return Publication.fromJson(jsonDecode(response.body));
        }
        throw Exception('Error al actualizar publicación: ${response.body}');
      } else {
        // Sin imagen - usar JSON normal
        final response = await http.put(
          Uri.parse('$baseUrl/publications/$id/'),
          headers: await _getHeaders(requireAuth: true),
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          return Publication.fromJson(jsonDecode(response.body));
        }
        throw Exception('Error al actualizar publicación');
      }
    } catch (e) {
      print('Error en updatePublication: $e');
      rethrow;
    }
  }

  /// Eliminar publicación (admin)
  Future<bool> deletePublication(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/publications/$id/'),
        headers: await _getHeaders(requireAuth: true),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error en deletePublication: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/api_service.dart';

/// Provider para manejar el estado de autenticación, publicaciones y tema
class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Estado de autenticación
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  
  // Lista de publicaciones
  List<Publication> _publications = [];
  
  // Estado del tema
  bool _isDarkMode = false;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Publication> get publications => _publications;
  bool get isDarkMode => _isDarkMode;

  /// Inicializar - verificar si hay sesión activa
  Future<void> init() async {
    _isAuthenticated = await _apiService.isAuthenticated();
    notifyListeners();
  }

  /// Toggle modo oscuro/claro
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _apiService.login(username, password);
      if (success) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError('Credenciales incorrectas');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Cargar publicaciones públicas
  Future<void> loadPublications() async {
    _setLoading(true);
    _clearError();
    
    try {
      _publications = await _apiService.getPublications();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar productos');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar todas las publicaciones (admin)
  Future<void> loadAllPublications() async {
    _setLoading(true);
    _clearError();
    
    try {
      _publications = await _apiService.getAllPublications();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar productos');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear publicación
  Future<bool> createPublication(Map<String, dynamic> data, {String? imagePath}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final newPublication = await _apiService.createPublication(data, imagePath: imagePath);
      _publications.insert(0, newPublication);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al crear producto');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar publicación
  Future<bool> updatePublication(int id, Map<String, dynamic> data, {String? imagePath}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updated = await _apiService.updatePublication(id, data, imagePath: imagePath);
      final index = _publications.indexWhere((p) => p.id == id);
      if (index != -1) {
        _publications[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Error al actualizar producto');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar publicación
  Future<bool> deletePublication(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _apiService.deletePublication(id);
      if (success) {
        _publications.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error al eliminar producto');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

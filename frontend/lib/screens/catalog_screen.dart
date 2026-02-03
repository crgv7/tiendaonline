import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/navbar.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';

/// Pantalla principal del catálogo de productos
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar publicaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadPublications();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToAdmin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Navbar
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return Navbar(
                isAdmin: provider.isAuthenticated,
                onAdminPressed: provider.isAuthenticated
                    ? _navigateToAdmin
                    : _navigateToLogin,
                onLogout: provider.isAuthenticated
                    ? () async {
                        await provider.logout();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sesión cerrada'),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
                        }
                      }
                    : null,
              );
            },
          ),
          // Contenido
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.publications.isEmpty) {
                  return _buildLoading(isDark);
                }

                if (provider.error != null && provider.publications.isEmpty) {
                  return _buildError(provider.error!, isDark);
                }

                if (provider.publications.isEmpty) {
                  return _buildEmpty(isDark);
                }

                return _buildCatalog(provider, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando productos...',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Colors.redAccent.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            error,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AppProvider>().loadPublications();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Reintentar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 100,
            color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay productos disponibles',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve pronto para ver nuestras novedades',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog(AppProvider provider, bool isDark) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPublications(),
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(provider.publications.length, isDark),
          ),
          // Grid de productos
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                int crossAxisCount = 1;
                if (width > 1200) {
                  crossAxisCount = 4;
                } else if (width > 900) {
                  crossAxisCount = 3;
                } else if (width > 600) {
                  crossAxisCount = 2;
                }

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(
                        publication: provider.publications[index],
                      );
                    },
                    childCount: provider.publications.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con gradiente
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ).createShader(bounds),
            child: Text(
              'Nuestros Productos',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count productos disponibles',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

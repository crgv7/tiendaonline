import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

/// Barra de navegación sticky y responsiva con switch de tema
class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAdminPressed;
  final bool isAdmin;
  final VoidCallback? onLogout;

  const Navbar({
    super.key,
    this.onAdminPressed,
    this.isAdmin = false,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              _buildLogo(context),
              
              // Navegación
              if (isMobile)
                _buildMobileMenu(context)
              else
                _buildDesktopNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Tienda Online',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        // Switch de tema
        _ThemeSwitch(),
        const SizedBox(width: 16),
        _NavButton(
          label: 'Catálogo',
          icon: Icons.grid_view_rounded,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        const SizedBox(width: 16),
        if (isAdmin) ...[
          _NavButton(
            label: 'Panel Admin',
            icon: Icons.dashboard_rounded,
            onPressed: onAdminPressed,
            highlighted: true,
          ),
          const SizedBox(width: 16),
          _NavButton(
            label: 'Salir',
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ] else
          _NavButton(
            label: 'Administrar',
            icon: Icons.login_rounded,
            onPressed: onAdminPressed,
          ),
      ],
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        _ThemeSwitch(),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) {
            switch (value) {
              case 'catalog':
                Navigator.of(context).pushReplacementNamed('/');
                break;
              case 'admin':
                onAdminPressed?.call();
                break;
              case 'logout':
                onLogout?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            _buildMenuItem(context, 'catalog', 'Catálogo', Icons.grid_view_rounded),
            if (isAdmin) ...[
              _buildMenuItem(context, 'admin', 'Panel Admin', Icons.dashboard_rounded),
              _buildMenuItem(context, 'logout', 'Salir', Icons.logout_rounded),
            ] else
              _buildMenuItem(context, 'admin', 'Administrar', Icons.login_rounded),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Switch para alternar entre modo claro y oscuro
class _ThemeSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    
    return GestureDetector(
      onTap: () => provider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeIcon(
              icon: Icons.light_mode_rounded,
              isSelected: !isDark,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            _ThemeIcon(
              icon: Icons.dark_mode_rounded,
              isSelected: isDark,
              color: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _ThemeIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool highlighted;

  const _NavButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.highlighted = false,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton.icon(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: widget.highlighted
                ? const Color(0xFF6366F1)
                : _isHovered
                    ? (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100)
                    : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            widget.icon,
            color: widget.highlighted 
                ? Colors.white 
                : (isDark ? Colors.white : const Color(0xFF1F2937)),
            size: 20,
          ),
          label: Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: widget.highlighted 
                  ? Colors.white 
                  : (isDark ? Colors.white : const Color(0xFF1F2937)),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

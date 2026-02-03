import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/navbar.dart';
import '../widgets/product_card.dart';
import '../models/publication.dart';

/// Panel de administración para gestionar productos
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllPublications();
    });
  }

  void _showProductForm({Publication? publication}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(publication: publication),
    );
  }

  void _confirmDelete(Publication publication) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Eliminar Producto',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de eliminar "${publication.title}"?\nEsta acción no se puede deshacer.',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<AppProvider>()
                  .deletePublication(publication.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Producto eliminado'
                          : 'Error al eliminar producto',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
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
                isAdmin: true,
                onAdminPressed: () {},
                onLogout: () async {
                  await provider.logout();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
          // Contenido
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) {
                return CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(provider.publications.length, isDark),
                    ),
                    // Grid
                    if (provider.isLoading && provider.publications.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else if (provider.publications.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmpty(isDark),
                      )
                    else
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.72,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final pub = provider.publications[index];
                                  return ProductCard(
                                    publication: pub,
                                    isAdmin: true,
                                    onEdit: () =>
                                        _showProductForm(publication: pub),
                                    onDelete: () => _confirmDelete(pub),
                                  );
                                },
                                childCount: provider.publications.length,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Nuevo Producto',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildHeader(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ).createShader(bounds),
                child: Text(
                  'Panel de Administración',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count productos en total',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              context.read<AppProvider>().loadAllPublications();
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              size: 28,
            ),
            tooltip: 'Actualizar',
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
            'No hay productos',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer producto usando el botón +',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para crear/editar productos con selector de imagen
class ProductFormDialog extends StatefulWidget {
  final Publication? publication;

  const ProductFormDialog({super.key, this.publication});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _phoneController;
  late bool _isActive;
  bool _isLoading = false;
  
  // Para la imagen
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.publication != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.publication?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.publication?.description ?? '');
    _priceController = TextEditingController(
      text: widget.publication?.price.toStringAsFixed(0) ?? '',
    );
    _phoneController =
        TextEditingController(text: widget.publication?.phoneNumber ?? '');
    _isActive = widget.publication?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': _priceController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'is_active': _isActive,
    };

    bool success;
    final apiService = ApiService();
    
    try {
      if (isEditing) {
        await apiService.updatePublication(
          widget.publication!.id, 
          data,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
        success = true;
      } else {
        await apiService.createPublication(
          data,
          imageBytes: _selectedImageBytes,
          imageName: _selectedImageName,
        );
        success = true;
      }
      
      // Recargar lista
      if (mounted) {
        await context.read<AppProvider>().loadAllPublications();
      }
    } catch (e) {
      success = false;
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Producto actualizado' : 'Producto creado',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().error ?? 'Error al guardar',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildDialogHeader(isDark),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Selector de imagen
                      _buildImagePicker(isDark),
                      const SizedBox(height: 20),
                      _buildField(
                        controller: _titleController,
                        label: 'Título del producto',
                        icon: Icons.title_rounded,
                        isDark: isDark,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        icon: Icons.description_rounded,
                        maxLines: 3,
                        isDark: isDark,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _priceController,
                        label: 'Precio',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Campo requerido';
                          if (double.tryParse(v!) == null) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _phoneController,
                        label: 'Número WhatsApp (con código de país)',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        hintText: 'Ej: 573001234567',
                        isDark: isDark,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Campo requerido';
                          if (v!.length < 10) {
                            return 'Mínimo 10 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Switch activo
                      _buildActiveSwitch(isDark),
                    ],
                  ),
                ),
              ),
            ),
            // Botones
            _buildDialogActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.05) 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.grey.shade300,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: _selectedImageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageBytes = null;
                          _selectedImageName = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : widget.publication?.imageUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          widget.publication!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(isDark),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cambiar imagen',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildImagePlaceholder(isDark),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 48,
          color: isDark ? Colors.white38 : Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para agregar imagen',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white38 : Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PNG, JPG hasta 5MB',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEditing ? 'Editar Producto' : 'Nuevo Producto',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: isDark ? Colors.white : const Color(0xFF1F2937),
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
        hintStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white30 : Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          icon, 
          color: isDark ? Colors.white54 : Colors.grey.shade500,
        ),
        filled: true,
        fillColor: isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6366F1),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildActiveSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isActive
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: _isActive ? Colors.green : (isDark ? Colors.white54 : Colors.grey.shade500),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto visible',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _isActive
                        ? 'Visible en el catálogo'
                        : 'Oculto del catálogo',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEditing ? 'Guardar Cambios' : 'Crear Producto',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

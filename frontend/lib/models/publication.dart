/// Modelo de Publicación que mapea la respuesta de la API
class Publication {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final double price;
  final String? phoneNumber;
  final String whatsappLink;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Publication({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.price,
    this.phoneNumber,
    required this.whatsappLink,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      phoneNumber: json['phone_number'],
      whatsappLink: json['whatsapp_link'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price.toString(),
      'phone_number': phoneNumber,
      'is_active': isActive,
    };
  }

  Publication copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    String? phoneNumber,
    String? whatsappLink,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Publication(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Product category.
enum CategoryType {
  digital,
  physical,
  service;
}

/// Currency code (ISO 4217).
enum CurrencyCode {
  IDR,
  USD,
  EUR;

  String get symbol {
    switch (this) {
      case CurrencyCode.IDR:
        return 'Rp ';
      case CurrencyCode.USD:
        return '$';
      case CurrencyCode.EUR:
        return '€';
    }
  }
}

/// Product data model.
class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String>? imageUrls;
  final double price;
  final double? salePrice;
  final int stock;
  final CategoryType category;
  final Map<String, dynamic>? attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.imageUrl,
    this.imageUrls,
    required this.price,
    this.salePrice,
    this.stock = 0,
    required this.category,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
      price: (json['price'] as num).toDouble(),
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      stock: json['stock'] as int? ?? 0,
      category: switch (json['category']) {
        'digital' => CategoryType.digital,
        'service' => CategoryType.service,
        _ => CategoryType.physical,
      },
      attributes: json['attributes'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'name': name,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (imageUrls != null) 'image_urls': imageUrls,
        'price': price,
        if (salePrice != null) 'sale_price': salePrice,
        'stock': stock,
        'category': switch (category) {
          CategoryType.digital => 'digital',
          CategoryType.physical => 'physical',
          CategoryType.service => 'service',
        },
        if (attributes != null) 'attributes': attributes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_active': isActive,
      };

  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    double? price,
    double? salePrice,
    int? stock,
    CategoryType? category,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  double get effectivePrice => salePrice ?? price;
  bool get hasSale => salePrice != null && salePrice < price;
  bool get isInStock => stock > 0;
}

import 'package:moe_flutter_commerce/src/models/product_model.dart';

/// Cart item model.
class CartItemModel {
  final String id;
  final String productId;
  final ProductModel product;
  final int quantity;
  final double unitPrice;
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product': product.toJson(),
        'quantity': quantity,
        'unit_price': unitPrice,
        'added_at': addedAt.toIso8601String(),
      };

  CartItemModel copyWith({
    String? id,
    String? productId,
    ProductModel? product,
    int? quantity,
    double? unitPrice,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Line total = quantity × unit price.
  double get lineTotal => quantity * unitPrice;
}

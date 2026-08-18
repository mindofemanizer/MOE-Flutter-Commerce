import 'package:moe_flutter_commerce/src/models/cart_item_model.dart';

/// Order status enum.
enum OrderStatus {
  pending,     // payment pending
  confirmed,   // payment confirmed
  processing,  // preparing goods
  shipped,     // in transit
  delivered,   // received
  cancelled,   // cancelled by user or system
  refunded,    // refund processed
}

/// Payment method.
enum PaymentMethod {
  bankTransfer,
  eWallet,
  creditCard,
  debitCard,
  cashOnDelivery,
}

/// Order data model.
class OrderModel {
  final String id;
  final String orderNumber;
  final int userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double tax;
  final double total;
  final String currency;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentProofUrl;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingProvince;
  final String? shippingPostalCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.shippingFee = 0,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.currency = 'IDR',
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.bankTransfer,
    this.paymentProofUrl,
    this.shippingAddress,
    this.shippingCity,
    this.shippingProvince,
    this.shippingPostalCode,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'IDR',
      status: switch (json['status']) {
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'refunded' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      },
      paymentMethod: switch (json['payment_method']) {
        'ewallet' => PaymentMethod.eWallet,
        'credit_card' => PaymentMethod.creditCard,
        'debit_card' => PaymentMethod.debitCard,
        'cash' => PaymentMethod.cashOnDelivery,
        _ => PaymentMethod.bankTransfer,
      },
      paymentProofUrl: json['payment_proof_url'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingProvince: json['shipping_province'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'user_id': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'discount': discount,
        'tax': tax,
        'total': total,
        'currency': currency,
        'status': switch (status) {
          OrderStatus.pending => 'pending',
          OrderStatus.confirmed => 'confirmed',
          OrderStatus.processing => 'processing',
          OrderStatus.shipped => 'shipped',
          OrderStatus.delivered => 'delivered',
          OrderStatus.cancelled => 'cancelled',
          OrderStatus.refunded => 'refunded',
        },
        'payment_method': switch (paymentMethod) {
          PaymentMethod.bankTransfer => 'bank_transfer',
          PaymentMethod.eWallet => 'ewallet',
          PaymentMethod.creditCard => 'credit_card',
          PaymentMethod.debitCard => 'debit_card',
          PaymentMethod.cashOnDelivery => 'cash',
        },
        if (paymentProofUrl != null) 'payment_proof_url': paymentProofUrl,
        if (shippingAddress != null) 'shipping_address': shippingAddress,
        if (shippingCity != null) 'shipping_city': shippingCity,
        if (shippingProvince != null) 'shipping_province': shippingProvince,
        if (shippingPostalCode != null) 'shipping_postal_code': shippingPostalCode,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      };

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    int? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? tax,
    double? total,
    String? currency,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? paymentProofUrl,
    String? shippingAddress,
    String? shippingCity,
    String? shippingProvince,
    String? shippingPostalCode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingCity: shippingCity ?? this.shippingCity,
      shippingProvince: shippingProvince ?? this.shippingProvince,
      shippingPostalCode: shippingPostalCode ?? this.shippingPostalCode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  /// Number of items in cart (sum of quantities).
  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Is order completed?
  bool get isDelivered => status == OrderStatus.delivered;

  /// Is order paid?
  bool get isPaid => paidAt != null && !isCancelled;

  /// Is order cancelled?
  bool get isCancelled => status == OrderStatus.cancelled;
}

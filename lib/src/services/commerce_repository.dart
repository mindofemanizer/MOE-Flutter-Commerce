import 'package:dio/dio.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_commerce/src/config/commerce_config.dart';
import 'package:moe_flutter_commerce/src/models/product_model.dart';
import 'package:moe_flutter_commerce/src/models/cart_item_model.dart';
import 'package:moe_flutter_commerce/src/models/order_model.dart';

/// Repository for commerce operations.
class CommerceRepository {
  final Dio _dio;

  CommerceRepository(this._dio, MoeCommerceConfig _);

  // ── Products ───────────────────────────────────────────────

  /// List products with pagination/filter.
  Future<AppResult<List<ProductModel>>> listProducts({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (category != null) 'category': category,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final products = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((p) => ProductModel.fromJson(p))
          .toList();
      return Ok(products);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get single product by ID.
  Future<AppResult<ProductModel>> getProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Ok(ProductModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  // ── Cart ───────────────────────────────────────────────────

  /// Get current user's cart.
  Future<AppResult<List<CartItemModel>>> getCart() async {
    try {
      final response = await _dio.get('/cart');
      final items = (response.data as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((i) => CartItemModel.fromJson(i))
          .toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Add item to cart.
  Future<AppResult<CartItemModel>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(
        '/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
      return Ok(CartItemModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Update cart item quantity.
  Future<AppResult<void>> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      await _dio.put('/cart/items/$itemId', data: {'quantity': quantity});
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Remove item from cart.
  Future<AppResult<void>> removeCartItem(String itemId) async {
    try {
      await _dio.delete('/cart/items/$itemId');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Calculate cart totals.
  Future<AppResult<Map<String, double>>> calculateCartTotals() async {
    try {
      final response = await _dio.get('/cart/calculate');
      final data = response.data as Map<String, dynamic>;
      return Ok({
        'subtotal': (data['subtotal'] as num).toDouble(),
        'shipping': (data['shipping'] as num?)?.toDouble() ?? 0,
        'discount': (data['discount'] as num?)?.toDouble() ?? 0,
        'tax': (data['tax'] as num?)?.toDouble() ?? 0,
        'total': (data['total'] as num).toDouble(),
      });
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  // ── Orders ─────────────────────────────────────────────────

  /// Create order from cart.
  Future<AppResult<OrderModel>> createOrder({
    required String shippingAddress,
    required String shippingCity,
    required String shippingProvince,
    String? shippingPostalCode,
    PaymentMethod paymentMethod = PaymentMethod.bankTransfer,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity,
          'shipping_province': shippingProvince,
          if (shippingPostalCode != null)
            'shipping_postal_code': shippingPostalCode,
          'payment_method': switch (paymentMethod) {
            PaymentMethod.bankTransfer => 'bank_transfer',
            PaymentMethod.eWallet => 'ewallet',
            PaymentMethod.creditCard => 'credit_card',
            PaymentMethod.debitCard => 'debit_card',
            PaymentMethod.cashOnDelivery => 'cash',
          },
          if (notes != null) 'notes': notes,
        },
      );
      return Ok(OrderModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// List user's orders.
  Future<AppResult<List<OrderModel>>> listOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final orders = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((o) => OrderModel.fromJson(o))
          .toList();
      return Ok(orders);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }

  /// Get single order by ID.
  Future<AppResult<OrderModel>> getOrder(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return Ok(OrderModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(
        AppFailure(
          type: FailureType.unknown,
          message: e.toString(),
        ),
      );
    }
  }
}

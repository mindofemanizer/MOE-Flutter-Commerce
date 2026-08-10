import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_commerce/src/config/commerce_config.dart';
import 'package:moe_flutter_commerce/src/models/product_model.dart';
import 'package:moe_flutter_commerce/src/models/cart_item_model.dart';
import 'package:moe_flutter_commerce/src/services/commerce_repository.dart';

/// State for products.
sealed class ProductsState {
  const ProductsState();
}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final bool isLoadingMore;
  const ProductsLoaded(this.products, {this.isLoadingMore = false});
}

final class ProductsError extends ProductsState {
  final AppFailure failure;
  const ProductsError(this.failure);
}

/// Notifier for products.
class ProductsNotifier extends StateNotifier<ProductsState> {
  final CommerceRepository _repository;

  ProductsNotifier(this._repository) : super(const ProductsInitial());

  Future<void> loadProducts({String? category, int page = 1}) async {
    state = const ProductsLoading();

    final result = await _repository.listProducts(
      category: category,
      page: page,
      limit: page == 1 ? 20 : 20,
    );

    switch (result) {
      case Ok(:final data):
        state = ProductsLoaded(data);
      case Err(:final failure):
        state = ProductsError(failure);
    }
  }

  Future<void> loadProduct(String id) async {
    state = const ProductsLoading();

    final result = await _repository.getProduct(id);

    switch (result) {
      case Ok(:final data):
        // Update single product in list or show detail screen
        state = ProductsLoaded([data]);
      case Err(:final failure):
        state = ProductsError(failure);
    }
  }
}

/// State for cart.
sealed class CartState {
  const CartState();
}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final Map<String, double>? totals;
  const CartLoaded(this.items, {this.totals});
}

final class CartError extends CartState {
  final AppFailure failure;
  const CartError(this.failure);
}

/// Notifier for cart.
class CartNotifier extends StateNotifier<CartState> {
  final CommerceRepository _repository;

  CartNotifier(this._repository) : super(const CartInitial());

  Future<void> loadCart() async {
    state = const CartLoading();

    final itemsResult = await _repository.getCart();
    final totalsResult = await _repository.calculateCartTotals();

    if (itemsResult is Ok && totalsResult is Ok) {
      state = CartLoaded(itemsResult.data, totals: totalsResult.data);
    } else if (itemsResult is Err || totalsResult is Err) {
      state = CartError(itemsResult is Err ? itemsResult.failure : totalsResult.failure);
    }
  }

  Future<AppResult<CartItemModel>> addItem({
    required String productId,
    required int quantity,
  }) async {
    final result = await _repository.addToCart(
      productId: productId,
      quantity: quantity,
    );

    if (result is Ok && state is CartLoaded) {
      final loaded = state as CartLoaded;
      state = CartLoaded([...loaded.items, result.data], totals: loaded.totals);
    }

    return result;
  }

  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final result = await _repository.updateCartItemQuantity(
      itemId: itemId,
      quantity: quantity,
    );

    if (result is Ok && state is CartLoaded) {
      final loaded = state as CartLoaded;
      final updatedItems = loaded.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity, unitPrice: item.product.effectivePrice);
        }
        return item;
      }).toList();
      state = CartLoaded(updatedItems, totals: loaded.totals);
    }
  }

  Future<void> removeItem(String itemId) async {
    final result = await _repository.removeCartItem(itemId);

    if (result is Ok && state is CartLoaded) {
      final loaded = state as CartLoaded;
      final filteredItems = loaded.items.where((i) => i.id != itemId).toList();
      state = CartLoaded(filteredItems, totals: loaded.totals);
    }
  }

  int get itemCount => state is CartLoaded ? (state as CartLoaded).items.length : 0;

  double get subtotal => state is CartLoaded && (state as CartLoaded).totals != null
      ? (state as CartLoaded).totals!['subtotal'] ?? 0
      : 0;

  double get total => state is CartLoaded && (state as CartLoaded).totals != null
      ? (state as CartLoaded).totals!['total'] ?? 0
      : 0;
}

/// Provider for CommerceRepository.
final commerceRepositoryProvider = Provider<CommerceRepository>((ref) {
  throw UnimplementedError('MoeCommerce.setup() must be called before use.');
});

/// Provider for ProductsNotifier.
final productsProvider = StateNotifierProviderFactory<ProductsNotifier>(
  (ref) => ProductsNotifier(ref.watch(commerceRepositoryProvider)),
);

/// Provider for CartNotifier.
final cartProvider = StateNotifierProviderFactory<CartNotifier>(
  (ref) => CartNotifier(ref.watch(commerceRepositoryProvider)),
);

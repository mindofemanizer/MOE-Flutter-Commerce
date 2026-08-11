# MOE-Flutter-Commerce

Commerce package for MOE Flutter ecosystem — store, product, cart, order.

## Installation

```yaml
dependencies:
  moe_flutter_commerce:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Commerce.git
      ref: master
```

## Usage

### Setup

```dart
import 'package:moe_flutter_foundation/moe_flutter_foundation.dart';
import 'package:moe_flutter_commerce/moe_flutter_commerce.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await MoeFoundation.setup(
    envConfig: EnvConfig.fromEnvironment(),
    sharedPreferences: prefs,
  );

  MoeCommerce.setup(
    config: MoeCommerceConfig(
      apiUrl: 'https://api.kioskit.com/api/commerce',
      enableMultiStore: false, // or true for marketplace
    ),
  );

  runApp(MoeFoundationProviderScope(child: MyApp()));
}
```

### Products

```dart
final state = ref.watch(productsProvider.notifier);

switch (state) {
  case ProductsLoaded(:final products):
    GridView.builder(
      itemCount: products.length,
      itemBuilder: (ctx, i) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(products[i].imageUrl ?? ''),
            Text(products[i].name),
            Text(Formatters.currency(products[i].effectivePrice)),
            if (products[i].hasSale)
              Text(
                Formatters.currency(products[i].price),
                style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
              ),
          ],
        ),
      ),
    );
  default:
    // loading/error
}

// trigger load
await ref.read(productsProvider.notifier).loadProducts();

// load product detail
await ref.read(productsProvider.notifier).loadProduct(productId);
```

### Cart

```dart
final state = ref.watch(cartProvider);

switch (state) {
  case CartLoaded(:final items, :final totals):
    ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(items[i].product.name),
        subtitle: Text('${items[i].quantity} × ${Formatters.currency(items[i].unitPrice)}'),
        trailing: Text(Formatters.currency(items[i].lineTotal)),
      ),
    ),
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(title: Text('Subtotal'), subtitle: Text(Formatters.currency(totals!['subtotal'] ?? 0))),
          ListTile(title: Text('Shipping'), subtitle: Text(Formatters.currency(totals!['shipping'] ?? 0))),
          ListTile(title: Text('Tax'), subtitle: Text(Formatters.currency(totals!['tax'] ?? 0))),
          Divider(),
          ListTile(title: Text('Total'), subtitle: Text(Formatters.currency(totals!['total'] ?? 0))),
        ],
      ),
    ),
  default:
    // loading/error
}

// add to cart
await ref.read(cartProvider.notifier).addItem(
  productId: 'prod_123',
  quantity: 2,
);

// update quantity
await ref.read(cartProvider.notifier).updateItemQuantity(
  itemId: 'item_456',
  quantity: 5,
);

// remove item
await ref.read(cartProvider.notifier).removeItem('item_456');
```

### Create Order

```dart
final orderResult = await ref.read(commerceRepositoryProvider.notifier).createOrder(
  shippingAddress: 'Jl. Merdeka No. 1',
  shippingCity: 'Jakarta',
  shippingProvince: 'DKI Jakarta',
  shippingPostalCode: '10110',
  paymentMethod: PaymentMethod.bankTransfer,
  notes: 'Ringan saja mas',
);
```

## What's Included

| Module | Description |
|--------|-------------|
| `ProductModel` | Full product data (prices, stock, categories, attributes) |
| `CartItemModel` | Cart line item with quantity × price |
| `OrderModel` | Complete order (items, addresses, payment, status) |
| `CommerceRepository` | Products/Cart/Orders API calls |
| `ProductsNotifier` | Load/search products |
| `CartNotifier` | Add/update/remove items, calculate totals |

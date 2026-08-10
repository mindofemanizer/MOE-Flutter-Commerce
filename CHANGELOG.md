# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `CategoryType` — digital/physical/service enum
- `CurrencyCode` — IDR/USD/EUR with symbols
- `ProductModel` — full product data model with prices, stock, categories
- `CartItemModel` — cart line item with quantity × price calculation
- `OrderModel` — complete order (items, addresses, payment, shipping, status)
- `OrderStatus` — pending/confirmed/processing/shipped/delivered/cancelled/refunded
- `PaymentMethod` — bankTransfer/eWallet/creditCard/debitCard/cashOnDelivery
- `CommerceRepository` — products, cart, orders CRUD operations
- `ProductsNotifier` — load/list products
- `CartNotifier` — add/update/remove items, calculate totals
- `MoeCommerceConfig` — configurable API URL + multi-store support
- `MoeCommerce.setup()` — entry point
- Riverpod providers: `productsProvider`, `cartProvider`, `commerceRepositoryProvider`

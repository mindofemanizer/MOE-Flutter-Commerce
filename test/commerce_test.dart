import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_commerce/moe_flutter_commerce.dart';

void main() {
  group('CategoryType', () {
    test('has correct string value', () {
      expect(CategoryType.digital.name, equals('digital'));
      expect(CategoryType.physical.name, equals('physical'));
      expect(CategoryType.service.name, equals('service'));
    });
  });

  group('CurrencyCode', () {
    test('has symbol', () {
      expect(CurrencyCode.IDR.symbol, equals('Rp '));
      expect(CurrencyCode.USD.symbol, equals(r'$'));
      expect(CurrencyCode.EUR.symbol, equals('€'));
    });
  });

  group('ProductModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'prod1',
        'sku': 'SKU-001',
        'name': 'Test Product',
        'description': 'Test description',
        'image_url': 'https://example.com/image.jpg',
        'price': 100000,
        'sale_price': 85000,
        'stock': 50,
        'category': 'physical',
        'created_at': '2026-08-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
        'is_active': true,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, equals('prod1'));
      expect(product.sku, equals('SKU-001'));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('Test description'));
      expect(product.price, equals(100000.0));
      expect(product.salePrice, equals(85000.0));
      expect(product.effectivePrice, equals(85000.0));
      expect(product.hasSale, isTrue);
      expect(product.stock, equals(50));
      expect(product.isInStock, isTrue);
    });

    test('effectivePrice returns salePrice if exists', () {
      final product = ProductModel(
        id: 'test',
        sku: 'S1',
        name: 'Test',
        price: 100,
        salePrice: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.effectivePrice, equals(80));
    });

    test('toJson round-trips correctly', () {
      final model = ProductModel(
        id: 'test',
        sku: 'SKU1',
        name: 'Product',
        price: 99999,
        stock: 10,
        category: CategoryType.digital,
        createdAt: DateTime(2026, 8, 10),
        updatedAt: DateTime(2026, 8, 10),
      );

      final json = model.toJson();

      expect(json['id'], equals('test'));
      expect(json['price'], equals(99999));
      expect(json['category'], equals('digital'));
    });
  });

  group('CartItemModel', () {
    test('lineTotal calculates correctly', () {
      final product = ProductModel(
        id: 'p1',
        sku: 'S1',
        name: 'Test',
        price: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final item = CartItemModel(
        id: 'c1',
        productId: 'p1',
        product: product,
        quantity: 5,
        unitPrice: 100,
        addedAt: DateTime.now(),
      );

      expect(item.lineTotal, equals(500));
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'c1',
        'product_id': 'p1',
        'quantity': 3,
        'unit_price': 50000,
        'added_at': '2026-08-10T10:00:00.000Z',
        'product': {
          'id': 'p1',
          'sku': 'S1',
          'name': 'Product',
          'price': 50000,
          'created_at': '2026-08-10T09:00:00.000Z',
          'updated_at': '2026-08-10T09:00:00.000Z',
        },
      };

      final item = CartItemModel.fromJson(json);

      expect(item.id, equals('c1'));
      expect(item.quantity, equals(3));
      expect(item.unitPrice, equals(50000));
      expect(item.product.id, equals('p1'));
      expect(item.lineTotal, equals(150000));
    });
  });

  group('OrderStatus', () {
    test('has correct string values', () {
      expect(OrderStatus.pending.name, equals('pending'));
      expect(OrderStatus.confirmed.name, equals('confirmed'));
      expect(OrderStatus.processing.name, equals('processing'));
      expect(OrderStatus.shipped.name, equals('shipped'));
      expect(OrderStatus.delivered.name, equals('delivered'));
      expect(OrderStatus.cancelled.name, equals('cancelled'));
      expect(OrderStatus.refunded.name, equals('refunded'));
    });
  });

  group('OrderModel', () {
    test('totalItems calculates correctly', () {
      final product = ProductModel(
        id: 'p1',
        sku: 'S1',
        name: 'P1',
        price: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final order = OrderModel(
        id: 'o1',
        orderNumber: 'ORD-001',
        userId: 1,
        items: [
          CartItemModel(
            id: 'i1',
            productId: 'p1',
            product: product,
            quantity: 3,
            unitPrice: 100,
            addedAt: DateTime.now(),
          ),
          CartItemModel(
            id: 'i2',
            productId: 'p2',
            product: product,
            quantity: 2,
            unitPrice: 100,
            addedAt: DateTime.now(),
          ),
        ],
        subtotal: 500,
        total: 550,
        createdAt: DateTime.now(),
      );

      expect(order.totalItems, equals(5));
    });

    test('isPaid returns true when paidAt is set and not cancelled', () {
      final order = OrderModel(
        id: 'o1',
        orderNumber: 'ORD-001',
        userId: 1,
        items: [],
        subtotal: 100,
        total: 100,
        createdAt: DateTime(2026, 8, 10),
        paidAt: DateTime(2026, 8, 10, 10, 0),
        status: OrderStatus.confirmed,
      );

      expect(order.isPaid, isTrue);
      expect(order.isCancelled, isFalse);
    });

    test('isDelivered returns true when status is delivered', () {
      final order = OrderModel(
        id: 'o1',
        orderNumber: 'ORD-001',
        userId: 1,
        items: [],
        subtotal: 100,
        total: 100,
        createdAt: DateTime(2026, 8, 10),
        status: OrderStatus.delivered,
      );

      expect(order.isDelivered, isTrue);
    });

    test('fromJson parses order with statuses', () {
      final json = {
        'id': 'o1',
        'order_number': 'ORD-001',
        'user_id': 10,
        'items': [],
        'subtotal': 1000,
        'shipping_fee': 50,
        'discount': 100,
        'tax': 50,
        'total': 1000,
        'currency': 'IDR',
        'status': 'shipped',
        'payment_method': 'bank_transfer',
        'created_at': '2026-08-10T10:00:00.000Z',
      };

      final order = OrderModel.fromJson(json);

      expect(order.status, equals(OrderStatus.shipped));
      expect(order.paymentMethod, equals(PaymentMethod.bankTransfer));
      expect(order.currency, equals('IDR'));
      expect(order.total, equals(1000));
    });

    test('copyWith updates fields', () {
      final order = OrderModel(
        id: 'o1',
        orderNumber: 'ORD-001',
        userId: 1,
        items: [],
        subtotal: 100,
        total: 100,
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
      );

      final updated = order.copyWith(
        status: OrderStatus.confirmed,
        notes: 'Express delivery',
      );

      expect(updated.status, equals(OrderStatus.confirmed));
      expect(updated.notes, equals('Express delivery'));
      expect(updated.id, equals('o1'));
    });
  });

  group('MoeCommerceConfig', () {
    test('requires apiUrl', () {
      const config = MoeCommerceConfig(apiUrl: 'https://api.example.com');

      expect(config.apiUrl, equals('https://api.example.com'));
      expect(config.enableMultiStore, isFalse);
    });

    test('enables multi-store', () {
      const config = MoeCommerceConfig(
        apiUrl: 'https://api.example.com',
        enableMultiStore: true,
      );

      expect(config.enableMultiStore, isTrue);
    });
  });
}

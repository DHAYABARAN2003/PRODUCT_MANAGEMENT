import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_management_app/services/local_storage/local_storage_service.dart';
import 'package:product_management_app/services/connectivity/connectivity_service.dart';

import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_management_app/features/products/presentation/screens/home_screen.dart';
import 'package:product_management_app/features/products/data/models/dimensions_model.dart';
import 'package:product_management_app/features/products/data/models/meta_model.dart';
import 'package:product_management_app/shared/widgets/product_card.dart';

// Mock the Main Product Notifier
class MockProductListNotifier extends StateNotifier<ProductListState> implements ProductListNotifier {
  MockProductListNotifier(super.state);
  @override
  Future<void> fetchProducts() async {}
  @override
  void addProductLocally(ProductModel product) {}
  @override
  void updateProductLocally(ProductModel product) {}
  @override
  void deleteProductLocally(int productId) {}
}

// Mock the Search Notifier to prevent dependency crashes
class MockSearchNotifier extends StateNotifier<SearchState> implements SearchNotifier {
  MockSearchNotifier() : super(const SearchState());
  @override
  void search(String query) {}
  @override
  void clearSearch() {}
}

void main() {
  // CRITICAL FIX: Initialize dummy SharedPreferences for the test environment
  SharedPreferences.setMockInitialValues({});

  final tProduct = ProductModel(
    id: 1,
    title: 'UI Render Test Product',
    description: 'Desc',
    category: 'test',
    price: 99.99,
    discountPercentage: 0,
    rating: 4.0,
    stock: 10,
    tags: [],
    sku: 'SKU',
    weight: 10,
    dimensions: const DimensionsModel(width: 1, height: 1, depth: 1),
    warrantyInformation: '1y',
    shippingInformation: 'Fast',
    availabilityStatus: 'In Stock',
    reviews: [],
    returnPolicy: '30d',
    minimumOrderQuantity: 1,
    meta: MetaModel(createdAt: DateTime.now(), updatedAt: DateTime.now(), barcode: '1', qrCode: '1'),
    images: ['https://dummyjson.com/image.png'],
    thumbnail: 'https://dummyjson.com/image.png',
  );

  testWidgets('HomeScreen should render ProductCards when state has products', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final mockNotifier = MockProductListNotifier(ProductListState(
      isLoading: false,
      products: [tProduct],
    ));
    
    final mockSearchNotifier = MockSearchNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          connectivityStreamProvider.overrideWith((ref) => Stream.value(true)),
          recentlyViewedIdsProvider.overrideWith((ref) => <int>[]),
          // Override both providers so the UI doesn't try to make real API calls
          productListProvider.overrideWith((ref) => mockNotifier),
          searchProvider.overrideWith((ref) => mockSearchNotifier),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(ProductCard), findsOneWidget);
    expect(find.text('UI Render Test Product'), findsOneWidget);
    expect(find.text('₹99.99'), findsOneWidget);
  });
}
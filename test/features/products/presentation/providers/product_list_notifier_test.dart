import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your app files here
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/data/models/dimensions_model.dart';
import 'package:product_management_app/features/products/data/models/meta_model.dart';
import 'package:product_management_app/features/products/data/repository/product_repository_impl.dart';
import 'package:product_management_app/features/products/domain/usecases/product_usecases.dart';
import 'package:product_management_app/features/products/domain/repository/product_repository.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_management_app/services/connectivity/connectivity_service.dart';

// 1. Create Mock Classes using Mocktail
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockConnectivityService mockConnectivityService;
  late MockProductRepository mockProductRepository;
  late ProviderContainer container;

  // A dummy product to use in our tests
  final tProduct = ProductModel(
    id: 1,
    title: 'Test Product',
    description: 'A product for testing',
    category: 'electronics',
    price: 99.99,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 50,
    tags: ['test'],
    sku: 'TEST-SKU',
    weight: 100,
    dimensions: const DimensionsModel(width: 10, height: 10, depth: 10),
    warrantyInformation: '1 year',
    shippingInformation: 'Ships in 1 day',
    availabilityStatus: 'In Stock',
    reviews: [],
    returnPolicy: '30 days',
    minimumOrderQuantity: 1,
    meta: MetaModel(createdAt: DateTime.now(), updatedAt: DateTime.now(), barcode: '123', qrCode: '123'),
    images: ['image.jpg'],
    thumbnail: 'thumb.jpg',
  );

  // setUp runs before EVERY test
  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockConnectivityService = MockConnectivityService();
    mockProductRepository = MockProductRepository();

    // Set up a Riverpod ProviderContainer with our mocked dependencies
    container = ProviderContainer(
      overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockGetProductsUseCase),
        connectivityServiceProvider.overrideWithValue(mockConnectivityService),
        productRepositoryProvider.overrideWithValue(mockProductRepository),
      ],
    );
  });

  // tearDown runs after EVERY test
  tearDown(() {
    container.dispose();
  });

  test('fetchProducts should update state with products when online and API call is successful', () async {
    // Arrange: Tell the mocks how to behave
    final tResponse = ProductListResponse(products: [tProduct], total: 1, skip: 0, limit: 30);
    
    // Simulate being online
    when(() => mockConnectivityService.isConnected).thenAnswer((_) async => true);
    
    // Simulate a successful API response
    when(() => mockGetProductsUseCase(limit: any(named: 'limit'), skip: any(named: 'skip')))
        .thenAnswer((_) async => tResponse);

    // Act: Trigger the function
    final notifier = container.read(productListProvider.notifier);
    await notifier.fetchProducts();

    // Assert: Verify the state changed correctly
    final state = container.read(productListProvider);
    
    expect(state.isLoading, false);
    expect(state.isOffline, false);
    expect(state.errorMessage, isNull);
    expect(state.products.length, 1);
    expect(state.products.first.title, 'Test Product');
  });
}
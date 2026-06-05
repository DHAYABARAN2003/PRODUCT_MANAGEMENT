import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_management_app/features/products/data/datasource/product_local_datasource.dart';
import 'package:product_management_app/features/products/data/datasource/product_remote_datasource.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/data/repository/product_repository_impl.dart';

class MockProductRemoteDatasource extends Mock implements ProductRemoteDatasource {}
class MockProductLocalDatasource extends Mock implements ProductLocalDatasource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDatasource mockRemoteDatasource;
  late MockProductLocalDatasource mockLocalDatasource;

  setUp(() {
    mockRemoteDatasource = MockProductRemoteDatasource();
    mockLocalDatasource = MockProductLocalDatasource();
    repository = ProductRepositoryImpl(mockRemoteDatasource, mockLocalDatasource);
  });

  group('ProductRepositoryImpl', () {
    test('getProducts should fetch from remote and cache the result', () async {
      // Arrange
      final tProductListResponse = ProductListResponse(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      );
      
      when(() => mockRemoteDatasource.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
          .thenAnswer((_) async => tProductListResponse);
      when(() => mockLocalDatasource.cacheProducts(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.getProducts(limit: 20, skip: 0);

      // Assert
      expect(result, equals(tProductListResponse));
      verify(() => mockRemoteDatasource.getProducts(limit: 20, skip: 0)).called(1);
      verify(() => mockLocalDatasource.cacheProducts(tProductListResponse.products)).called(1);
    });
  });
}
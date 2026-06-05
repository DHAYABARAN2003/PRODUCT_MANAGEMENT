import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/data/repository/product_repository_impl.dart';
import 'package:product_management_app/features/products/domain/repository/product_repository.dart';

/// Use case: Fetch products from API.
class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<ProductListResponse> call({int limit = 20, int skip = 0}) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}

/// Use case: Get a single product by ID.
class GetProductByIdUseCase {
  final ProductRepository _repository;

  GetProductByIdUseCase(this._repository);

  Future<ProductModel> call(int id) {
    return _repository.getProductById(id);
  }
}

/// Use case: Search products.
class SearchProductsUseCase {
  final ProductRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<ProductListResponse> call(String query) {
    return _repository.searchProducts(query);
  }
}

/// Use case: Add a new product.
class AddProductUseCase {
  final ProductRepository _repository;

  AddProductUseCase(this._repository);

  Future<ProductModel> call(Map<String, dynamic> productData) {
    return _repository.addProduct(productData);
  }
}

/// Use case: Update an existing product.
class UpdateProductUseCase {
  final ProductRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<ProductModel> call(int id, Map<String, dynamic> productData) {
    return _repository.updateProduct(id, productData);
  }
}

/// Use case: Delete a product.
class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<ProductModel> call(int id) {
    return _repository.deleteProduct(id);
  }
}

// ─── Providers ───────────────────────────────────────────────────
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final getProductByIdUseCaseProvider = Provider<GetProductByIdUseCase>((ref) {
  return GetProductByIdUseCase(ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

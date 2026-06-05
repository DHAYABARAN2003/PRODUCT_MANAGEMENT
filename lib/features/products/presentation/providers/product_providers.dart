import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/data/repository/product_repository_impl.dart';
import 'package:product_management_app/features/products/domain/usecases/product_usecases.dart';
import 'package:product_management_app/services/connectivity/connectivity_service.dart';

class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
    bool? isOffline,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final GetProductsUseCase _getProductsUseCase;
  final Ref _ref;

  ProductListNotifier(this._getProductsUseCase, this._ref)
      : super(const ProductListState());

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check connectivity
      final connectivityService = _ref.read(connectivityServiceProvider);
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        // Load from cache
        final repository = _ref.read(productRepositoryProvider);
        final cached = repository.getCachedProducts();
        if (cached != null && cached.isNotEmpty) {
          state = state.copyWith(
            products: cached,
            isLoading: false,
            isOffline: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'No internet connection and no cached data available.',
            isOffline: true,
          );
        }
        return;
      }

      final response = await _getProductsUseCase(limit: 30, skip: 0);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        isOffline: false,
      );
    } catch (e) {
      // Try cache on error
      final repository = _ref.read(productRepositoryProvider);
      final cached = repository.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(
          products: cached,
          isLoading: false,
          errorMessage: 'Failed to load. Showing cached data.',
          isOffline: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  void addProductLocally(ProductModel product) {
    state = state.copyWith(
      products: [product, ...state.products],
    );
  }

  void updateProductLocally(ProductModel product) {
    final updated = state.products.map((p) {
      return p.id == product.id ? product : p;
    }).toList();
    state = state.copyWith(products: updated);
  }

  void deleteProductLocally(int productId) {
    final filtered = state.products.where((p) => p.id != productId).toList();
    state = state.copyWith(products: filtered);
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final getProducts = ref.watch(getProductsUseCaseProvider);
  return ProductListNotifier(getProducts, ref);
});

final productDetailProvider =
    FutureProvider.family<ProductModel, int>((ref, id) async {
  final useCase = ref.watch(getProductByIdUseCaseProvider);
  return useCase(id);
});

class SearchState {
  final List<ProductModel> results;
  final bool isLoading;
  final String? errorMessage;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
    this.query = '',
  });

  SearchState copyWith({
    List<ProductModel>? results,
    bool? isLoading,
    String? errorMessage,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchProductsUseCase _searchUseCase;
  Timer? _debounceTimer;

  SearchNotifier(this._searchUseCase) : super(const SearchState());

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await _searchUseCase(query);
        state = state.copyWith(
          results: response.products,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchUseCase = ref.watch(searchProductsUseCaseProvider);
  return SearchNotifier(searchUseCase);
});

final recentlyViewedIdsProvider = StateProvider<List<int>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getRecentlyViewedIds();
});

class AddProductNotifier extends StateNotifier<AsyncValue<ProductModel?>> {
  final AddProductUseCase _addProductUseCase;

  AddProductNotifier(this._addProductUseCase)
      : super(const AsyncValue.data(null));

  Future<ProductModel?> addProduct(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final product = await _addProductUseCase(data);
      state = AsyncValue.data(product);
      return product;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final addProductProvider =
    StateNotifierProvider<AddProductNotifier, AsyncValue<ProductModel?>>((ref) {
  final useCase = ref.watch(addProductUseCaseProvider);
  return AddProductNotifier(useCase);
});

class UpdateProductNotifier extends StateNotifier<AsyncValue<ProductModel?>> {
  final UpdateProductUseCase _updateProductUseCase;

  UpdateProductNotifier(this._updateProductUseCase)
      : super(const AsyncValue.data(null));

  Future<ProductModel?> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    state = const AsyncValue.loading();
    try {
      final product = await _updateProductUseCase(id, data);
      state = AsyncValue.data(product);
      return product;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final updateProductProvider = StateNotifierProvider<UpdateProductNotifier,
    AsyncValue<ProductModel?>>((ref) {
  final useCase = ref.watch(updateProductUseCaseProvider);
  return UpdateProductNotifier(useCase);
});

class DeleteProductNotifier extends StateNotifier<AsyncValue<bool>> {
  final DeleteProductUseCase _deleteProductUseCase;

  DeleteProductNotifier(this._deleteProductUseCase)
      : super(const AsyncValue.data(false));

  Future<bool> deleteProduct(int id) async {
    state = const AsyncValue.loading();
    try {
      await _deleteProductUseCase(id);
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final deleteProductProvider =
    StateNotifierProvider<DeleteProductNotifier, AsyncValue<bool>>((ref) {
  final useCase = ref.watch(deleteProductUseCaseProvider);
  return DeleteProductNotifier(useCase);
});

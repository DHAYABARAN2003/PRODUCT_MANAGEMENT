import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_management_app/core/constants/app_constants.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/data/repository/product_repository_impl.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_management_app/services/connectivity/connectivity_service.dart';
import 'package:product_management_app/shared/widgets/error_widget.dart';
import 'package:product_management_app/shared/widgets/empty_widget.dart';
import 'package:product_management_app/shared/widgets/loading_widget.dart';
import 'package:product_management_app/shared/widgets/offline_banner.dart';
import 'package:product_management_app/shared/widgets/product_card.dart';
import 'package:product_management_app/shared/widgets/search_bar_widget.dart';
import 'package:product_management_app/shared/widgets/theme_toggle.dart';

final _addRecentlyViewedProvider =
    FutureProvider.family<void, int>((ref, id) async {
  final repository = ref.read(productRepositoryProvider);
  await repository.addRecentlyViewed(id);
});
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final searchState = ref.watch(searchProvider);
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, colorScheme, theme),
            // Offline Banner from stream
            connectivityAsync.when(
              data: (isConnected) =>
                  !isConnected ? const OfflineBanner() : const SizedBox.shrink(),
              loading: () => productState.isOffline
                  ? const OfflineBanner()
                  : const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(searchState, theme, colorScheme)
                  : _buildProductContent(productState, theme, colorScheme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-product'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: colorScheme.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              const ThemeToggle(),
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSearchBar(
            controller: _searchController,
            hintText: AppConstants.searchHint,
            onChanged: (query) {
              setState(() => _isSearching = query.isNotEmpty);
              ref.read(searchProvider.notifier).search(query);
            },
            onClear: () {
              setState(() => _isSearching = false);
              ref.read(searchProvider.notifier).clearSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductContent(
    ProductListState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading && state.products.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.products.isEmpty) {
      return ErrorDisplayWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(productListProvider.notifier).fetchProducts(),
      );
    }

    if (state.products.isEmpty) {
      return const EmptyDisplayWidget(
        message: AppConstants.noProductsMessage,
        subtitle: 'Try adding a new product to get started.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(productListProvider.notifier).fetchProducts(),
      child: CustomScrollView(
        slivers: [
          _buildRecentlyViewedSection(state.products, theme, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Products',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.products.length} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = state.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _onProductTap(product),
                  );
                },
                childCount: state.products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedSection(
    List<ProductModel> allProducts,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final recentIds = ref.watch(recentlyViewedIdsProvider);
    if (recentIds.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final recentProducts =
        allProducts.where((p) => recentIds.contains(p.id)).toList();
    if (recentProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recently Viewed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: recentProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = recentProducts[index];
                return SizedBox(
                  width: 155,
                  child: ProductCard(
                    product: product,
                    onTap: () => _onProductTap(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    SearchState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const LoadingWidget(itemCount: 4);
    }

    if (state.errorMessage != null) {
      return ErrorDisplayWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(searchProvider.notifier).search(_searchController.text),
      );
    }

    if (state.query.isNotEmpty && state.results.isEmpty) {
      return EmptyDisplayWidget(
        message: 'No results for "${state.query}"',
        subtitle: 'Try a different search term.',
        icon: Icons.search_off_rounded,
      );
    }

    if (state.results.isEmpty) {
      return const EmptyDisplayWidget(
        message: 'Start typing to search',
        subtitle: 'Search across all products.',
        icon: Icons.search_rounded,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final product = state.results[index];
        return ProductCard(
          product: product,
          onTap: () => _onProductTap(product),
        );
      },
    );
  }

  void _onProductTap(ProductModel product) {
    // Update recently viewed state
    final currentIds = ref.read(recentlyViewedIdsProvider);
    final updatedIds = [
      product.id,
      ...currentIds.where((id) => id != product.id),
    ].take(AppConstants.maxRecentlyViewed).toList();

    ref.read(recentlyViewedIdsProvider.notifier).state = updatedIds;

    // Persist to storage
    ref.read(_addRecentlyViewedProvider(product.id));

    // Navigate
    context.push('/product-details/${product.id}');
  }
}

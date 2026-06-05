import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_management_app/core/constants/app_constants.dart';
import 'package:product_management_app/features/products/data/models/product_model.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';
import 'package:product_management_app/shared/widgets/error_widget.dart';
import 'package:product_management_app/shared/widgets/loading_widget.dart';
import 'package:product_management_app/shared/widgets/price_widget.dart';
import 'package:product_management_app/shared/widgets/product_carousel.dart';
import 'package:product_management_app/shared/widgets/rating_badge.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: productAsync.when(
        data: (p) => _body(context, ref, p, theme, cs),
        loading: () => const SafeArea(child: LoadingWidget(itemCount: 2)),
        error: (e, _) => SafeArea(
          child: Column(children: [
            _topBar(context),
            Expanded(child: ErrorDisplayWidget(message: e.toString(),
              onRetry: () => ref.invalidate(productDetailProvider(productId)))),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext ctx) => Padding(
    padding: const EdgeInsets.all(4),
    child: Row(children: [IconButton(onPressed: () => ctx.pop(), icon: const Icon(Icons.arrow_back_rounded))]),
  );

  Widget _body(BuildContext ctx, WidgetRef ref, ProductModel p, ThemeData t, ColorScheme cs) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 360, pinned: true,
        leading: IconButton(
          onPressed: () => ctx.pop(),
          icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.8), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_rounded)),
        ),
        actions: [
          IconButton(onPressed: () => ctx.push('/edit-product/${p.id}'),
            icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.8), shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, size: 20))),
          IconButton(onPressed: () => _deleteDialog(ctx, ref, p),
            icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.8), shape: BoxShape.circle), child: Icon(Icons.delete_outline_rounded, size: 20, color: cs.error))),
        ],
        flexibleSpace: FlexibleSpaceBar(background: ProductCarousel(images: p.images, heroTag: 'product-image-${p.id}')),
      ),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Category & rating
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(8)),
            child: Text(p.category.toUpperCase(), style: t.textTheme.labelSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
          if (p.brand != null) ...[const SizedBox(width: 8), Text(p.brand!, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500))],
          const Spacer(),
          RatingBadge(rating: p.rating),
        ]),
        const SizedBox(height: 12),
        Text(p.title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        PriceWidget(price: p.price, discountPercentage: p.discountPercentage),
        const SizedBox(height: 16),
        // Stock info
        Row(children: [
          _chip(ctx, Icons.inventory_2_outlined, '${p.stock} in stock', p.stock > 10 ? const Color(0xFF2E7D32) : cs.error),
          const SizedBox(width: 8),
          Expanded(child: _chip(ctx, Icons.local_shipping_outlined, p.shippingInformation, cs.primary)),
        ]),
        const SizedBox(height: 20),
        Text('Description', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(p.description, style: t.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
        const SizedBox(height: 20),
        // Details card
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Product Details', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _row(t, 'SKU', p.sku), _row(t, 'Weight', '${p.weight}g'),
          _row(t, 'Dimensions', p.dimensions.toString()),
          _row(t, 'Warranty', p.warrantyInformation),
          _row(t, 'Return Policy', p.returnPolicy),
          _row(t, 'Min. Order', '${p.minimumOrderQuantity} units'),
        ]))),
        const SizedBox(height: 20),
        // Reviews
        if (p.reviews.isNotEmpty) ...[
          Row(children: [
            Text('Reviews', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Text('${p.reviews.length}', style: t.textTheme.labelSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),
          ...p.reviews.map((r) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 16, backgroundColor: cs.primaryContainer, child: Text(r.reviewerName.isNotEmpty ? r.reviewerName[0].toUpperCase() : '?', style: t.textTheme.labelMedium?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.reviewerName, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text('${r.date.day}/${r.date.month}/${r.date.year}', style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ])),
              RatingBadge(rating: r.rating.toDouble()),
            ]),
            const SizedBox(height: 8),
            Text(r.comment, style: t.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
          ])))),
        ],
        const SizedBox(height: 32),
      ]))),
    ]);
  }

  Widget _chip(BuildContext ctx, IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color), const SizedBox(width: 4),
      Flexible(child: Text(label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]),
  );

  Widget _row(ThemeData t, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: t.textTheme.bodyMedium)),
    ]),
  );

  void _deleteDialog(BuildContext ctx, WidgetRef ref, ProductModel p) {
    final cs = Theme.of(ctx).colorScheme;
    showDialog(context: ctx, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [Icon(Icons.warning_rounded, color: cs.error), const SizedBox(width: 8), const Text(AppConstants.deleteConfirmTitle)]),
      content: const Text(AppConstants.deleteConfirmMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
          onPressed: () async {
            Navigator.pop(c);
            final ok = await ref.read(deleteProductProvider.notifier).deleteProduct(p.id);
            if (ok && ctx.mounted) {
              ref.read(productListProvider.notifier).deleteProductLocally(p.id);
              ctx.pop();
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${p.title} deleted'), behavior: SnackBarBehavior.floating));
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

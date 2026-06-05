import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final int productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final updateState = ref.watch(updateProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: productAsync.when(
        data: (product) {
          if (!_loaded) {
            _nameCtrl.text = product.title;
            _descCtrl.text = product.description;
            _priceCtrl.text = product.price.toString();
            _categoryCtrl.text = product.category;
            _loaded = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.secondaryContainer.withValues(alpha: 0.5),
                          cs.tertiaryContainer.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 48,
                          color: cs.secondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Edit Product',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update product details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Product Name', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Product name',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Price', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Price',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Must be numeric';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Category', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: updateState.isLoading
                        ? null
                        : () => _submit(product),
                    icon: updateState.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      updateState.isLoading ? 'Saving...' : 'Save Changes',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _submit(dynamic original) async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'category': _categoryCtrl.text.trim(),
    };
    final product = await ref
        .read(updateProductProvider.notifier)
        .updateProduct(widget.productId, data);
    if (product != null && mounted) {
      ref.read(productListProvider.notifier).updateProductLocally(product);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

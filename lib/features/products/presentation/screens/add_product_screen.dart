import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_management_app/features/products/presentation/providers/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

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
    final addState = ref.watch(addProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header illustration
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer.withValues(alpha: 0.5),
                      cs.tertiaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 48,
                      color: cs.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create New Product',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details below',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Product Name
              Text('Product Name', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter product name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Product name is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              // Description
              Text('Description', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              // Price
              Text('Price', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter price',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) {
                    return 'Price must be numeric';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              // Category
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Category is required'
                    : null,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              // Submit
              FilledButton.icon(
                onPressed: addState.isLoading ? null : _submit,
                icon: addState.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(addState.isLoading ? 'Adding...' : 'Add Product'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'category': _categoryCtrl.text.trim(),
    };
    final product = await ref
        .read(addProductProvider.notifier)
        .addProduct(data);
    if (product != null && mounted) {
      ref.read(productListProvider.notifier).addProductLocally(product);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

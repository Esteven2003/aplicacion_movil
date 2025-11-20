import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductCrudScreen extends StatefulWidget {
  const ProductCrudScreen({super.key});

  @override
  State<ProductCrudScreen> createState() => _ProductCrudScreenState();
}

class _ProductCrudScreenState extends State<ProductCrudScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Product? _editingProduct;

  String get _dialogTitle =>
      _editingProduct == null ? 'Crear producto en Firebase' : 'Editar producto';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _startCreate() {
    _editingProduct = null;
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _categoryController.clear();
    _stockController.clear();
    _showEditSheet();
  }

  void _startEdit(Product product) {
    _editingProduct = product;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toStringAsFixed(2);
    _categoryController.text = product.category;
    _stockController.text = product.stock.toString();
    _showEditSheet();
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _editingProduct == null
                        ? 'Crear producto en Firebase'
                        : 'Editar producto',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null) return 'Ingresa un precio válido';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(_editingProduct == null ? 'Guardar' : 'Actualizar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final isCreating = _editingProduct == null;
    final product = Product(
      id: _editingProduct?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      category: _categoryController.text.isEmpty
          ? 'General'
          : _categoryController.text,
      stock: int.tryParse(_stockController.text) ?? 0,
      rating: _editingProduct?.rating ?? 0,
    );

    try {
      if (isCreating) {
        await _service.addProduct(product);
      } else {
        await _service.updateProduct(
          product.copyWith(id: _editingProduct!.id),
          previousCategory: _editingProduct!.category,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        _editingProduct = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCreating ? 'Producto creado' : 'Producto actualizado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar producto'),
            content: Text('¿Seguro que deseas eliminar "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _service.deleteProduct(product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos (Firebase CRUD)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startCreate,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _service.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(
              child: Text('Aún no hay productos en Firebase.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(product.name.characters.first.toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '\\$${product.price.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (product.description.isNotEmpty)
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(
                                    product.category.isEmpty
                                        ? 'General'
                                        : product.category,
                                  ),
                                  avatar: const Icon(Icons.category_outlined, size: 18),
                                ),
                                Chip(
                                  label: Text('Stock: ${product.stock}'),
                                  avatar: Icon(
                                    product.stock > 0
                                        ? Icons.inventory_2_outlined
                                        : Icons.error_outline,
                                    size: 18,
                                  ),
                                  backgroundColor: product.stock > 0
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                                  labelStyle: product.stock > 0
                                      ? null
                                      : TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                  avatarBorder: CircleBorder(
                                    side: BorderSide(
                                      color: product.stock > 0
                                          ? Colors.transparent
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _startEdit(product),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: products.length,
          );
        },
      ),
    );
  }
}

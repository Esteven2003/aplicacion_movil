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
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _editingProduct == null
                        ? 'Crear producto'
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

    final product = Product(
      id: _editingProduct?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      imageUrl: '',
      category: _categoryController.text.isEmpty
          ? 'General'
          : _categoryController.text,
      stock: int.tryParse(_stockController.text) ?? 0,
      rating: _editingProduct?.rating ?? 0,
    );

    try {
      if (_editingProduct == null) {
        await _service.addProduct(product);
      } else {
        await _service.updateProduct(
          product.copyWith(id: _editingProduct!.id),
          previousCategory: _editingProduct!.category,
        );
      }
      if (mounted) {
        Navigator.of(context).maybePop();
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
        title: const Text('Productos (CRUD)'),
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
              child: Text('Aún no hay productos.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(product.name.characters.first.toUpperCase()),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.category} · Stock: ${product.stock} · \$${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _startEdit(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(product),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: products.length,
          );
        },
      ),
    );
  }
}

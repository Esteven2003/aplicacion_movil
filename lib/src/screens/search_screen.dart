import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const SearchScreen({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = widget.products;
      });
    } else {
      setState(() {
        _filteredProducts = widget.products.where((product) {
          return product.name.toLowerCase().contains(query) ||
                 product.description.toLowerCase().contains(query) ||
                 product.category.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Productos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: buildProductImage(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.clean_hands),
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(product.category),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => widget.onProductTap(product),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
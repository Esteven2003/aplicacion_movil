import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';

class CategoriesScreen extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const CategoriesScreen({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  List<String> get categories {
    final allCategories = products.map((p) => p.category).toSet().toList();
    allCategories.sort();
    return allCategories;
  }

  List<Product> getProductsByCategory(String category) {
    return products.where((p) => p.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryProducts = getProductsByCategory(category);
            final categoryVisual = _getCategoryVisual(category);
            final gradient = _getCategoryGradient(theme, categoryVisual.color);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                  collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(
                      categoryVisual.icon,
                      color: categoryVisual.color,
                    ),
                  ),
                  iconColor: theme.colorScheme.primary,
                  collapsedIconColor: theme.colorScheme.primary,
                  title: Text(
                    category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  subtitle: Text(
                    '${categoryProducts.length} productos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  children: [
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryProducts
                            .map(
                              (product) => ActionChip(
                                backgroundColor: theme.colorScheme.surface,
                                labelStyle: theme.textTheme.bodyMedium,
                                avatar: const Icon(Icons.cleaning_services, size: 18),
                                label: Text(product.name),
                                onPressed: () => onProductTap(product),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryProducts.map(
                      (product) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: theme.colorScheme.surface.withOpacity(0.95),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: buildProductImage(
                              product.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                width: 48,
                                height: 48,
                                color: theme.colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: const Icon(Icons.clean_hands, size: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => onProductTap(product),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _CategoryVisual _getCategoryVisual(String category) {
    switch (category.toLowerCase()) {
      case 'escobas':
        return const _CategoryVisual(Icons.brush, Colors.blue);
      case 'trapeadores':
        return const _CategoryVisual(Icons.cleaning_services, Colors.green);
      case 'palos':
        return const _CategoryVisual(Icons.straighten, Colors.orange);
      case 'cepillos':
        return const _CategoryVisual(Icons.soap, Colors.purple);
      case 'otros':
        return const _CategoryVisual(Icons.work, Colors.red);
      default:
        return const _CategoryVisual(Icons.clean_hands, Colors.grey);
    }
  }

  LinearGradient _getCategoryGradient(ThemeData theme, Color accentColor) {
    final baseColor = accentColor;
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.25),
        theme.colorScheme.primaryContainer.withOpacity(0.35),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _CategoryVisual {
  final IconData icon;
  final Color color;

  const _CategoryVisual(this.icon, this.color);
}

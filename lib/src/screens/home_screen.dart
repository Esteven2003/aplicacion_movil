import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_image.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  StreamSubscription<List<Product>>? _productSubscription;

  late List<Product> _products;

  final List<CartItem> cartItems = [];
  int _selectedDestination = 0;

  @override
  void initState() {
    super.initState();
    _products = [];
    _productSubscription = _productService.watchProducts().listen(
      (remoteProducts) {
        if (!mounted) return;
        setState(() {
          _products = remoteProducts;
        });
      },
    );
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToProductDetail(Product product) {
    return Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: {
        'product': product,
        'onAddToCart': _addToCart,
      },
    );
  }

  Future<void> _navigateToCategories() async {
    await Navigator.pushNamed(
      context,
      '/categories',
      arguments: {
        'products': _products,
        'onProductTap': _navigateToProductDetail,
      },
    );
  }

  Future<void> _navigateToSearch() async {
    await Navigator.pushNamed(
      context,
      '/search',
      arguments: {
        'products': _products,
        'onProductTap': _navigateToProductDetail,
      },
    );
  }

  Future<void> _navigateToCart() async {
    await Navigator.pushNamed(
      context,
      '/cart',
      arguments: {
        'cartItems': cartItems,
        'onCartUpdated': () {
          setState(() {});
        },
      },
    );
  }

  Future<void> _navigateToProfile() {
    return Navigator.pushNamed(context, '/profile');
  }

  void _addToCart(Product product) {
    final existingItemIndex = cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      setState(() {
        cartItems[existingItemIndex].quantity++;
      });
    } else {
      setState(() {
        cartItems.add(CartItem(product: product));
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedDestination) {
      return;
    }

    setState(() {
      _selectedDestination = index;
    });

    Future<void>? navigation;
    switch (index) {
      case 0:
        break;
      case 1:
        navigation = _navigateToCategories();
        break;
      case 2:
        navigation = _navigateToSearch();
        break;
      case 3:
        navigation = _navigateToCart();
        break;
      case 4:
        navigation = _navigateToProfile();
        break;
    }

    navigation?.whenComplete(() {
      if (mounted) {
        setState(() {
          _selectedDestination = 0;
        });
      }
    });

    if (navigation == null) {
      setState(() {
        _selectedDestination = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final Color headerColor = isDark
        ? const Color(0xFFB8860B)
        : const Color(0xFF7B1F3D);
    final int totalCartItems = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.black.withOpacity(0.65),
            ),
            Container(
              height: 56,
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    tooltip: 'Abrir menú',
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La Hogareña',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                        tooltip: 'Ver carrito',
                        onPressed: _navigateToCart,
                      ),
                      if (totalCartItems > 0)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              totalCartItems.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: headerColor,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'La Hogareña',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              _NavigationDrawerItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
                isSelected: _selectedDestination == 0,
                onTap: () {
                  Navigator.pop(context);
                  _onDestinationSelected(0);
                },
              ),
              _NavigationDrawerItem(
                icon: Icons.category_outlined,
                selectedIcon: Icons.category,
                label: 'Categorías',
                isSelected: _selectedDestination == 1,
                onTap: () {
                  Navigator.pop(context);
                  _onDestinationSelected(1);
                },
              ),
              _NavigationDrawerItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Buscar',
                isSelected: _selectedDestination == 2,
                onTap: () {
                  Navigator.pop(context);
                  _onDestinationSelected(2);
                },
              ),
              _NavigationDrawerItem(
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag,
                label: 'Carrito',
                isSelected: _selectedDestination == 3,
                trailing: totalCartItems > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          totalCartItems.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _onDestinationSelected(3);
                },
              ),
              _NavigationDrawerItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Perfil',
                isSelected: _selectedDestination == 4,
                onTap: () {
                  Navigator.pop(context);
                  _onDestinationSelected(4);
                },
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Todo para la limpieza del hogar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explora nuestras categorías y encuentra tus productos básicos de limpieza.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonalIcon(
                                icon: const Icon(Icons.category_outlined),
                                label: const Text('Ver categorías'),
                                onPressed: _navigateToCategories,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.cleaning_services,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    readOnly: true,
                    onTap: _navigateToSearch,
                    decoration: InputDecoration(
                      hintText: 'Buscar productos, categorías o usos',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: _navigateToSearch,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Productos destacados',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _products[index];
                  return _ProductCard(
                    product: product,
                    onAddToCart: () => _addToCart(product),
                    onTap: () => _navigateToProductDetail(product),
                  );
                },
                childCount: _products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
          ]
        : [
            theme.colorScheme.primary.withOpacity(0.14),
            theme.colorScheme.secondary.withOpacity(0.08),
          ];

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surface.withOpacity(0.6)
                            : Colors.white,
                      ),
                      child: Center(
                        child: buildProductImage(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          placeholder: Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.cleaning_services, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: onAddToCart,
                        child: const Icon(Icons.add_shopping_cart_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDrawerItem extends StatelessWidget {
  const _NavigationDrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(isSelected ? selectedIcon : icon),
      title: Text(label),
      trailing: trailing,
      selected: isSelected,
      selectedColor: theme.colorScheme.primary,
      onTap: onTap,
    );
  }
}

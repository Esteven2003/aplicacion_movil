import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasShownImageWarning = false;

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Escoba de Coco normal',
      description: 'Escoba con base de madera y fibra natural profesional para interior y exterior',
      price: 3.25,
      imageUrl:
          'https://quimiclean-ec.com/wp-content/uploads/2022/05/escoba-de-coco-40cm.jpg',
      category: 'Escobas',
      stock: 15,
      rating: 4.5,
    ),
    Product(
      id: '2',
      name: 'Trapeador de 500g',
      description: 'Trapeador giratorio con cabeza de algodón extraíble',
      price: 5.00,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyVXrbCfdtCrgg2fI3qvqnidTpEzpTmeUiLA&s',
      category: 'Trapeadores',
      stock: 8,
      rating: 4.8,
    ),
    Product(
      id: '3',
      name: 'Pala',
      description: 'Pala de plástico con palo de madera',
      price: 1.50,
      imageUrl: 'https://static.wixstatic.com/media/54d53f_a7973bd71093481da67e5ba37711a0fe~mv2.png/v1/fill/w_480,h_480,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/54d53f_a7973bd71093481da67e5ba37711a0fe~mv2.png',
      category: 'Otros',
      stock: 5,
      rating: 4.9,
    ),
    Product(
      id: '4',
      name: 'Palos de madera',
      description: 'Palos de madera sin rosca de tamaño normal por unidad',
      price: 1.00,
      imageUrl: 'https://http2.mlstatic.com/D_NQ_NP_837154-MLM75800072961_042024-O.webp',
      category: 'Palos',
      stock: 6,
      rating: 4.6,
    ),
    Product(
      id: '5',
      name: 'Palos de metal',
      description: 'Palos de metal con rosca',
      price: 2.00,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ9Ne4ZrZ_42Pv_TR-DHd06PzuZxyn0gZjE3rr4l-rQ1Uzx6QM_PTUVPWNBkkLtmTAcy0&usqp=CAU',
      category: 'Palos',
      stock: 3,
      rating: 4.8,
    ),
    Product(
      id: '6',
      name: 'Cepillo para Baño',
      description: 'Cepillo con cerdas firmes para limpieza profunda de baños',
      price: 3.50,
      imageUrl: 'https://almacenesmirna.com.ec/wp-content/uploads/2020/08/HO-2031-fr.jpg',
      category: 'Cepillos',
      stock: 20,
      rating: 4.3,
    ),
    Product(
      id: '7',
      name: 'Cepillo para Muebles',
      description: 'Cepillo suave para limpieza de muebles y superficies delicadas',
      price: 2.00,
      imageUrl: 'https://ambientegourmet.vtexassets.com/arquivos/ids/236875-800-auto?v=638791342265570000&width=800&height=auto&aspect=true',
      category: 'Cepillos',
      stock: 15,
      rating: 4.4,
    ),
    Product(
      id: '8',
      name: 'Cepillo de plástico lava ropa',
      description: 'Cepillo para lavado de ropa tipo plancha',
      price: 1.50,
      imageUrl: 'https://res.cloudinary.com/agglobal-com/image/upload/f_auto,q_auto,g_center,b_rgb:fff,c_pad,d_assets:noImage.webp,w_1000,h_1000/053077.webp',
      category: 'Cepillos',
      stock: 12,
      rating: 4.5,
    ),
  ];

  final List<CartItem> cartItems = [];
  int _selectedDestination = 0;

  @override
  void initState() {
    super.initState();
    _checkCoconutBroomImage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkCoconutBroomImage() async {
    Product? coconutBroom;
    try {
      coconutBroom = products.firstWhere((product) => product.id == '1');
    } catch (_) {
      coconutBroom = null;
    }

    if (coconutBroom == null) {
      return;
    }

    final Uri? uri = Uri.tryParse(coconutBroom.imageUrl);
    if (uri == null || !uri.hasScheme) {
      _showImageWarning(
        'No se pudo validar la imagen de "${coconutBroom.name}" porque la URL es inválida.',
      );
      return;
    }

    try {
      final response = await http.head(uri);
      if (!mounted || _hasShownImageWarning) return;

      if (response.statusCode >= 400) {
        _showImageWarning(
          'La URL de la imagen de "${coconutBroom.name}" respondió con el código ${response.statusCode}.',
        );
      }
    } catch (error) {
      if (!mounted || _hasShownImageWarning) return;
      _showImageWarning(
        'No se pudo cargar la imagen de "${coconutBroom.name}". Error: $error',
      );
    }
  }

  void _showImageWarning(String message) {
    if (_hasShownImageWarning) return;
    _hasShownImageWarning = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
    });
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
        'products': products,
        'onProductTap': _navigateToProductDetail,
      },
    );
  }

  Future<void> _navigateToSearch() async {
    await Navigator.pushNamed(
      context,
      '/search',
      arguments: {
        'products': products,
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
                                'Explora nuestras categorías y encuentra tus básicos de limpieza.',
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
                  final product = products[index];
                  return _ProductCard(
                    product: product,
                    onAddToCart: () => _addToCart(product),
                    onTap: () => _navigateToProductDetail(product),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Carrito',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
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
            theme.colorScheme.surfaceVariant.withOpacity(0.4),
            theme.colorScheme.surfaceVariant.withOpacity(0.1),
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
                            color: theme.colorScheme.surfaceVariant,
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

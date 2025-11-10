import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/mobile_resources_screen.dart';
import 'models/product.dart';
import 'models/cart_item.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.themeNotifier});

  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'La Hogareña - Materiales de Limpieza',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/profile': (context) => ProfileScreen(
                  themeNotifier: themeNotifier,
                ),
            '/mobile_resources': (context) => const MobileResourcesScreen(),
          },
          onGenerateRoute: (settings) {

            // 🆕 PRODUCT DETAIL
            if (settings.name == '/product_detail') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: args['product'] as Product,
                  onAddToCart: args['onAddToCart'] as Function(Product),
                ),
              );
            }

            // 🆕 CART SCREEN
            if (settings.name == '/cart') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CartScreen(
                  cartItems: args['cartItems'] as List<CartItem>,
                  onCartUpdated: args['onCartUpdated'] as VoidCallback,
                ),
              );
            }

            // 🆕 CATEGORIES SCREEN
            if (settings.name == '/categories') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CategoriesScreen(
                  products: args['products'] as List<Product>,
                  onProductTap: args['onProductTap'] as Function(Product),
                ),
              );
            }

            // 🆕 SEARCH SCREEN
            if (settings.name == '/search') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => SearchScreen(
                  products: args['products'] as List<Product>,
                  onProductTap: args['onProductTap'] as Function(Product),
                ),
              );
            }

            return null;
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/models/cart_item.dart';
import 'src/models/product.dart';
import 'src/screens/cart_screen.dart';
import 'src/screens/categories_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/mobile_resources_screen.dart';
import 'src/screens/product_crud_screen.dart';
import 'src/screens/product_detail_screen.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/search_screen.dart';

final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
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
          initialRoute: '/login',
          routes: {
            '/login': (context) => Homepage(themeNotifier: _themeNotifier),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => ProfileScreen(
                  themeNotifier: _themeNotifier,
                ),
            '/mobile_resources': (context) => const MobileResourcesScreen(),
            '/crud': (context) => const ProductCrudScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/product_detail') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: args['product'] as Product,
                  onAddToCart: args['onAddToCart'] as Function(Product),
                ),
              );
            }

            if (settings.name == '/cart') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CartScreen(
                  cartItems: args['cartItems'] as List<CartItem>,
                  onCartUpdated: args['onCartUpdated'] as VoidCallback,
                ),
              );
            }

            if (settings.name == '/categories') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CategoriesScreen(
                  products: args['products'] as List<Product>,
                  onProductTap: args['onProductTap'] as Function(Product),
                ),
              );
            }

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
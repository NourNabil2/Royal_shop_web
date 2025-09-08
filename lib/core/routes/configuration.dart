// Router Configuration
import 'package:go_router/go_router.dart';
import 'package:shoping/features/home/data/product_db.dart';
import 'package:shoping/features/home/view/contact_screen.dart';
import 'package:shoping/features/home/view/home_screen.dart';
import 'package:shoping/features/product_details/view/product_details_screen.dart';
import 'package:shoping/features/search/view/search_screen.dart';


final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final product = sampleProducts.firstWhere((p) => p.id == id);
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    // إضافة route البحث الجديد
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shoping/core/theme/theme.dart';
import 'package:shoping/core/widgets/custom_app_bar.dart';
import 'package:shoping/features/home/data/product_db.dart';
import 'package:shoping/features/home/widgets/footer_section.dart';
import 'package:shoping/features/home/widgets/hero_header.dart';
import 'package:shoping/features/home/widgets/product_card.dart';



// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onThemeToggle: () => Provider.of<ThemeController>(context, listen: false).toggleTheme(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroHeader(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'منتاجاتنا',
                    style: GoogleFonts.cairo(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف مجموعتنا المختارة بعناية من الكروت، الأكياس، والبادجات بجودة عالية',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 2;
                      } else {
                        crossAxisCount = 1;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: sampleProducts.length,
                        itemBuilder: (context, index) {
                          final product = sampleProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => context.go('/product/${product.id}'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
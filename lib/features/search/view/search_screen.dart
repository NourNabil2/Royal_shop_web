import 'package:flutter/material.dart'  hide SearchController;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shoping/core/model/product_model.dart';
import 'package:shoping/features/search/view_model/search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchController searchController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController = SearchController();

    // تركيز تلقائي على البحث بعد قليل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: searchController,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar للبحث
              _buildSearchAppBar(),

              // محتوى الصفحة
              Expanded(
                child: Consumer<SearchController>(
                  builder: (context, search, child) {
                    return Column(
                      children: [
                        // فلاتر الفئات
                        if (search.isSearching || search.selectedCategory != null)
                          _buildCategoryFilters(search),

                        // المحتوى الأساسي
                        Expanded(
                          child: _buildMainContent(search),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // شريط البحث
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث في المنتجات...',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _textController.clear();
                      searchController.clearSearch();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
                onChanged: (query) {
                  searchController.searchProducts(query);
                  setState(() {}); // لتحديث suffixIcon
                },
                onSubmitted: (query) => searchController.searchProducts(query),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -1, duration: 400.ms);
  }

  Widget _buildCategoryFilters(SearchController search) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: search.categories.length + 1, // +1 للخيار "الكل"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('الكل', null, search);
          }

          final category = search.categories[index - 1];
          return _buildCategoryChip(category, category, search);
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.5);
  }

  Widget _buildCategoryChip(String label, String? value, SearchController search) {
    final isSelected = search.selectedCategory == value;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
        onSelected: (_) => search.filterByCategory(value),
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.grey[100],
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildMainContent(SearchController search) {
    if (!search.isSearching) {
      return _buildInitialState(search);
    }

    if (!search.hasResults) {
      return _buildNoResultsState();
    }

    return _buildSearchResults(search);
  }

  Widget _buildInitialState(SearchController search) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // أيقونة البحث
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.search,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).animate().scale(delay: 300.ms),

          const SizedBox(height: 24),

          Text(
            'ابحث عن المنتجات',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 8),

          Text(
            'يمكنك البحث في جميع منتجاتنا من كروت، أكياس، وبادجات',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 32),

          // البحثات الأخيرة
          if (search.recentSearches.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'البحثات الأخيرة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...search.recentSearches.map((searchTerm) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    _textController.text = searchTerm;
                    search.searchProducts(searchTerm);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            searchTerm,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[500], size: 18),
                          onPressed: () => search.removeRecentSearch(searchTerm),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            if (search.recentSearches.length > 3)
              TextButton(
                onPressed: search.clearRecentSearches,
                child: Text(
                  'مسح الكل',
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 32),

          // الفئات السريعة
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'البحث السريع',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: search.categories.map((category) {
              return InkWell(
                onTap: () => search.filterByCategory(category),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.search_off,
              size: 50,
              color: Colors.grey[400],
            ),
          ).animate().scale(delay: 200.ms),

          const SizedBox(height: 24),

          Text(
            'لا توجد نتائج',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 8),

          Text(
            'لم نجد أي منتجات تطابق بحثك\nجرب كلمات مختلفة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              _textController.clear();
              searchController.clearSearch();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'مسح البحث',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchController search) {
    return Column(
      children: [
        // عدد النتائج
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'وُجد ${search.searchResults.length} منتج',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.right,
          ),
        ).animate().fadeIn(delay: 200.ms),

        // النتائج
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: search.searchResults.length,
            itemBuilder: (context, index) {
              final product = search.searchResults[index];
              return _buildProductItem(product, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go('/product/${product.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // صورة المنتج
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.image,
                  color: Colors.grey[400],
                  size: 40,
                ),
              ),

              const SizedBox(width: 16),

              // تفاصيل المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      product.shortDescription,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        if (product.matrial != null)
                          Row(
                            children: [
                              Text(
                                product.matrial!,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 1);
  }
}
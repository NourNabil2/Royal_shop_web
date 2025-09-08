import 'package:flutter/material.dart';
import 'package:shoping/core/model/product_model.dart';
import 'package:shoping/features/home/data/product_db.dart';

class SearchController extends ChangeNotifier {
  List<Product> _allProducts = sampleProducts;
  List<Product> _searchResults = [];
  List<String> _recentSearches = [];
  String _searchQuery = '';
  bool _isSearching = false;
  String? _selectedCategory;

  List<Product> get searchResults => _searchResults;
  List<Product> get allProducts => _allProducts;
  List<String> get recentSearches => _recentSearches;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get hasResults => _searchResults.isNotEmpty;
  String? get selectedCategory => _selectedCategory;

  // الحصول على جميع الفئات
  List<String> get categories {
    final set = _allProducts.map((p) => p.category).toSet().toList();
    set.sort();
    return set;
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
    _isSearching = query.isNotEmpty;

    if (query.isEmpty) {
      _searchResults = [];
    } else {
      final q = query.toLowerCase();
      _searchResults = _allProducts.where((product) {
        final matchesQuery =
            product.name.toLowerCase().contains(q) ||
                product.category.toLowerCase().contains(q) ||
                product.description.toLowerCase().contains(q) ||
                (product.matrial?.toLowerCase().contains(q) ?? false);

        final matchesCategory = _selectedCategory == null ||
            product.category == _selectedCategory;

        return matchesQuery && matchesCategory;
      }).toList();

      if (!_recentSearches.contains(_searchQuery) && _searchQuery.length > 2) {
        _recentSearches.insert(0, _searchQuery);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    }
    notifyListeners();
  }


  void filterByCategory(String? category) {
    _selectedCategory = category;
    _isSearching = true; // علشان الواجهة تعرض النتائج حتى بدون نص بحث

    if (category == null) {
      // "الكل": رجّع كل المنتجات من الداتابيز
      _searchResults = List<Product>.from(_allProducts);
    } else {
      _searchResults = _allProducts.where((p) => p.category == category).toList();
    }

    notifyListeners();
  }

// مسح البحث يرجّع كل حاجة للحالة الأولية
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _selectedCategory = null;
    notifyListeners();
  }


  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }
}
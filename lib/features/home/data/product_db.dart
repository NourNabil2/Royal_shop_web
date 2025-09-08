
// Sample Data
import 'package:shoping/core/model/product_model.dart';


final List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'اكياس جرار ( مصنفرة )',
    imageUrls: [
      'assets/product/bag_1.jpeg',
      'assets/product/bag_2.jpeg',
    ],
    price: 0,
    matrial: 'مصنفره',
    inStock: true,
    shortDescription: 'كميات تبدأ من ١٠٠ قطعه',
    description: 'كميات تبدأ من ١٠٠ قطعه ساده\nالطباعه تبدأ من ٢٠٠ كيس مطبوع',
    category: 'اكياس',
  ),
  Product(
    id: '2',
    name: 'كارت صنف قطعتين',
    imageUrls: [
      'assets/product/card_1.jpeg',

    ],
    inStock: true,
    matrial: 'ورق',
    price: 0,
    shortDescription: 'الكمية تبدأ من 2000 كارت',
    description: 'الكمية تبدأ من 2000 كارت\nالسعر يختلف حسب الكمية المطلوبه',
    category: 'كروت',
  ),
  Product(
    id: '3',
    name: 'كارت صنف قطعتين',
    matrial: 'ورق',
    imageUrls: [
      'assets/product/card2_1.jpeg',
      'assets/product/card2_2.jpeg',
    ],
    price: 0,
    inStock: true,
    shortDescription: 'الكمية تبدأ من 2000 كارت',
    description: 'الكمية تبدأ من 2000 كارت\nالسعر يختلف حسب الكمية المطلوبه',
    category: 'كروت',
  ),
  Product(
    id: '4',
    name: 'كارت صنف 5.3×9',
    matrial: 'ورق',
    dimensions: '9 X 5.3',
    imageUrls: [
      'assets/product/card5X9_5.jpeg',
      'assets/product/card5X9_1.jpeg',
      'assets/product/card5X9_2.jpeg',
      'assets/product/card5X9_3.jpeg',
      'assets/product/card5X9_4.jpeg',
    ],
    price: 0,
    inStock: true,
    shortDescription: 'كميات تبدأ من 1000 كارت',
    description: 'كميات تبدأ من 1000 كارت.\nالسعر يحدد حسب الكميه المطلوبه',
    category: 'كروت',
  ),
  Product(
    id: '5',
    name: 'كارت صنف 5 ×11',
    dimensions: '11 X 5',
    imageUrls: [
      'assets/product/card_5.jpeg',
    ],
    price: 0,
    inStock: true,
    matrial: 'ورق',
    shortDescription: 'الكمية تبدأ من 2000 كارت',
    description: 'الكمية تبدأ من 2000 كارت\nالسعر يختلف حسب الكمية المطلوبه',
    category: 'كروت',
  ),
  Product(
    id: '6',
    name: 'بدجات نسيج',
    imageUrls: [
      'assets/product/badge_1.jpeg',
    ],
    price: 0,
    matrial: 'نسيج',
    inStock: true,
    shortDescription: 'الكميه تبدأ من 500 قطعه السعر يحدد',
    description:  'الكميه تبدأ من 500 قطعه السعر يحدد\nالسعر يختلف حسب الكمية المطلوبه',
    category: 'بدجات',
  ),
  Product(
    id: '7',
    name: 'تكت ستان مطبوع ( لتعليمات غسيل )',
    imageUrls: [
      'assets/product/Ticket_1.jpeg',
      'assets/product/Ticket_2.jpeg',
      'assets/product/Ticket_3.jpeg',
      'assets/product/Ticket_4.jpeg',
    ],
    price: 0,
    matrial: 'ستان',
    inStock: true,
    shortDescription: 'كميه تبدأ من 1000 متر 5 بكرات',
    description:  'كميه تبدأ من 1000 متر 5 بكرات\nالسعر يختلف حسب الكمية المطلوبه',
    category: 'تكت',
  ),
  //box
  Product(
    id: '8',
    name: 'بوكسات كرتون',
    imageUrls: [
      'assets/product/box1.jpeg',
      'assets/product/box2.jpeg',
      'assets/product/box3.jpeg',
      'assets/product/box4.jpeg',
    ],
    price: 0,
    matrial: 'كرتون',
    inStock: true,
    shortDescription: 'كميه تبدأ من ٥٠ بوكس',
    description:  'كميه تبدأ من ٥٠ بوكس\nالسعر بتحدد حسب مقاس البوكس والكمية',
    category: 'كرتون',
  ),
];
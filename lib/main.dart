import 'package:acer_app/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'pages/edit_profile_page.dart';
import 'firebase_options.dart';
import 'location_page.dart';
import 'models/user_model.dart';
import 'all_categories_page.dart';
import 'all_products_page.dart';
import 'dart:ui';
import 'forgot_password_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'error_page.dart';
import 'pages/my_orders_page.dart'; 
import 'pages/privacy_policy_page.dart';
import 'about_acer_store.dart';
import 'help_support.dart'; 
import 'terms_services.dart'; 
import 'email_prefernces.dart'; 
import 'address_managment.dart'; 
import 'payment_methods.dart';
import 'checkout_page.dart'
    as new_checkout; 
import 'providers/theme_provider.dart';   
import 'theme/app_theme.dart'; 
import 'beautiful_cart_page.dart';
import 'providers/notification_provider.dart' as providers;
import 'services/local_notification_service.dart';
import 'pages/notifications_page.dart' as pages;
import 'predator_series.dart';
import 'swift_series.dart';
import 'aspire_series.dart';
import 'beautiful_product_details.dart';
import 'services/connectivity_service.dart';
import 'pages/offline_page.dart'; 

// Define Acer brand colors
const Color acerPrimaryColor = Color(0xFF83B81A); // Acer green
const Color acerSecondaryColor = Color(0xFF1A1A1A); // Dark gray/black
const Color acerAccentColor = Color(0xFF0079C1); // Acer blue

// Custom theme for the Acer Store app
ThemeData acerTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: acerPrimaryColor,
    onPrimary: Colors.white,
    secondary: acerSecondaryColor,
    onSecondary: Colors.white,
    tertiary: acerAccentColor,
    surface: Colors.white,
    error: Colors.red[700]!,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: acerPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: acerPrimaryColor,
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: acerPrimaryColor.withOpacity(0.2),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
);

// Product model class
class Product {
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
  });
}

// Cart Provider to manage cart state
class CartProvider extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => _items;
  int get itemCount => _items.values.fold(0, (sum, quantity) => sum + quantity);
  double get totalAmount => _items.entries
      .fold(0, (sum, entry) => sum + (entry.key.price * entry.value));

  void addItem(Product product) {
    _items[product] = (_items[product] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product] == 1) {
        _items.remove(product);
      } else {
        _items[product] = _items[product]! - 1;
      }
      notifyListeners();
    }
  }

  void removeItemCompletely(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Add this after CartProvider class
class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final SharedPreferences _prefs;

  UserProvider(this._prefs) {
    // Load saved user data when provider is initialized
    _loadSavedUser();
  }

  User? get currentUser => _currentUser;

  void setUser(User user) async {
    _currentUser = user;
    // Save user data to SharedPreferences
    await _prefs.setString('user_name', user.name);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_phone', user.phone);
    await _prefs.setString('user_image_url', user.imageUrl ?? '');
    notifyListeners();
  }

  void clearUser() async {
    _currentUser = null;
    // Clear saved user data
    await _prefs.remove('user_name');
    await _prefs.remove('user_email');
    await _prefs.remove('user_phone');
    await _prefs.remove('user_image_url');
    notifyListeners();
  }

  void _loadSavedUser() {
    final name = _prefs.getString('user_name');
    final email = _prefs.getString('user_email');
    final phone = _prefs.getString('user_phone');
    final imageUrl = _prefs.getString('user_image_url');

    if (name != null && email != null && phone != null) {
      _currentUser = User(
        name: name,
        email: email,
        phone: phone,
        imageUrl: imageUrl?.isEmpty ?? true ? null : imageUrl,
      );
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    clearUser();
    await _prefs.clear();
  }
}





// Sample product data
final List<Product> products = [
  // Entry Level Gaming
  Product(
    name: 'Acer Nitro 5',
    imageUrl: 'https://metrokomputer.id/wp-content/uploads/2023/10/1-3.png',
    price: 69999,
    description:
        'The Intel Core i5 processors in the Nitro 5 (e.g., i5-10300H, i5-11400H, or i5-12500H) are mid-range, multi-core CPUs with 4-12 cores and boost clocks up to 4.5 GHz. Paired with the RTX 3050, they provide efficient multitasking and gaming performance, achieving 60-80 fps in modern titles at 1080p medium-high settings.',
    category: 'Entry Level Gaming',
  ),
  Product(
    name: 'Acer Aspire 7',
    imageUrl: 'https://laptopmedia.com/wp-content/uploads/2021/01/1-62.jpg',
    price: 54999,
    description:
        'The Acer Aspire 7 is a performance-oriented laptop designed for both professionals and casual gamers. It strikes a balance between power, portability, and affordability, making it an ideal choice for students, content creators, coders, and business users.',
    category: 'Entry Level Gaming',
  ),
  Product(
    name: 'Acer Nitro V',
    imageUrl: 'https://metrokomputer.id/wp-content/uploads/2023/10/1-3.png',
    price: 62999,
    description:
        'The Acer Nitro V series equipped with the NVIDIA GeForce RTX 2050 GPU is engineered to deliver a balanced performance for gamers, content creators, and professionals seeking a reliable and efficient laptop.',
    category: 'Entry Level Gaming',
  ),

  // Mid-Range Gaming
  Product(
    name: 'Acer Nitro 5 (RTX 3060)',
    imageUrl:
        'https://storage.googleapis.com/stateless-gstylemag-com/2023/12/c3ca0eaa-acer-nitro-v-16-anv16-41_front-facing-1160x919.png',
    price: 79999,
    description:
        'The Acer Nitro 5 RTX 3060 (AMD) is a mid-range gaming laptop with an NVIDIA RTX 3060 (6GB GDDR6), AMD Ryzen 5 5600H or Ryzen 7 5800H, and a 15.6-inch 144Hz Full HD IPS display. It has 8GB/16GB DDR4, 512GB SSD, Wi-Fi 6, and dual-fan cooling.',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Acer Predator Helios 300',
    imageUrl:
        'https://assets.mmsrg.com/isr/166325/c1/-/ASSET_MMS_95212261/fee_786_587_png',
    price: 89999,
    description:
        'Acer Predator Helios 300 RTX 3060 (AMD) is a mid-range gaming laptop with an RTX 3060 (6GB), AMD Ryzen 5 5600H or Ryzen 7 5800H, and 15.6-inch 144Hz/240Hz Full HD IPS display. It has 16GB DDR4, 512GB SSD, Wi-Fi 6, and AeroBlade cooling.',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Acer Predator Helios Neo 16',
    imageUrl:
        'https://static.wixstatic.com/media/131a7a_c475ba2376b74907991f40650d516b59~mv2.png/v1/fill/w_963,h_789,al_c,q_90,enc_auto/131a7a_c475ba2376b74907991f40650d516b59~mv2.png',
    price: 94999,
    description:
        'The Acer Predator Helios Neo 16 (2024) with Intel and RTX 4080 is a high-performance gaming laptop featuring a 14th Gen Intel Core i9-14900HX, NVIDIA RTX 4080 (12GB GDDR6), and a 16-inch WQXGA (2560x1600) IPS display with 240Hz refresh. It includes 32GB DDR5, 1TB SSD, Wi-Fi 7, and dual AeroBlade 3D fan cooling.',
    category: 'Mid-Range Gaming',
  ),

  // High-End Gaming
  Product(
    name: 'Acer Predator Triton 500 SE',
    imageUrl:
        'https://images.frandroid.com/wp-content/uploads/2022/01/acer-predator-triton-500-se-2022-frandroid-2022.png',
    price: 149999,
    description:
        'The Acer Predator Helios 500 SE (PH517-52) is a high-end gaming laptop with an Intel Core i9-11980HK, NVIDIA RTX 3080 (165W, 16GB), and 17.3-inch 4K Mini LED display. It features 32GB DDR4, 2TB SSD (RAID0), Wi-Fi 6, and advanced cooling with PowerGem.',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Acer Predator Helios 500',
    imageUrl:
        'https://delta-game.ru/wp-content/uploads/2018/08/Acer-Predator-Helios-500-PH517-51-74ZA.png',
    price: 199999,
    description:
        'The Acer Predator Helios 500 (PH517-52, 2021) is a high-end gaming laptop with an Intel Core i9-11980HK, NVIDIA RTX 3080 (16GB GDDR6), and 17.3-inch 4K Mini LED 120Hz display. It features 32GB DDR4, dual 1TB PCIe 4 SSDs in RAID0, Wi-Fi 6, and AeroBlade 3D cooling with PowerGem.',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Acer Predator Triton 700',
    imageUrl:
        'https://www.pngkit.com/png/full/340-3400698_predator-triton-700-gaming-laptop-acer-predator-triton.png',
    price: 219999,
    description:
        'The Acer Predator Triton 700 RTX 3080 series is a high-performance gaming laptop with an NVIDIA RTX 3080 (8GB GDDR6), Intel Core i7-11800H, and a 15.6-inch Full HD 120Hz IPS display. It features 16GB DDR4, 1TB SSD, Wi-Fi 6, and AeroBlade 3D cooling.',
    category: 'High-End Gaming',
  ),

  // Business & Productivity
  Product(
    name: 'Acer Swift 3',
    imageUrl:
        'https://www.pngkey.com/png/full/933-9332504_swift-3-sf313-51-01-acer-swift-3.png',
    price: 54999,
    description:
        'The 2024 Acer Swift 3 (Swift Go 14, SFG14-73) is an ultrathin AI PC with AMD Ryzen AI 8040 Series processors (e.g., Ryzen 7 8845HS, 8-core, up to 5.1 GHz) and a 14-inch 2.8K OLED display (90Hz, 100% DCI-P3). It features 16GB LPDDR5X, 1TB SSD, Wi-Fi 7, and a 65Wh battery (~12 hours).',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Acer Spin 5',
    imageUrl:
        'https://www.systembaba.com/uploaded_files/acer-spin-5-2022-3513f.png',
    price: 64999,
    description:
        'Acer Spin 5 (2022, SP514-51N): A 2-in-1 convertible laptop with a 14-inch WQXGA (2560x1600) 16:10 touchscreen, 12th Gen Intel Core i7-1260P, 16GB LPDDR5, 512GB SSD, and Wi-Fi 6.',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Acer TravelMate P6',
    imageUrl:
        'https://www.creativeit.tv/wp-content/uploads/2020/03/TravelMate.png',
    price: 74999,
    description:
        'Acer TravelMate P6 14 AI: A premium business laptop with Intel Core Ultra processors, 14-inch WQXGA (2560x1600) OLED display, 16GB/32GB LPDDR5X RAM, and 512GB/1TB SSD.',
    category: 'Business & Productivity',
  ),

  // Monitors
  Product(
    name: 'Acer Predator XB273K',
    imageUrl:
        'https://pisces.bbystatic.com/image2/BestBuy_US/images/products/6577/6577093_sd.png',
    price: 49999,
    description:
        'A 27-inch 4K UHD (3840x2160) IPS gaming monitor with a 160Hz refresh rate, 0.5ms response time, AMD FreeSync Premium, VESA DisplayHDR 400, and 95% DCI-P3. Features 2x HDMI 2.1, DisplayPort 1.4, and ergonomic stand.',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer Nitro XV272U',
    imageUrl:
        'https://www.notebookcheck.com/fileadmin/Notebooks/News/_nc3/Nitro_XV272U_KF_1.png',
    price: 24999,
    description:
        'The latest Acer Nitro XV272U series continues to deliver impressive gaming performance at a competitive price point, focusing on 27-inch, 1440p (QHD) resolution. These monitors primarily utilize IPS panels, offering vibrant colors and wide viewing angles.',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer ProDesigner PE320QK',
    imageUrl:
        'https://th.bing.com/th/id/OIP.3SycXmBrNb_asw6zbmfFhAHaHa?rs=1&pid=ImgDetMain',
    price: 59999,
    description:
        'Models like the PE320QK and newer iterations boast 32-inch 4K UHD IPS panels, covering 99% of Adobe RGB and 99% of DCI-P3 color gamuts, often with Delta E < 2 calibration out of the box.',
    category: 'Monitors',
  ),
  Product(
    name: 'Acer CB342CK',
    imageUrl:
        'https://assets.mmsrg.com/isr/166325/c1/-/ASSET_MMS_91106875/fee_786_587_png',
    price: 19999,
    description:
        'Featuring a vibrant 34-inch ultrawide curved display, these models aim to simplify computing for home and office use. They typically boast Intel processors, integrated graphics, and a focus on seamless integration with Google Workspace and the wider Chrome ecosystem.',
    category: 'Monitors',
  ),

  // Accessories
  Product(
    name: 'Acer Predator Cestus 350',
    imageUrl:
        'https://static.acer.com/up/Resource/Acer/Accessories/Predator/Predator-Cestus-350/images/20200302/Predator-Cestus_350_sku-main.png',
    price: 4999,
    description:
        'The latest iteration features a refined ergonomic shape and continues to offer swappable side grips to tailor the fit to various hand sizes and grip styles. It boasts a high-precision optical sensor with up to 12,000 DPI, ensuring accurate tracking, and utilizes Omron switches for responsive and durable clicks.',
    category: 'Accessories',
  ),
  Product(
    name: 'Acer Predator Aethon 500',
    imageUrl:
        'https://sm.ign.com/t/ign_pk/cover/a/acer-preda/acer-predator-aethon-500_gcud.300.png',
    price: 7999,
    description:
        "The Acer Predator Aethon CG500 series keyboards are built for immersive gaming experiences, focusing on customization and performance. Available in full-size and TKL (tenkeyless) layouts, they feature Predator's custom-engineered mechanical switches.",
    category: "Accessories",
  ),
  Product(
    name: 'Acer Nitro Headset',
    imageUrl:
        'https://th.bing.com/th/id/R.24a12b0030bbbe89ccd1cf49eb5ef00d?rik=Dfxj16XlL0ZQnQ&riu=http%3a%2f%2fwww.acerstore.cl%2fcdn%2fshop%2ffiles%2fheadset_1a-1.png%3fv%3d1724192851&ehk=oxdlPI%2fzhd%2fPyFkqj8Xw903xxcoNoiECFVozSMv1L70%3d&risl=&pid=ImgRaw&r=0',
    price: 3999,
    description:
        'Featuring a sleek, minimalist design, these headsets boast larger 40mm drivers delivering immersive sound with enhanced bass for a competitive edge.  They prioritize long-lasting comfort with plush memory foam earcups and adjustable headbands, making them suitable for extended gaming sessions.',
    category: 'Accessories',
  ),
  Product(
    name: 'Acer Predator Gaming Chair',
    imageUrl:
        'https://static.acer.com/up/Resource/Acer/Accessories/Predator/Predator_Gaming_Chair/Images/20180713/Predator-gaming-chair-PGC810-preview.png',
    price: 19999,
    description:
        'The latest Acer Predator gaming chairs represent a significant leap in both comfort and integrated technology. Moving beyond purely aesthetic aggression, these chairs prioritize long-duration gameplay with a focus on ergonomic support.',
    category: 'Accessories',
  ),
];

// Add categories list at the top level
final List<String> categories = [
  'All',
  'Entry Level Gaming',
  'Mid-Range Gaming',
  'High-End Gaming',
  'Business & Productivity',
  'Monitors',
  'Accessories',
];

// Sample products data
final List<Product> sampleProducts = [
  // Gaming Laptops
  Product(
    name: 'Predator Helios 16',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 199999.99,
    description:
        "The 2024 Predator Helios 16 represents Acer's continued push into premium gaming laptops. This generation boasts Intel's latest 14th Gen HX Series processors paired with up to NVIDIA GeForce RTX 4090 graphics, delivering exceptional performance for demanding games and creative applications. A standout feature is the 16-inch WQXGA mini-LED display with a blazing 240Hz refresh rate",
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Predator Triton 17 X',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 189999.99,
    description:
        'The Acer Predator Triton 17 X (PTX17-71) is a premium gaming laptop that combines cutting-edge performance with a sleek, minimalist design. Powered by up to a 13th Gen Intel® Core™ i9-13900HX processor and NVIDIA® GeForce RTX™ 4090 GPU.',
    category: 'High-End Gaming',
  ),
  Product(
    name: 'Nitro 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description:
        'The Acer Nitro 5 (AN515-57-74QK) is a mid-range gaming laptop that offers a balance of performance and affordability. It features a 15.6-inch Full HD IPS display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4060 GPU.',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Acer Travelmate 7',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 109999.99,
    description:
        'The Acer Travelmate 7 (PX715-51) is a business laptop that offers a balance of performance and portability. It features a 15.6-inch Full HD IPS display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4070 GPU.',
    category: 'Mid-Range Gaming',
  ),
  Product(
    name: 'Aspire Gaming 5',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 59999.99,
    description:
        'The Acer Aspire Gaming 5 (AN515-57-54QK) is an entry-level gaming laptop that offers a balance of performance and affordability. It features a 15.6-inch Full HD IPS display, up to a 12th Gen Intel® Core™ i5-12450H processor, and NVIDIA® GeForce RTX™ 3050 GPU.',
    category: 'Entry Level Gaming',
  ),

  // Business Laptops
  Product(
    name: 'Swift Edge 16',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 129999.99,
    description:
        'The Acer Swift Edge 16 (SF16-61) is a high-performance business laptop that offers a balance of performance and portability. It features a 16-inch 3.2K OLED display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4060 GPU.',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'Swift Go 14',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description:
        'The Acer Swift Go 14 (SFG14-73) is a high-performance business laptop that offers a balance of performance and portability. It features a 14-inch 2.8K OLED display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4060 GPU.',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'TravelMate P4',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 79999.99,
    description:
        'The Acer TravelMate P4 (PT415-51) is a high-performance business laptop that offers a balance of performance and portability. It features a 15.6-inch Full HD IPS display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4060 GPU.',
    category: 'Business & Productivity',
  ),
  Product(
    name: 'TravelMate P2',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 54999.99,
    description:
        'The Acer TravelMate P2 (PT215-51) is a high-performance business laptop that offers a balance of performance and portability. It features a 15.6-inch Full HD IPS display, up to a 13th Gen Intel® Core™ i7-13700H processor, and NVIDIA® GeForce RTX™ 4060 GPU.',
    category: 'Business & Productivity',
  ),

  // Monitors
  Product(
    name: 'Predator X45',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 149999.99,
    description:
        'The Acer Predator X45 (X45-1) is a high-performance gaming monitor that offers a balance of performance and portability. It features a 45-inch OLED display, 3440x1440 resolution, 240Hz refresh rate, and 0.01ms response time.',
    category: 'Monitors',
  ),
  Product(
    name: 'Predator X27',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 89999.99,
    description:
        'The Acer Predator X27 (X27-1) is a high-performance gaming monitor that offers a balance of performance and portability. It features a 27-inch 4K display, 160Hz refresh rate, and G-SYNC Ultimate.',
    category: 'Monitors',
  ),
  Product(
    name: 'Nitro XV272U',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 29999.99,
    description:
        'The Acer Nitro XV272U (XV272U-1) is a high-performance gaming monitor that offers a balance of performance and portability. It features a 27-inch 170Hz display, AMD FreeSync Premium, and 95% DCI-P3 color gamut.',
    category: 'Monitors',
  ),
  Product(
    name: 'CB342CK',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 34999.99,
    description:
        'The Acer CB342CK (CB342CK-1) is a high-performance gaming monitor that offers a balance of performance and portability. It features a 34-inch 100Hz display, USB-C, and 95% DCI-P3 color gamut.',
    category: 'Monitors',
  ),

  // Accessories
  Product(
    name: 'Predator Cestus 350',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 7999.99,
    description:
        'The Acer Predator Cestus 350 (C350-1) is a high-performance gaming mouse that offers a balance of performance and portability. It features a 16000 DPI, RGB, and 95% DCI-P3 color gamut.',
    category: 'Accessories',
  ),
  Product(
    name: 'Predator Aethon 500',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 12999.99,
    description:
        'The Acer Predator Aethon 500 (A500-1) is a high-performance gaming keyboard that offers a balance of performance and portability. It features Blue Switches, RGB, and 95% DCI-P3 color gamut.',
    category: 'Accessories',
  ),
  Product(
    name: 'Predator Galea 350',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 5999.99,
    description:
        'The Acer Predator Galea 350 (G350-1) is a high-performance gaming headset that offers a balance of performance and portability. It features 7.1 Virtual Surround, RGB, and 95% DCI-P3 color gamut.',
    category: 'Accessories',
  ),
  Product(
    name: 'Nitro Gaming Mouse Pad',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1711051475117-f3a4d3ff6778?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    price: 1499.99,
    description:
        'The Acer Nitro Gaming Mouse Pad (MGP250-1) is a high-performance gaming mouse pad that offers a balance of performance and portability. It features XXL Size, Anti-slip Base, Cloth Surface, and 95% DCI-P3 color gamut.',
    category: 'Accessories',
  ),
];

// Add DotPatternPainter class at the top level (outside of any other classes)
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dotSize = 2.0;
    const spacing = 20.0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7) // Softer white
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawPoints(
          PointMode.points,
          [Offset(x, y)],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Add missing classes required by navigation
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Product> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<Product> results = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Search for Acer products by name, category, or features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, _searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _darkMode = false;
  bool _notifications = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notificationsEnabled') ?? true;
    });

    // Apply theme immediately
    _applyTheme();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notificationsEnabled', _notifications);
  }

  void _applyTheme() async {
    // Apply theme changes immediately
    if (!mounted) return;
    
    // Import ThemeController
    // ignore: await_only_futures
    await Provider.of<ThemeProvider>(context, listen: false).setDarkMode(_darkMode);
  }

  Widget _buildUserImage(String imageUrl, double width, double height) {
    if (imageUrl.startsWith('data:image')) {
      // Handle base64 encoded images
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person,
          size: 54,
          color: acerPrimaryColor,
        ),
      );
    } else {
      // Handle network images
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.person,
          size: 54,
          color: acerPrimaryColor,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: acerPrimaryColor,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 25,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 0,
            toolbarHeight: 64,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.help_outline, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupport(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.background,
                  ]
                : [
                    acerPrimaryColor.withAlpha(15),
                    Colors.grey.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _animation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  if (user != null) _buildProfileCard(user),

                  const SizedBox(height: 24),

                  // Account Section
                  _buildSectionHeader('Account', Icons.person),
                  _buildAnimatedSettingsCard(
                    children: [
                      _buildListTile(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                final userProvider =
                                    Provider.of<UserProvider>(context,
                                        listen: false);
                                final user = userProvider
                                    .currentUser; // Get the current user
                                if (user == null) {
                                  // Handle the case where user is null
                                  return const ErrorPage(); // Redirect to an error page or show a message
                                }
                                return EditProfilePage(
                                    user:
                                        user); // Pass the user, ensuring it's non-null
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.location_on_outlined,
                        title: 'Address Management',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddressManagement(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Credit cards, UPI, and more',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentMethods(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Appearance Section
                  _buildSectionHeader(
                      'Appearance', Icons.palette_outlined),
                  _buildAnimatedSettingsCard(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle:
                            const Text('Enable dark theme for the app'),
                        secondary: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _darkMode
                                ? Colors.indigo.withAlpha(30)
                                : Colors.amber.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (_darkMode
                                        ? Colors.indigo
                                        : Colors.amber)
                                    .withAlpha(100),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _darkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: _darkMode 
                                ? AppColors.textOnDark 
                                : Colors.amber,
                          ),
                        ),
                        value: _darkMode,
                        activeColor: acerPrimaryColor,
                        onChanged: (value) {
                          setState(() {
                            _darkMode = value;
                            _saveSettings();
                            _applyTheme();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Theme updated'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Notifications Section
                  _buildSectionHeader(
                      'Notifications', Icons.notifications_outlined),
                  _buildAnimatedSettingsCard(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text(
                            'Receive alerts about deals and new products'),
                        secondary: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _notifications
                                ? acerAccentColor.withAlpha(30)
                                : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (_notifications
                                        ? acerAccentColor
                                        : Colors.grey)
                                    .withAlpha(100),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _notifications
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: _notifications
                                ? acerAccentColor
                                : Colors.grey,
                          ),
                        ),
                        value: _notifications,
                        activeColor: acerPrimaryColor,
                        onChanged: (value) {
                          setState(() {
                            _notifications = value;
                            _saveSettings();
                          });
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.email_outlined,
                        title: 'Email Notifications',
                        subtitle: 'Manage email preferences',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EmailPreferences(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // About Section
                  _buildSectionHeader('About', Icons.info_outline),
                  _buildAnimatedSettingsCard(
                    children: [
                      _buildListTile(
                        icon: Icons.security_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsServices(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupport(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: 'About Acer Store',
                        subtitle: 'Version 1.9.8',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AboutAcerStore(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Sign Out Button
                  _buildSignOutButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(User user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? AppColors.acerGreen.withAlpha(40) 
                : acerPrimaryColor.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.darkCard.withOpacity(0.9),
                        AppColors.darkSurface.withOpacity(0.7),
                      ]
                    : [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.6),
                      ],
              ),
              border: Border.all(
                color: isDarkMode 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar with glowing effect
                Semantics(
                  label: 'Profile picture of ${user.name}',
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: acerAccentColor.withAlpha(60),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: acerPrimaryColor.withOpacity(0.2),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: user.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(52),
                                  child: _buildUserImage(user.imageUrl!, 104, 104),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 54,
                                  color: acerPrimaryColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User name with shadow effect
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // User contact info with better visual separation
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: acerPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: acerPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: acerPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: acerPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user.phone,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Edit profile button with improved styling
                Material(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final currentUser = userProvider.currentUser;
                            if (currentUser == null) {
                              return const ErrorPage();
                            }
                            return EditProfilePage(user: currentUser);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            acerPrimaryColor.withOpacity(0.1),
                            acerAccentColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: acerAccentColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: acerAccentColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: acerAccentColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 15,
                              color: acerAccentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0, left: 4.0, right: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            acerPrimaryColor.withAlpha(20),
            acerPrimaryColor.withAlpha(8),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: acerPrimaryColor.withAlpha(40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  acerPrimaryColor,
                  acerPrimaryColor.withAlpha(200),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: acerPrimaryColor.withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: acerPrimaryColor,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  acerPrimaryColor,
                  acerPrimaryColor.withAlpha(100),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSettingsCard({required List<Widget> children}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: acerPrimaryColor.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: acerPrimaryColor.withAlpha(25),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        acerPrimaryColor.withAlpha(30),
                        acerPrimaryColor.withAlpha(15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: acerPrimaryColor.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: acerPrimaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: acerPrimaryColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: acerPrimaryColor,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFEE5A52),
            Color(0xFFE74C3C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showSignOutConfirmation();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Sign Out'),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: TextButton(
                child: const Text(
                  'SIGN OUT',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  // Sign out the user
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);
                  await userProvider.signOut();

                  // Close the dialog
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();

                  // Navigate to login page
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );
  }
}



class CategoryPage extends StatefulWidget {
  final String category;
  final String title;

  const CategoryPage({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = products.where((product) {
        return product.category.contains(widget.category);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BeautifulProductDetails(product: product),
                ),
              );
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add ProductDetailsPage class after CartModel class
class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;
  final PageController _imagePageController = PageController();

  // Sample specs map - in a real app these would come from the product data
  late Map<String, Map<String, String>> _specifications;

  // Sample reviews - in a real app these would come from a database
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Rahul Sharma',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'rating': 5,
      'date': '15 May 2023',
      'comment':
          'Excellent laptop! The performance is outstanding for gaming and the battery life is impressive. The display quality is exceptional with vibrant colors.',
      'liked': 24,
    },
    {
      'name': 'Priya Patel',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'rating': 4,
      'date': '2 Jun 2023',
      'comment':
          'Great product for the price. The keyboard feels nice to type on and the trackpad is responsive. Only issue is that it runs a bit hot during intensive tasks.',
      'liked': 18,
    },
    {
      'name': 'Amit Kumar',
      'avatar': 'https://randomuser.me/api/portraits/men/62.jpg',
      'rating': 5,
      'date': '23 Apr 2023',
      'comment':
          'Build quality is premium and the design is sleek. Very happy with my purchase. The audio quality is also excellent with rich bass and clear highs.',
      'liked': 10,
    },
  ];

  // Multiple product images for the image carousel
  final List<String> _productImages = [
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/AcerPredatorHelios16_Teaser.jpg',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/4zu3_Acer_Predator_Helios_16_PH16-71.jpg',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/Predator_Helios_16__1_.png',
    'https://www.notebookcheck.net/fileadmin/Notebooks/Acer/Predator_Helios_16_PH16-71/Predator_Helios_16__10_.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupSpecifications();
  }

  void _setupSpecifications() {
    _specifications = {
      'Performance': {
        'Processor': 'Intel Core i7-13700HX / AMD Ryzen 9-7950X',
        'Graphics': 'NVIDIA GeForce RTX 4080 / AMD Radeon RX 7600M XT',
        'RAM': '32GB DDR5 5200MHz (Upgradable to 64GB)',
        'Storage': '1TB PCIe NVMe SSD (Expandable)',
      },
      'Display': {
        'Screen Size': '16-inch WQXGA',
        'Resolution': '2560 x 1600 pixels',
        'Refresh Rate': '240Hz with G-SYNC support',
        'Panel Type': 'IPS Mini-LED with HDR support',
        'Brightness': '600 nits with 100% DCI-P3 color gamut',
      },
      'Design': {
        'Dimensions': '36.2 x 28.0 x 2.85 cm',
        'Weight': '2.6 kg',
        'Keyboard': 'Per-key RGB backlit with anti-ghosting',
        'Cooling': 'Advanced AeroBlade 3D Fan technology',
        'Color': 'Eclipse Black / Abyssal Black',
      },
      'Connectivity': {
        'Wireless': 'Wi-Fi 6E + Bluetooth 5.3',
        'Ports': '2x USB-C (Thunderbolt 4), 3x USB-A 3.2, HDMI 2.1, Ethernet',
        'Audio': 'DTS:X Ultra with dual speakers',
        'Webcam': 'FHD 1080p with dual microphones',
        'Card Reader': 'SD Card reader (UHS-II)',
      },
      'Battery': {
        'Capacity': '90Wh Li-ion battery',
        'Runtime': 'Up to 8 hours of normal usage',
        'Fast Charging': '0 to 50% in 30 minutes',
        'Power Supply': '300W AC adapter',
      },
      'Software': {
        'Operating System': 'Windows 11 Home / Pro',
        'Software Suite': 'Acer PredatorSense, Acer Care Center',
        'Security': 'BIOS password, Kensington lock slot, TPM 2.0',
        'Warranty': '1-year International Travelers Warranty',
      },
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with product name
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: acerPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image carousel
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: _productImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          // Image with gradient overlay
                          Positioned.fill(
                            child: Image.network(
                              index == 0
                                  ? widget.product.imageUrl
                                  : _productImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported,
                                    size: 100, color: Colors.grey),
                              ),
                            ),
                          ),
                          // Gradient overlay for text visibility
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.3, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Carousel indicators
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _productImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == index
                                ? acerPrimaryColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Favorite button
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFavorite
                          ? '${widget.product.name} added to wishlist'
                          : '${widget.product.name} removed from wishlist'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),      
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing product...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // Product content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and rating
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '₹${widget.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: acerPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${(widget.product.price * 1.1).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '10% OFF',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildRatingIndicator(4.5, 125),
                    ],
                  ),
                ),

                // Availability and delivery info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_shipping_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Free Delivery',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Delivery in 2-3 days',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab bar for switching between details, specs, and reviews
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: acerPrimaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: acerPrimaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'DETAILS'),
                      Tab(text: 'SPECIFICATIONS'),
                      Tab(text: 'REVIEWS'),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: 600, // Fixed height for the tab content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Details tab
                      _buildDetailsTab(),

                      // Specifications tab
                      _buildSpecificationsTab(),

                      // Reviews tab
                      _buildReviewsTab(),
                    ],
                  ),
                ),

                // Add to cart section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Buy now button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: acerAccentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to checkout page with single product for Buy Now
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => new_checkout.CheckoutPage(
                                  cartItems: {widget.product: 1},
                                  totalAmount: widget.product.price,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'BUY NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to cart button
                      Expanded(
                        child: Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: acerPrimaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                cart.addItem(widget.product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.product.name} added to cart'),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BeautifulCartPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'ADD TO CART',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced description section with Amazon-like formatting
          const Text(
            'About This Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Formatted description with rich content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main description paragraph with enhanced details
              Text(
                widget.product.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              // Product highlights section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                        'Powered by the latest ${widget.product.category.contains("Gaming") ? "Intel Core i7/i9 or AMD Ryzen 7/9 processors" : "Intel Core or AMD Ryzen processors"} to deliver exceptional performance for all your computing needs'),
                    _buildBulletPoint(
                        'Stunning ${widget.product.category.contains("Gaming") ? "high-refresh rate" : "high-resolution"} display with vibrant colors and excellent viewing angles for immersive visuals'),
                    _buildBulletPoint(
                        'Advanced cooling technology ensures optimal performance even during extended use sessions'),
                    _buildBulletPoint(
                        'Premium build quality with ${widget.product.category.contains("Gaming") ? "RGB backlit keyboard for gaming aesthetics" : "backlit keyboard for productivity in all environments"}'),
                    _buildBulletPoint(
                        'Long-lasting battery life with quick charge technology gets you back to ${widget.product.category.contains("Gaming") ? "gaming" : "work"} faster'),
                    _buildBulletPoint(
                        'Enhanced audio system with ${widget.product.category.contains("Gaming") ? "DTS:X Ultra sound for gaming immersion" : "crystal-clear sound for video conferences and media consumption"}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Technical details section
              const Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  _buildTableRow('Brand', 'Acer'),
                  _buildTableRow('Series', widget.product.category),
                  _buildTableRow(
                      'Screen Size',
                      widget.product.category.contains("Gaming")
                          ? '15.6 to 17.3 inches'
                          : '13.3 to 15.6 inches'),
                  _buildTableRow(
                      'RAM',
                      widget.product.category.contains("Gaming")
                          ? '16GB to 32GB DDR5'
                          : '8GB to 16GB DDR4'),
                  _buildTableRow(
                      'Storage',
                      widget.product.category.contains("Gaming")
                          ? '1TB NVMe SSD'
                          : '512GB NVMe SSD'),
                  _buildTableRow(
                      'Graphics',
                      widget.product.category.contains("Gaming")
                          ? 'NVIDIA GeForce RTX or AMD Radeon RX'
                          : 'Integrated Intel/AMD Graphics'),
                  _buildTableRow('Operating System', 'Windows 11 Home'),
                  _buildTableRow(
                      'Battery Life',
                      widget.product.category.contains("Gaming")
                          ? 'Up to 6 hours'
                          : 'Up to 12 hours'),
                  _buildTableRow(
                      'Weight',
                      widget.product.category.contains("Gaming")
                          ? '2.5 to 3.0 kg'
                          : '1.3 to 1.8 kg'),
                ],
              ),
              const SizedBox(height: 24),

              // Usage scenarios section
              const Text(
                'Perfect For',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _getUsageScenarios()
                    .map((scenario) => Chip(
                          label: Text(scenario),
                          backgroundColor: acerPrimaryColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Additional information with callouts
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      acerPrimaryColor.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: acerPrimaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Choose This ${widget.product.category}?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: acerPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getExtendedDescription(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Acer Certified Quality',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.support_agent,
                            color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '24/7 Technical Support',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.update, color: acerPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Free Software Updates',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Key features header
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Key features grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                Icons.memory,
                'High Performance',
                'Latest generation processor for exceptional speed',
                Colors.blue,
              ),
              _buildFeatureCard(
                Icons.battery_charging_full,
                'Long Battery Life',
                'Up to 8 hours of usage on a single charge',
                Colors.green,
              ),
              _buildFeatureCard(
                Icons.laptop,
                'Premium Display',
                'High resolution screen with vibrant colors',
                Colors.purple,
              ),
              _buildFeatureCard(
                Icons.speaker,
                'Immersive Audio',
                'Crystal-clear sound with deep bass response',
                Colors.orange,
              ),
              _buildFeatureCard(
                Icons.keyboard,
                'Ergonomic Keyboard',
                'Comfortable typing with RGB backlighting',
                Colors.red,
              ),
              _buildFeatureCard(
                Icons.flash_on,
                'Fast Charging',
                '50% charge in just 30 minutes',
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // What's in the box
          const Text(
            'What\'s in the Box',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Box contents list with improved styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoxItem('1 x Acer ${widget.product.name}'),
                _buildBoxItem(
                    '1 x AC Power Adapter (${widget.product.category.contains("Gaming") ? "180W" : "65W"})'),
                _buildBoxItem('1 x Power Cord'),
                _buildBoxItem('1 x User Manual and Quick Start Guide'),
                _buildBoxItem(
                    '1 x Warranty Card (12-month International Warranty)'),
                if (widget.product.category.contains("Gaming"))
                  _buildBoxItem('1 x Acer Gaming Mouse Pad'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Compare with similar items section
          const Text(
            'Compare with Similar Items',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Visit our All Products page to compare this item with other similar products in our catalog.',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllProductsPage(),
                ),
              );
            },
            icon: const Icon(Icons.compare),
            label: const Text('Compare Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: acerPrimaryColor,
              side: const BorderSide(color: acerPrimaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: acerPrimaryColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String property, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            property,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }

  List<String> _getUsageScenarios() {
    if (widget.product.category.contains("Gaming")) {
      return [
        'AAA Gaming',
        'Esports',
        'Game Development',
        'Live Streaming',
        'Video Editing',
        '3D Rendering',
        'Virtual Reality',
      ];
    } else if (widget.product.category.contains("Business")) {
      return [
        'Office Work',
        'Video Conferencing',
        'Data Analysis',
        'Presentations',
        'Web Development',
        'Document Management',
        'Remote Work',
      ];
    } else {
      return [
        'Everyday Computing',
        'Web Browsing',
        'Content Consumption',
        'Student Projects',
        'Light Photo Editing',
        'Office Applications',
        'Email & Communication',
      ];
    }
  }

  String _getExtendedDescription() {
    if (widget.product.category.contains("Gaming")) {
      return 'This premium gaming laptop delivers exceptional performance for the most demanding games and creative applications. The advanced cooling system with dual fans ensures that your system maintains peak performance during intense gaming sessions. The vibrant display with high refresh rate provides smooth gameplay with minimal motion blur, while the RGB keyboard enhances your gaming experience with customizable lighting effects. The powerful speakers deliver immersive audio that puts you right in the middle of the action.';
    } else if (widget.product.category.contains("Business")) {
      return 'Designed for professionals who need reliability, security, and performance, this business laptop helps you stay productive wherever work takes you. The fingerprint reader and facial recognition provide secure and convenient login options, while the military-grade durability ensures your device can withstand the rigors of daily use and travel. The anti-glare display reduces eye strain during long work sessions, and the extended battery life keeps you productive throughout the day without searching for a power outlet.';
    } else {
      return 'Perfect for everyday use, this versatile laptop balances performance and portability to suit your lifestyle. The efficient processor handles multitasking with ease, while the thin and light design makes it easy to take your work or entertainment anywhere. The crisp, clear display is ideal for browsing the web, watching videos, or video chatting with friends and family. With fast charging technology and long battery life, you can stay productive and connected throughout your day.';
    }
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _specifications.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: acerPrimaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSpecIcon(entry.key),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.entries.map((spec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          spec.key,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          spec.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 32),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getSpecIcon(String category) {
    switch (category) {
      case 'Performance':
        return Icons.speed;
      case 'Display':
        return Icons.desktop_windows;
      case 'Design':
        return Icons.design_services;
      case 'Connectivity':
        return Icons.wifi;
      case 'Battery':
        return Icons.battery_charging_full;
      case 'Software':
        return Icons.apps;
      default:
        return Icons.info;
    }
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Rating summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Average rating
              Column(
                children: [
                  const Text(
                    '4.5',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: acerPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on 125 reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Rating bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.7),
                    _buildRatingBar(4, 0.2),
                    _buildRatingBar(3, 0.05),
                    _buildRatingBar(2, 0.03),
                    _buildRatingBar(1, 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Review list
        Expanded(
          child: _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to review this product',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Review header with user info and rating
                        Row(
                          children: [
                            // User avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(review['avatar']),
                              backgroundColor: Colors.grey[300],
                            ),
                            const SizedBox(width: 12),

                            // User name and date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Posted on ${review['date']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Rating stars
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < review['rating']
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Review content
                        Text(
                          review['comment'],
                          style: TextStyle(
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Review actions
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                // Toggle liked state
                                setState(() {
                                  review['isLiked'] =
                                      !(review['isLiked'] ?? false);
                                  if (review['isLiked']) {
                                    review['liked']++;
                                  } else {
                                    review['liked']--;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (review['isLiked'] ?? false)
                                      ? acerPrimaryColor.withOpacity(0.1)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (review['isLiked'] ?? false)
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      size: 14,
                                      color: (review['isLiked'] ?? false)
                                          ? acerPrimaryColor
                                          : Colors.grey[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${review['liked']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (review['isLiked'] ?? false)
                                            ? acerPrimaryColor
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                // Show reply dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reply feature coming soon'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.reply,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reply',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(acerPrimaryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingIndicator(double rating, int reviewCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            ...List.generate(5, (index) {
              if (index < rating.floor()) {
                return const Icon(Icons.star, color: Colors.amber, size: 20);
              } else if (index == rating.floor() && rating % 1 > 0) {
                return const Icon(Icons.star_half,
                    color: Colors.amber, size: 20);
              } else {
                return Icon(Icons.star_border,
                    color: Colors.grey[400], size: 20);
              }
            }),
            const SizedBox(width: 8),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$reviewCount reviews',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 0,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBoxItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// Add LoginPage class before HomePage class
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter email and password'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to sign in with Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get current Firebase user
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Get user provider
        // ignore: use_build_context_synchronously
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Get user data from Firestore or create a basic user object
        User user = User(
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? email,
          phone: firebaseUser.phoneNumber ?? '',
        );

        // Set the user in provider
        userProvider.setUser(user);

        // Navigate to home page
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email. Please sign up first.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Please try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many sign-in attempts. Please try again later.';
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Login Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            ),
          ),

          // Decorative patterns
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerPrimaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerAccentColor.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo with animated shadow
                          _buildAnimatedLogo(),
                          const SizedBox(height: 40),

                          // Form fields with staggered animation
                          _buildStaggeredFormFields(),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: acerAccentColor,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login button with pulse animation
                          _buildAnimatedLoginButton(),

                          // Sign up link
                          _buildSignUpContainer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Image.asset(
                  'assets/logos/acer_logo.png',
                  height: 55,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, acerAccentColor],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [acerPrimaryColor, acerAccentColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredFormFields() {
    return Column(
      children: [
        // Name field
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildInputField(
                  controller: _nameController,
                  label: 'Your Name',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Email field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 200)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        // Password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 400)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedLoginButton() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 600)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, Color(0xFF69A214)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSignUpContainer() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 800)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: acerPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: acerPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: acerPrimaryColor,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// Add SignupPage class
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _isValidIndianPhoneNumber(String phone) {
    // Check if the phone number is exactly 10 digits
    if (phone.length != 10) {
      return false;
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return false;
    }
    
    // Check if the first digit is valid for Indian mobile numbers (6, 7, 8, or 9)
    if (!['6', '7', '8', '9'].contains(phone[0])) {
      return false;
    }
    
    return true;
  }

  Widget _buildPhoneInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: textInputAction,
        style: TextStyle(color: Colors.grey[800]),
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
          _IndianPhoneNumberFormatter(),
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: acerPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: acerPrimaryColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Validate inputs
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Validate phone number
    if (!_isValidIndianPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 10-digit Indian mobile number starting with 6, 7, 8, or 9'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Check password strength
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the newly created Firebase user
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Update profile to add display name
        await firebaseUser.updateDisplayName(name);

        // If possible, update phone number
        // Note: Usually requires verification via SMS code in a real app

        // Reload user to get updated profile
        await firebaseUser.reload();

        // Get user provider
        // ignore: use_build_context_synchronously
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Create user with the entered details
        final user = User(
          name: name,
          email: email,
          phone: phone,
        );

        // Set the user in provider to save in SharedPreferences
        userProvider.setUser(user);

        // Add welcome notification
        // ignore: use_build_context_synchronously
        final notificationProvider = Provider.of<providers.NotificationsProvider>(context, listen: false);
        notificationProvider.addWelcomeNotification(name);

        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            backgroundColor: acerPrimaryColor,
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to home page
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create account';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled.';
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('Signup Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            ),
          ),

          // Decorative patterns
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerPrimaryColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: acerAccentColor.withOpacity(0.1),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: acerPrimaryColor),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with animated logo
                          _buildAnimatedHeader(),
                          const SizedBox(height: 30),

                          // Form fields with staggered animation
                          _buildStaggeredFormFields(),

                          const SizedBox(height: 30),

                          // Signup button with pulse animation
                          _buildAnimatedSignupButton(),

                          const SizedBox(height: 24),

                          // Login link
                          _buildLoginContainer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: value * 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [acerPrimaryColor, acerAccentColor],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Sign Up',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerAccentColor, acerPrimaryColor],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Create a new Acer Store account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 2,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [acerAccentColor, acerPrimaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredFormFields() {
    return Column(
      children: [
        // Name field
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 0)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Email field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 150)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Phone field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 300)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildPhoneInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 450)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Confirm password field with delay
        FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 600)),
          builder: (context, snapshot) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedSignupButton() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 750)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: acerPrimaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [acerPrimaryColor, Color(0xFF69A214)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginContainer() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 900)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: acerPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: acerPrimaryColor.withOpacity(0.7),
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: acerPrimaryColor,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// Custom Indian phone number formatter
class _IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      return oldValue;
    }
    
    // Check if first digit is valid for Indian mobile numbers (6-9)
    if (digitsOnly.isNotEmpty && 
        !['6', '7', '8', '9'].contains(digitsOnly[0])) {
      return oldValue;
    }
    
    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

// ThemeProvider moved to providers/theme_provider.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
      try {
      await LocalNotificationService.initialize();
    } catch (e) {
      debugPrint('Failed to initialize LocalNotificationService: $e');
    }

  // Get shared preferences instance
  final prefs = await SharedPreferences.getInstance();

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                UserProvider(prefs)), // Pass SharedPreferences for persistence
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => providers.NotificationsProvider()),
        ChangeNotifierProvider(
            create: (context) => OrderProvider()), // Add OrderProvider
        ChangeNotifierProvider.value(
            value: connectivityService), // Add ConnectivityService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ThemeProvider, ConnectivityService>(
      builder: (context, userProvider, themeProvider, connectivityService, child) {
        return MaterialApp(
          title: 'Acer Store',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          routes: {
            '/home': (context) => const HomePage(),
            '/offline': (context) => const OfflinePage(),
          },
          home: connectivityService.isOffline
              ? const OfflinePage() // Show offline page when disconnected
              : userProvider.currentUser != null
                  ? const HomePage() // User is logged in, go to HomePage
                  : const LoginPage(), // User is not logged in, go to LoginPage
        );
      }
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(),
    const BeautifulCartPage(),
    const MyOrdersPage(), // Add MyOrdersPage
    const LocationPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages container
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Assistant button (only show on HomePage)
          if (_selectedIndex == 0)
            Positioned(
              right: 20,
              bottom: 90, // Position it above the bottom navigation bar
              child: AcerAssistant(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcerAssistantChatPage(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Stores',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late PageController _pageController;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? 0;
        if (currentPage == 2) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logos/acer_logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        foregroundColor: acerPrimaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'My Orders',
            onPressed: () {
              // Navigate to orders tab (index 3)
              if (context.findAncestorStateOfType<_HomePageState>() != null) {
                // ignore: invalid_use_of_protected_member
                context.findAncestorStateOfType<_HomePageState>()!.setState(() {
                  context
                      .findAncestorStateOfType<_HomePageState>()!
                      ._selectedIndex = 3;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search tab (index 1)
              if (context.findAncestorStateOfType<_HomePageState>() != null) {
                // ignore: invalid_use_of_protected_member
                context.findAncestorStateOfType<_HomePageState>()!.setState(() {
                  context
                      .findAncestorStateOfType<_HomePageState>()!
                      ._selectedIndex = 1;
                });
              }
            },
          ),
          IconButton(
            icon: Consumer<providers.NotificationsProvider>(
                builder: (context, notificationsProvider, child) {
              return Badge(
                isLabelVisible: notificationsProvider?.hasUnreadNotifications ?? false,
                label: Text((notificationsProvider?.unreadCount ?? 0).toString()),
                child: const Icon(Icons.notifications),
              );
            }),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const pages.NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSlider(),
            _buildCategories(context),
            _buildPopularProducts(context),
            const SizedBox(height: 30), // Add some space before the chatbot
            // _buildChatbot(), // Chatbot widget
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {

    return Column(
      children: [
        SizedBox(
          height: 260, // Increased height for more impact
          child: Stack(
            children: [
              // Decorative top wave shape
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        acerPrimaryColor.withOpacity(0.1),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 40,
                      color: acerPrimaryColor.withOpacity(0.05),
                    ),
                  ),
                ),
              ),

              PageView(
                controller: _pageController,
                children: [
                  _buildBanner(
                    'Predator Series',
                    'Ultimate Gaming Experience',
                    acerSecondaryColor,
                    'https://sm.pcmag.com/t/pcmag_au/review/a/acer-preda/acer-predator-triton-700_un4c.1200.png',
                    const PredatorSeries(),
                  ),
                  _buildBanner(
                    'Swift Series',
                    'Ultra-thin, Ultra-powerful',
                    acerAccentColor,
                    'https://images.unsplash.com/photo-1618424181497-157f25b6ddd5?q=80&w=3000',
                    const SwiftSeries(),
                  ),
                  _buildBanner(
                    'Aspire Series',
                    'Everyday Productivity',
                    acerPrimaryColor,
                    'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?q=80&w=3000',
                    const AspireSeries(),
                  ),
                ],
              ),

              // Page indicators with enhanced styling
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: CustomizableEffect(
                      activeDotDecoration: DotDecoration(
                        width: 24,
                        height: 8,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        dotBorder: const DotBorder(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      dotDecoration: DotDecoration(
                        width: 8,
                        height: 8,
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        dotBorder: DotBorder(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      spacing: 8,
                    ),
                  ),
                ),
              ),

              // Banner slider title overlay
              Positioned(
                top: 15,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [acerPrimaryColor, acerAccentColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: acerPrimaryColor.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.whatshot,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Featured Products',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subtle transition element
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: acerPrimaryColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 1,
                      color: acerPrimaryColor.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: acerPrimaryColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(
      String title, String subtitle, Color color, String imageUrl, Widget navigationPage) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: color.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white.withOpacity(0.5),
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Fancy gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content area with glass effect
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with shadow for better visibility
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle with shadow
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Enhanced shop now button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (context) => ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => navigationPage,
                                ),
                              );
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: color,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Decorative element - badge
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                (title.contains('Predator'))
                    ? Icons.sports_esports
                    : (title.contains('Swift'))
                        ? Icons.speed
                        : Icons.computer,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with modern design
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title with decorative elements
                Row(
                  children: [
                    // Decorative vertical line with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Container(
                          height: 28 * value,
                          width: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                acerPrimaryColor,
                                acerAccentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: acerPrimaryColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),

                    // Title text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: acerSecondaryColor,
                                  ),
                        ),
                        Container(
                          width: 60,
                          height: 2,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                acerPrimaryColor,
                                acerPrimaryColor.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Enhanced view all button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: acerAccentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllCategoriesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grid_view_rounded, size: 16),
                    label: const Text('View All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerAccentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable category cards
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 120,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryCard(context, 'Gaming', Icons.videogame_asset,
                      acerPrimaryColor),
                  _buildCategoryCard(
                      context, 'Business', Icons.business, acerAccentColor),
                  _buildCategoryCard(context, 'Monitors', Icons.desktop_windows,
                      Colors.purple),
                  _buildCategoryCard(
                      context, 'Accessories', Icons.headset, Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String title, IconData icon, Color color) {
    // Map the display title to actual category values
    String categoryFilter;
    String categoryTitle;

    switch (title) {
      case 'Gaming':
        categoryFilter = 'Gaming';
        categoryTitle = 'Gaming Laptops';
        break;
      case 'Business':
        categoryFilter = 'Business';
        categoryTitle = 'Business Laptops';
        break;
      case 'Monitors':
        categoryFilter = 'Monitors';
        categoryTitle = 'Monitors';
        break;
      case 'Accessories':
        categoryFilter = 'Accessories';
        categoryTitle = 'Accessories';
        break;
      default:
        categoryFilter = title;
        categoryTitle = title;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryPage(
                    category: categoryFilter,
                    title: categoryTitle,
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.7),
                    color.withOpacity(0.9),
                  ],
                  stops: const [0.3, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Improved icon container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Improved text styling
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Add max lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Subtle indicator
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 2,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularProducts(BuildContext context) {
    // Display first 4 products
    final displayProducts =
        products.length > 4 ? products.sublist(0, 4) : products;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with animated background
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: acerPrimaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: acerPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Popular Products',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to AllProductsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProductsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      label: const Text('View All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: acerPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                // Decorative gradient line
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        acerPrimaryColor,
                        acerPrimaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Enhanced grid layout with custom spacing
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Make cards taller for better layout
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, displayProducts[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BeautifulProductDetails(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image with discount badge
              Stack(
                children: [
                  // Product image
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: acerPrimaryColor.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Discount badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '10% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 4),

                      // Price with original price strikethrough
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: acerPrimaryColor,
                                      fontSize: 16,
                                    ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${(product.price * 1.1).toStringAsFixed(0)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Ratings
                      // const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            double rating = (product.hashCode % 15 + 35) /
                                10; // Generate pseudo-random rating based on product hash
                            return Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : (index == rating.floor() && rating % 1 > 0)
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: Colors.amber,
                              size: 12,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            ((product.hashCode % 15 + 35) / 10)
                                .toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${(product.hashCode % 100) + 10})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Add to cart button
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return InkWell(
                            onTap: () {
                              cart.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: acerPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ADD TO CART',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





// Add this after the EditProfilePage class
class AcerAssistant extends StatefulWidget {
  final Function() onTap;

  const AcerAssistant({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AcerAssistant> createState() => _AcerAssistantState();
}

class _AcerAssistantState extends State<AcerAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isHovered ? _pulseAnimation.value : _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      acerPrimaryColor,
                      acerSecondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: acerPrimaryColor.withOpacity(
                          0.5), // Increased opacity for more visible light green shadow
                      blurRadius: 20, // Increased blur radius
                      spreadRadius:
                          8 * _scaleAnimation.value, // Increased spread radius
                    ),
                  ],
                ),
                child: Stack(
                  // clipBehavior: Clip.hardEdge,
                  alignment: Alignment.bottomRight,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_isHovered)
                      Positioned(
                        top: -30,
                        left: -30,
                        right: -30,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Acer Assistant',
                              style: TextStyle(
                                fontSize: 12,
                                color: acerPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Add this after the AcerAssistant class
class AcerAssistantChatPage extends StatefulWidget {
  const AcerAssistantChatPage({Key? key}) : super(key: key);

  @override
  State<AcerAssistantChatPage> createState() => _AcerAssistantChatPageState();
}

class _AcerAssistantChatPageState extends State<AcerAssistantChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello! I\'m your Acer Assistant. I can help you find the right product, check prices, or get recommendations based on your budget. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    _messageController.clear();

    // Show the assistant is typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 10000));

    // Process the user's message and generate a response
    final response = _generateResponse(text);

    // Hide the typing indicator and add the assistant's response
    setState(() {
      _isTyping = false;
    });

    _addMessage(response, false);
  }

  String _generateResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();

    // Budget recommendation
    if (lowercaseMessage.contains('budget') ||
        lowercaseMessage.contains('affordable') ||
        lowercaseMessage.contains('cheap')) {
      if (lowercaseMessage.contains('gaming') ||
          lowercaseMessage.contains('game')) {
        return 'For gaming on a budget, I recommend the Acer Nitro 5 at ₹69,999 or Acer Aspire 7 at ₹54,999. Both offer great performance for their price with dedicated graphics cards, good RAM, and SSD storage.';
      } else if (lowercaseMessage.contains('business') ||
          lowercaseMessage.contains('work')) {
        return 'For business use on a budget, the Acer Swift 3 at ₹59,999 offers excellent value with its lightweight design, long battery life, and performance suitable for everyday productivity tasks.';
      }
      return 'For budget options, we have several great choices: Acer Aspire 7 at ₹54,999, Acer Swift 3 at ₹59,999, or Acer Nitro V at ₹62,999. What will you be using the laptop for?';
    }

    // Price inquiries
    if (lowercaseMessage.contains('price') ||
        lowercaseMessage.contains('cost') ||
        lowercaseMessage.contains('how much')) {
      if (lowercaseMessage.contains('nitro 5')) {
        return 'The Acer Nitro 5 with RTX 3050 is priced at ₹69,999. It comes with 16GB RAM and 512GB SSD, making it excellent for entry-level gaming.';
      } else if (lowercaseMessage.contains('predator')) {
        return 'The Acer Predator Helios with RTX 3070 is priced at ₹129,999. It\'s our premium gaming laptop with 32GB RAM and 1TB SSD for high-performance gaming.';
      } else if (lowercaseMessage.contains('swift')) {
        return 'The Acer Swift 3 is priced at ₹59,999, while the premium Acer Swift X with dedicated graphics is ₹89,999.';
      }
      return 'I\'d be happy to check the price for you. Could you tell me which specific Acer model you\'re interested in?';
    }

    // Gaming laptop recommendations
    if (lowercaseMessage.contains('gaming') ||
        lowercaseMessage.contains('game') ||
        lowercaseMessage.contains('play')) {
      return 'For gaming, we have several great options:\n\n• Entry-level: Acer Nitro 5 (₹69,999) with RTX 3050\n• Mid-range: Acer Nitro 5 RTX 3060 (₹79,999)\n• High-end: Acer Predator Helios (₹129,999) with RTX 3070\n\nWhat\'s your budget range?';
    }

    // Business/productivity laptop recommendations
    if (lowercaseMessage.contains('business') ||
        lowercaseMessage.contains('work') ||
        lowercaseMessage.contains('office') ||
        lowercaseMessage.contains('productivity')) {
      return 'For business and productivity, I recommend:\n\n• Acer Swift 3 (₹59,999): Lightweight with great battery life\n• Acer TravelMate P6 (₹84,999): Professional-grade with security features\n• Acer Swift X (₹89,999): Powerful with dedicated graphics for content creation\n\nWhich features are most important to you?';
    }

    // General inquiry response
    return 'I can help you find the perfect Acer product. Are you looking for a gaming laptop, business laptop, monitor, or accessories? Or do you have a specific budget in mind?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acer Assistant'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: acerPrimaryColor),
                      SizedBox(width: 10),
                      Text('About Acer Assistant'),
                    ],
                  ),
                  content: const Text(
                    'The Acer Assistant can help you with product recommendations, price information, and finding the right product for your needs. Just ask about products, prices, or your requirements!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          if (_isTyping)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: acerPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Acer Assistant is typing...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _handleSubmitted,
                      decoration: const InputDecoration(
                        hintText:
                            'Ask about products, prices, or recommendations...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: acerPrimaryColor),
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: acerPrimaryColor,
              child:
                  Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? acerAccentColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Add Order model class
class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final Address deliveryAddress;
  final String paymentMethod;
  final String? trackingId;
  final DateTime? estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.trackingId,
    this.estimatedDelivery,
  });
}

class OrderItem {
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned
}

class Address {
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String phone;
  final bool isDefault;
  final String? landmark;
  final String? addressType; // Home, Work, Other

  Address({
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
    this.isDefault = false,
    this.landmark,
    this.addressType,
  });
}

// Add OrderProvider to manage orders
class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add some sample orders for demo purposes
  void addSampleOrders() {
    if (_orders.isNotEmpty) return;

    // Sample addresses
    final homeAddress = Address(
      name: 'Rahul Sharma',
      street: '123, Lotus Apartments, Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      zipCode: '400069',
      phone: '9876543210',
      isDefault: true,
      addressType: 'Home',
    );

    // Sample order 1 - Delivered
    final orderItems1 = [
      OrderItem(
        product: products.first,
        quantity: 1,
        price: products.first.price,
      ),
    ];

    addOrder(Order(
      id: 'ORD123456789',
      items: orderItems1,
      totalAmount: orderItems1.fold(
          0, (sum, item) => sum + (item.price * item.quantity)),
      orderDate: DateTime.now().subtract(const Duration(days: 15)),
      status: OrderStatus.delivered,
      deliveryAddress: homeAddress,
      paymentMethod: 'Credit Card',
      trackingId: 'TRK987654321',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
    ));

    // Sample order 2 - In progress
    final orderItems2 = [
      OrderItem(
        product: products[2],
        quantity: 1,
        price: products[2].price,
      ),
      OrderItem(
        product: products[15],
        quantity: 2,
        price: products[15].price,
      ),
    ];

    addOrder(Order(
      id: 'ORD987654321',
      items: orderItems2,
      totalAmount: orderItems2.fold(
          0, (sum, item) => sum + (item.price * item.quantity)),
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      deliveryAddress: homeAddress,
      paymentMethod: 'UPI',
      trackingId: 'TRK123456789',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    ));
  }

  // Calculate time-based status for an order
  OrderStatus getTimeBasedStatus(Order order) {
    // If order is already cancelled or returned, keep that status
    if (order.status == OrderStatus.cancelled || order.status == OrderStatus.returned) {
      return order.status;
    }

    final now = DateTime.now();
    final orderDate = order.orderDate;
    final difference = now.difference(orderDate);

    // Time-based status progression
    if (difference.inMinutes < 30) {
      return OrderStatus.pending; // First 30 minutes: Order is pending
    } else if (difference.inHours < 2) {
      return OrderStatus.confirmed; // 30 mins - 2 hours: Order is confirmed
    } else if (difference.inHours < 24) {
      return OrderStatus.processing; // 2 - 24 hours: Order is being processed
    } else if (difference.inHours < 72) {
      return OrderStatus.shipped; // 24 - 72 hours: Order is shipped
    } else if (difference.inHours < 96) {
      return OrderStatus.outForDelivery; // 72 - 96 hours: Out for delivery
    } else {
      return OrderStatus.delivered; // After 96 hours (4 days): Delivered
    }
  }

  // Update all orders with time-based status progression
  void updateAllOrdersStatus() {
    bool hasChanges = false;
    
    for (int i = 0; i < _orders.length; i++) {
      final currentOrder = _orders[i];
      final calculatedStatus = getTimeBasedStatus(currentOrder);
      
      // Only update if the calculated status is different from current status
      if (currentOrder.status != calculatedStatus) {
        // Create new order with updated status
        final updatedOrder = Order(
          id: currentOrder.id,
          items: currentOrder.items,
          totalAmount: currentOrder.totalAmount,
          orderDate: currentOrder.orderDate,
          status: calculatedStatus,
          deliveryAddress: currentOrder.deliveryAddress,
          paymentMethod: currentOrder.paymentMethod,
          trackingId: currentOrder.trackingId,
          estimatedDelivery: currentOrder.estimatedDelivery,
        );
        
        _orders[i] = updatedOrder;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifyListeners();
      print('Updated order statuses based on time progression');
    }
  }

  // Update specific order status
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final oldOrder = _orders[orderIndex];
      // Create new order with updated status
      final updatedOrder = Order(
        id: oldOrder.id,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        orderDate: oldOrder.orderDate,
        status: newStatus,
        deliveryAddress: oldOrder.deliveryAddress,
        paymentMethod: oldOrder.paymentMethod,
        trackingId: oldOrder.trackingId,
        estimatedDelivery: oldOrder.estimatedDelivery,
      );
      
      _orders[orderIndex] = updatedOrder;
      notifyListeners();
      print('Updated order ${orderId} status to ${newStatus}');
    }
  }
}

// Add CheckoutPage after CartPage class
class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cartItems;
  final double totalAmount;

  const CheckoutPage(
      {Key? key, required this.cartItems, required this.totalAmount})
      : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  Address? _selectedAddress;
  String _selectedPaymentMethod = 'Credit/Debit Card';

  // Sample delivery address for demo
  final List<Address> _addresses = [
    Address(
      name: 'Rahul Sharma',
      street: '123, Lotus Apartments, Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      zipCode: '400069',
      phone: '9876543210',
      isDefault: true,
      addressType: 'Home',
    ),
    Address(
      name: 'Rahul Sharma',
      street: 'Block C, Tech Park, Whitefield',
      city: 'Bangalore',
      state: 'Karnataka',
      zipCode: '560066',
      phone: '9876543210',
      isDefault: false,
      addressType: 'Work',
    ),
  ];

  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'netbanking',
      'name': 'Net Banking',
      'icon': Icons.account_balance,
    },
    {
      'id': 'cod',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selected address to default one
    _selectedAddress = _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.vertical,
        physics: const ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _placeOrder();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'PLACE ORDER' : 'CONTINUE',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: acerPrimaryColor),
                      ),
                      child: const Text('BACK'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Delivery Address'),
            subtitle: _selectedAddress != null
                ? Text(
                    '${_selectedAddress!.name}, ${_selectedAddress!.city}',
                    style: const TextStyle(fontSize: 12),
                  )
                : const Text('Select delivery address'),
            content: _buildAddressStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Payment Method'),
            subtitle: Text(
              _selectedPaymentMethod,
              style: const TextStyle(fontSize: 12),
            ),
            content: _buildPaymentStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review Order'),
            content: _buildOrderReviewStep(),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List of saved addresses
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _addresses.length,
          itemBuilder: (context, index) {
            final address = _addresses[index];
            final isSelected = _selectedAddress == address;

            return Card(
              elevation: isSelected ? 4 : 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? acerPrimaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () => setState(() => _selectedAddress = address),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<Address>(
                        value: address,
                        groupValue: _selectedAddress,
                        activeColor: acerPrimaryColor,
                        onChanged: (value) {
                          setState(() => _selectedAddress = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(
                                  address.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    address.addressType ?? 'Home',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                if (address.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: acerPrimaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Default',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: acerPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              address.street,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address.city}, ${address.state} - ${address.zipCode}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${address.phone}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Add new address button
        OutlinedButton.icon(
          onPressed: () {
            // In a real app, this would navigate to an address form
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add new address functionality coming soon!'),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('ADD NEW ADDRESS'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: const BorderSide(color: acerPrimaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _paymentMethods.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            final isSelected = _selectedPaymentMethod == method['name'];

            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? acerPrimaryColor.withOpacity(0.2)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method['icon'],
                  color: isSelected ? acerPrimaryColor : Colors.grey[600],
                ),
              ),
              title: Text(method['name']),
              trailing: Radio<String>(
                value: method['name'],
                groupValue: _selectedPaymentMethod,
                activeColor: acerPrimaryColor,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value!);
                },
              ),
              onTap: () {
                setState(() => _selectedPaymentMethod = method['name']);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        if (_selectedPaymentMethod == 'Credit/Debit Card') ...[
          // Credit card form
          const Text(
            'Card Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
              hintText: 'XXXX XXXX XXXX XXXX',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    border: OutlineInputBorder(),
                    hintText: 'MM/YY',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                    hintText: 'XXX',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            keyboardType: TextInputType.name,
          ),
        ] else if (_selectedPaymentMethod == 'UPI') ...[
          // UPI form
          const Text(
            'UPI Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_wallet),
              hintText: 'yourname@upi',
            ),
            keyboardType: TextInputType.text,
          ),
        ],
      ],
    );
  }

  Widget _buildOrderReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Items
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.cartItems.length,
          itemBuilder: (context, index) {
            final product = widget.cartItems.keys.elementAt(index);
            final quantity = widget.cartItems[product] ?? 0;
            final itemTotal = product.price * quantity;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Quantity: $quantity'),
              trailing: Text(
                '₹${itemTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: acerPrimaryColor,
                ),
              ),
            );
          },
        ),
        const Divider(height: 32),

        // Delivery Address
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedAddress != null) ...[
          Card(
            elevation: 0,
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAddress!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_selectedAddress!.street),
                  Text(
                    '${_selectedAddress!.city}, ${_selectedAddress!.state} - ${_selectedAddress!.zipCode}',
                  ),
                  Text('Phone: ${_selectedAddress!.phone}'),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Payment Method
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              _getPaymentIcon(_selectedPaymentMethod),
              color: acerPrimaryColor,
            ),
            title: Text(_selectedPaymentMethod),
          ),
        ),
        const SizedBox(height: 24),

        // Order Summary
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('₹${widget.totalAmount.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shipping'),
                    Text('₹ 2000', style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GST (18%)'),
                    Text('₹${(widget.totalAmount * 0.18).toStringAsFixed(0)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '₹${(widget.totalAmount * 1.18).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: acerPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Credit/Debit Card':
        return Icons.credit_card;
      case 'UPI':
        return Icons.account_balance_wallet;
      case 'Net Banking':
        return Icons.account_balance;
      case 'Cash on Delivery':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _placeOrder() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    try {
      // Generate a random order ID
      final orderId =
          'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Create order items from cart
      final orderItems = widget.cartItems.entries.map((entry) {
        return OrderItem(
          product: entry.key,
          quantity: entry.value,
          price: entry.key.price,
        );
      }).toList();

      // Calculate total amount (with tax for this example)
      final totalWithTax = widget.totalAmount * 1.18;

      // Create new order
      final newOrder = Order(
        id: orderId,
        items: orderItems,
        totalAmount: totalWithTax,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
        deliveryAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
        trackingId:
            'TRK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      );

      // Add to order provider - Force rebuild provider reference to ensure update
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.addOrder(newOrder);

      // Add order notification
      final notificationProvider = Provider.of<providers.NotificationsProvider>(context, listen: false);
      notificationProvider.addOrderNotification(orderId, 'placed', totalWithTax, itemCount: orderItems.length);

      // Clear cart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      // Show success dialog
      _showOrderConfirmationDialog(newOrder);

      // Debug print to confirm order was added
      print('Order added: ${newOrder.id}, items: ${newOrder.items.length}');
      print('Total orders in provider: ${orderProvider.orders.length}');
    } catch (e) {
      // Handle any errors that might occur during order placement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
      print('Error placing order: $e');
    }
  }

  void _showOrderConfirmationDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon and animation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: acerPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Placed Successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: ${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thank you for your order!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order has been confirmed and will be shipped soon. You can track your order using order ID ${order.id}.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: acerPrimaryColor),
                          ),
                          child: const Text('CONTINUE SHOPPING'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: acerPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('VIEW ORDERS'),
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
    );
  }
}

List<Widget> _buildTimelineIndicators(OrderStatus currentStatus) {
  final List<Widget> indicators = [];
  final List<OrderStatus> statuses = OrderStatus.values.toList();
  final int currentStatusIndex = statuses.indexOf(currentStatus);

  for (int i = 0; i < statuses.length; i++) {
    // Skip irrelevant statuses
    if (statuses[i] == OrderStatus.cancelled ||
        statuses[i] == OrderStatus.returned) {
      continue;
    }

    final bool isActive = i <= currentStatusIndex;
    final bool isLast =
        i == statuses.length - 3; // -3 because we skip 2 statuses

    indicators.add(
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? acerPrimaryColor : Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? acerPrimaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: isActive
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              )
            : null,
      ),
    );

    // Add line connecting indicators except for last one
    if (!isLast) {
      indicators.add(
        Container(
          width: 2,
          height: 30,
          color: i < currentStatusIndex ? acerPrimaryColor : Colors.grey[300],
        ),
      );
    }
  }

  return indicators;
}

// Add OrdersPage after OrderDetailsPage
class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize sample orders if the order list is empty
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider.orders.isEmpty) {
      orderProvider.addSampleOrders();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order history will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('BROWSE PRODUCTS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header with ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.orderDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const Divider(height: 24),

              // Product previews
              _buildProductPreviews(order),
              const SizedBox(height: 16),

              // Total and action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: acerPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acerPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('TRACK ORDER'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case OrderStatus.pending:
        badgeColor = Colors.amber;
        statusText = 'Pending';
        break;
      case OrderStatus.confirmed:
        badgeColor = Colors.blue;
        statusText = 'Confirmed';
        break;
      case OrderStatus.processing:
        badgeColor = Colors.orange;
        statusText = 'Processing';
        break;
      case OrderStatus.shipped:
        badgeColor = Colors.indigo;
        statusText = 'Shipped';
        break;
      case OrderStatus.outForDelivery:
        badgeColor = Colors.purple;
        statusText = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        badgeColor = Colors.green;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        badgeColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case OrderStatus.returned:
        badgeColor = Colors.brown;
        statusText = 'Returned';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductPreviews(Order order) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // Display first 3 products
          ...List.generate(
            order.items.length > 3 ? 3 : order.items.length,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order.items[index].product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // Show count if more than 3 products
          if (order.items.length > 3)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '+${order.items.length - 3}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Custom wave clipper for decorative effects
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);

    var firstControlPoint = Offset(size.width / 4, size.height - 20);
    var firstEndPoint = Offset(size.width / 2, size.height - 10);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height);
    var secondEndPoint = Offset(size.width, size.height - 15);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

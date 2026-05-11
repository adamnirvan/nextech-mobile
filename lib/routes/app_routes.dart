import 'package:flutter/material.dart';
import 'package:nextech_mobile/ui/screens/address/address_form_screen.dart';

import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/onboarding/onboarding_screen.dart';
import '../ui/screens/auth/login_register_screen.dart';
import '../ui/screens/main/home_screen.dart';
import '../ui/screens/search/search_screen.dart';
import '../ui/screens/product/product_detail_screen.dart';
import '../ui/screens/cart/cart_screen.dart';
import '../ui/components/navigation_bar.dart';
import '../ui/screens/order/order_screen.dart';
import '../ui/screens/checkout/checkout_screen.dart';
import '../ui/screens/checkout/payment_success_screen.dart';
import '../ui/screens/address/address_list_screen.dart';
import '../ui/screens/discovery/discovery_screen.dart';
import '../ui/screens/admin/admin_main.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String main = '/main'; 
  static const String home = '/home'; 
  static const String adminDashboard = '/admin';
  static const String search = '/search';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String order = '/order';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String addressList = '/address-list';
  static const String addressForm = '/address-form';
  static const String discovery = '/discovery';
  static const String adminMain = '/admin-main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      auth: (context) => const LoginRegisterScreen(),
      main: (context) => const MainScreen(),
      home: (context) => const HomeScreen(),
      adminDashboard: (context) =>
          const Scaffold(body: Center(child: Text("Ini Halaman Khusus Admin"))),
      search: (context) => const SearchScreen(),
      productDetail: (context) => const ProductDetailScreen(),
      cart: (context) => const CartScreen(),
      order: (context) => const OrdersScreen(),
      checkout: (context) => const CheckoutScreen(),
      paymentSuccess: (context) => const PaymentSuccessScreen(),
      addressList: (context) => const AddressListScreen(),
      addressForm: (context) => const AddressFormScreen(),
      discovery: (context) => const DiscoveryScreen(),
      adminMain: (context) => const AdminMainScreen(),
    };
  }
}

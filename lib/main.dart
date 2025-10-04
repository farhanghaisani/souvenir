import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/cart_provider.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Main Screens
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';

// Admin Screens
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_products_screen.dart';

// Payment
import 'screens/payment_webview_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://pvuguwfgmdmibxfdhaef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2dWd1d2ZnbWRtaWJ4ZmRoYWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNDc4MTUsImV4cCI6MjA3NDcyMzgxNX0.GuUY-8mc9HvqwvK-JHmsWoy8WaQsxEAXiYshbc_zH2I',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Souvenir App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
          useMaterial3: true,
          primaryColor: const Color(0xFFFF6B6B),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(), 
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-success': (context) => const OrderSuccessScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/admin/products': (context) => const AdminProductsScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle payment route with arguments
          if (settings.name == '/payment') {
            final url = settings.arguments as String?;
            if (url != null) {
              return MaterialPageRoute(
                builder: (context) => PaymentWebViewScreen(paymentUrl: url),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
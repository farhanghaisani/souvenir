abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const HOME = _Paths.HOME;
  static const PROFILE = _Paths.PROFILE;              // ← TAMBAH INI
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;    // ← TAMBAH INI
  static const CART = _Paths.CART;                    // ← TAMBAH INI
  static const CHECKOUT = _Paths.CHECKOUT;            // ← TAMBAH INI
  static const ORDERS = _Paths.ORDERS;                // ← TAMBAH INI
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const HOME = '/home';
  static const PROFILE = '/profile';                  // ← TAMBAH INI
  static const EDIT_PROFILE = '/edit-profile';        // ← TAMBAH INI
  static const CART = '/cart';                        // ← TAMBAH INI
  static const CHECKOUT = '/checkout';                // ← TAMBAH INI
  static const ORDERS = '/orders';                    // ← TAMBAH INI
}
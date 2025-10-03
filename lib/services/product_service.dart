  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../models/product.dart';

  class ProductService {
    final SupabaseClient _supabase = Supabase.instance.client;

    // Get all products
    Future<List<Product>> getAllProducts() async {
      try {
        final response = await _supabase
            .from('products')
            .select('*, categories(name)')
            .order('created_at', ascending: false);

        return (response as List).map((json) {
          final categoryName =
              json['categories'] != null ? json['categories']['name'] : null;

          return Product.fromJson({
            ...json,
            'category': categoryName,
          });
        }).toList();
      } catch (e) {
        throw Exception('Failed to load products: $e');
      }
    }

    // Get products by category
    Future<List<Product>> getProductsByCategory(String category) async {
      try {
        final response = await _supabase
            .from('products')
            .select('*, categories(name)')
            .eq('categories.name', category)
            .order('created_at', ascending: false);

        return (response as List).map((json) {
          final categoryName =
              json['categories'] != null ? json['categories']['name'] : null;

          return Product.fromJson({
            ...json,
            'category': categoryName,
          });
        }).toList();
      } catch (e) {
        throw Exception('Failed to load products by category: $e');
      }
    }

    // Search products
    Future<List<Product>> searchProducts(String query) async {
      try {
        final response = await _supabase
            .from('products')
            .select('*, categories(name)')
            .ilike('name', '%$query%')
            .order('created_at', ascending: false);

        return (response as List).map((json) {
          final categoryName =
              json['categories'] != null ? json['categories']['name'] : null;

          return Product.fromJson({
            ...json,
            'category': categoryName,
          });
        }).toList();
      } catch (e) {
        throw Exception('Failed to search products: $e');
      }
    }

    // Get product by ID
    Future<Product?> getProductById(String id) async {
      try {
        final response = await _supabase
            .from('products')
            .select('*, categories(name)')
            .eq('id', id)
            .single();

        final categoryName = response['categories'] != null
            ? response['categories']['name']
            : null;

        return Product.fromJson({
          ...response,
          'category': categoryName,
        });
      } catch (e) {
        return null;
      }
    }

    // Get all categories
    Future<List<String>> getCategories() async {
      try {
        final response =
            await _supabase.from('categories').select('name').order('name');

        return (response as List).map((item) => item['name'] as String).toList();
      } catch (e) {
        return [];
      }
    }
  }

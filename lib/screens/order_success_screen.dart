import 'package:flutter/material.dart';
// **IMPORTANT:** Ensure 'home_screen.dart' is in the same directory,
// and that it defines a class named 'HomeScreen'.
import 'home_screen.dart'; 

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The `appBar` is typically null for a full-screen success message, 
      // but you can uncomment this if needed.
      // appBar: AppBar(
      //   automaticallyImplyLeading: false, // Prevents a back button
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              // Success Title
              const Text(
                'Pesanan Berhasil!', // Order Successful!
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              const Text(
                'Terima kasih telah berbelanja.\nPesanan Anda sedang diproses.', // Thank you for shopping. Your order is being processed.
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              
              // --- Main Button: Go Back to Home ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to HomeScreen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()), // The const here assumes HomeScreen is a StatelessWidget or a StatefulWidget with a const constructor.
                      (route) => false, // This predicate removes all routes until the new one is the only one.
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Kembali ke Beranda', // Back to Home
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // --- Secondary Button: View Orders ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Use pushReplacementNamed to go to the orders screen, replacing the current screen
                    Navigator.pushReplacementNamed(context, '/orders');
                  },
                  child: const Text(
                    'Lihat Pesanan', // View Orders
                    style: TextStyle(fontSize: 16),
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
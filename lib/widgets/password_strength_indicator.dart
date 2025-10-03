import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  PasswordStrength _getStrength() {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    
    int strength = 0;
    
    // Check length
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    // Check for lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    
    // Check for uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    
    // Check for numbers
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    // Check for special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    
    if (strength == PasswordStrength.none) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: strength.index >= 1
                      ? strength.color
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: strength.index >= 2
                      ? strength.color
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: strength.index >= 3
                      ? strength.color
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          strength.label,
          style: TextStyle(
            fontSize: 12,
            color: strength.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (password.length < 8 || !password.contains(RegExp(r'[A-Z]')) || 
            !password.contains(RegExp(r'[0-9]')))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _getHint(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  String _getHint() {
    List<String> hints = [];
    
    if (password.length < 8) {
      hints.add('minimal 8 karakter');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      hints.add('huruf besar');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      hints.add('angka');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      hints.add('karakter spesial');
    }
    
    return 'Tambahkan: ${hints.join(', ')}';
  }
}

enum PasswordStrength {
  none('', Colors.grey),
  weak('Lemah', Colors.red),
  medium('Sedang', Colors.orange),
  strong('Kuat', Colors.green);

  final String label;
  final Color color;

  const PasswordStrength(this.label, this.color);
}
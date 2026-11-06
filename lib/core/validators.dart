import 'constants.dart';

class Validators {
  static String? email(String? v) {
    final value = (v ?? '').trim().toLowerCase();
    if (value.isEmpty) return 'Enter your email';
    final looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!looksValid) return 'Enter a valid email address';
    final domain = value.split('@').last;
    if (!allowedEmailDomains.contains(domain)) {
      return 'Use your ALU email (@${allowedEmailDomains.join(' or @')})';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return 'Enter $label';
    return null;
  }
}
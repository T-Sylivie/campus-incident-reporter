import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/core/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts an ALU student email', () {
      expect(Validators.email('a.b@alustudent.com'), isNull);
    });
    test('accepts a +tag address', () {
      expect(Validators.email('a.b+staff@alustudent.com'), isNull);
    });
    test('ignores case and surrounding spaces', () {
      expect(Validators.email('  A.B@ALUSTUDENT.COM '), isNull);
    });
    test('rejects other domains', () {
      expect(Validators.email('someone@gmail.com'), isNotNull);
    });
    test('rejects empty and malformed input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires at least 8 characters', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password(null), isNotNull);
    });
  });

  group('Validators.required', () {
    test('rejects blank values', () {
      expect(Validators.required('   ', 'your name'), isNotNull);
      expect(Validators.required('Amina', 'your name'), isNull);
    });
  });
}
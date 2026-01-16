import 'package:flutter_test/flutter_test.dart';
import 'package:link_note/core/utils.dart';

void main() {
  test('خوارزميات التشفير هل تطلع نفس النتيجة لنفس المدخلات', () {
    const input = '03746fc4-8bfa-441d-a8a2-131928dc9f57';
    final result = CipherService.encrypt(input);
    final matcher = CipherService.encrypt(input);

    expect(result, matcher);
  });
}

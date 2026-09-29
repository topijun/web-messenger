import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/features/messaging/domain/typing_label.dart';

void main() {
  test('formatTypingLabel covers one, two, and many typists', () {
    expect(formatTypingLabel(const []), isNull);
    expect(formatTypingLabel(const ['Anna']), 'Anna is typing…');
    expect(
      formatTypingLabel(const ['Mikko', 'Anna']),
      'Anna and Mikko are typing…',
    );
    expect(
      formatTypingLabel(const ['Topi', 'Anna', 'Mikko', 'Bob']),
      'Anna, Bob and 2 others are typing…',
    );
  });
}

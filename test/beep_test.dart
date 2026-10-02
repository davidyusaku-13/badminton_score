import 'package:flutter_test/flutter_test.dart';

import 'package:badminton_score/audio/beep.dart';

String chars(List<int> bytes, int offset, int length) =>
    String.fromCharCodes(bytes.sublist(offset, offset + length));

void main() {
  test('generateBeepWav produces a valid WAV header', () {
    final bytes = generateBeepWav(
      frequency: 880,
      milliseconds: 120,
      sampleRate: 44100,
    );

    expect(chars(bytes, 0, 4), 'RIFF');
    expect(chars(bytes, 8, 4), 'WAVE');
    expect(chars(bytes, 12, 4), 'fmt ');
    expect(chars(bytes, 36, 4), 'data');

    // 120ms at 44100Hz, 16-bit mono.
    const sampleCount = 44100 * 120 ~/ 1000;
    expect(bytes.length, 44 + sampleCount * 2);
  });
}

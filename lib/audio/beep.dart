import 'dart:math';
import 'dart:typed_data';

/// Generates a mono 16-bit PCM WAV beep in memory.
///
/// No asset files needed — the returned bytes can be played directly,
/// e.g. via `audioplayers` [BytesSource].
Uint8List generateBeepWav({
  double frequency = 880.0,
  int milliseconds = 120,
  int sampleRate = 44100,
  double volume = 0.5,
}) {
  assert(frequency > 0, 'frequency must be positive');
  assert(milliseconds > 0, 'milliseconds must be positive');
  assert(volume >= 0 && volume <= 1, 'volume must be between 0 and 1');

  final sampleCount = (sampleRate * milliseconds / 1000).round();
  final dataSize = sampleCount * 2; // 16-bit mono
  final buffer = ByteData(44 + dataSize);

  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      buffer.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  // RIFF header.
  writeString(0, 'RIFF');
  buffer.setUint32(4, 36 + dataSize, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little); // PCM subchunk size
  buffer.setUint16(20, 1, Endian.little); // audio format: PCM
  buffer.setUint16(22, 1, Endian.little); // mono
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  buffer.setUint16(32, 2, Endian.little); // block align
  buffer.setUint16(34, 16, Endian.little); // bits per sample
  writeString(36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  // Samples with a short fade in/out to avoid clicks.
  final fadeSamples = (sampleRate * 0.005).round().clamp(1, sampleCount ~/ 2);
  for (var i = 0; i < sampleCount; i++) {
    final envelope = i < fadeSamples
        ? i / fadeSamples
        : (i >= sampleCount - fadeSamples
              ? (sampleCount - 1 - i) / fadeSamples
              : 1.0);
    final sample =
        sin(2 * pi * frequency * i / sampleRate) * volume * envelope;
    buffer.setInt16(44 + i * 2, (sample * 32767).round(), Endian.little);
  }

  return buffer.buffer.asUint8List();
}

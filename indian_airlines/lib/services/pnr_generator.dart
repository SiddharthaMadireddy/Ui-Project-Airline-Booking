import 'dart:math';

/// Generates unambiguous 6-character alphanumeric PNR codes
class PnrGenerator {
  // Omit 0, O, 1, I to avoid human transcription confusion
  static const String _allowedChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate() {
    final Random rng = Random();
    final buffer = StringBuffer('IA'); // Start with airline prefix
    for (int i = 0; i < 4; i++) {
      final index = rng.nextInt(_allowedChars.length);
      buffer.write(_allowedChars[index]);
    }
    return buffer.toString();
  }
}

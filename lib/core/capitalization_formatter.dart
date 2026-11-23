import 'package:flutter/services.dart';

/// A [TextInputFormatter] that automatically capitalizes the first letter of the input,
/// even if typed in lowercase. Supports word-level or sentence-level capitalization.
class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  /// When true, capitalizes the first letter of every word (e.g., names, titles, cities).
  /// When false, capitalizes the first letter of each sentence/the whole input.
  final bool words;

  const CapitalizeFirstLetterFormatter({this.words = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;
    final newText = words ? _capitalizeWords(text) : _capitalizeSentences(text);

    if (newText == text) {
      return newValue;
    }

    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }

  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isLetter = char.toUpperCase() != char.toLowerCase();

      if (char == ' ' || char == '\t' || char == '\n' || char == '-' || char == '/') {
        capitalizeNext = true;
        buffer.write(char);
      } else if (isLetter) {
        if (capitalizeNext) {
          buffer.write(char.toUpperCase());
          capitalizeNext = false;
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _capitalizeSentences(String text) {
    if (text.isEmpty) return text;
    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isLetter = char.toUpperCase() != char.toLowerCase();

      if (char == '.' || char == '!' || char == '?' || char == '\n') {
        capitalizeNext = true;
        buffer.write(char);
      } else if (isLetter) {
        if (capitalizeNext) {
          buffer.write(char.toUpperCase());
          capitalizeNext = false;
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

import 'package:string_validator/string_validator.dart' as validator;

const String notFoundError = "NotFoundError";

extension StringHelper on String {
  bool isDigits() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  String firstChar() {
    return this[0];
  }

  String lastChar() {
    return this[length - 1];
  }

  /// Returns a new string containing the substring of this string up to to [count], exclusive.
  String take(int count) {
    if (count > length) {
      return this;
    }
    return substring(0, count);
  }

  static bool isLink(String? text) {
    if (text == null) {
      return false;
    }
    return (validator.isURL(text) ||
        (text.startsWith('ms-windows-store://') &&
            !text.trim().contains(' ')) ||
        (text.startsWith('mailto:') && !text.contains(' ')) &&
            text.contains('@'));
  }
}
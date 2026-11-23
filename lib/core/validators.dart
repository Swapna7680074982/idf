/// Centralized validator utility for form fields across the application.
class Validators {
  /// Regular expression for validating real, RFC-compliant email addresses.
  /// - Requires valid local part (letters, digits, and standard special characters ._%+-)
  /// - Does not allow consecutive dots (..) or leading/trailing dots in local part
  /// - Requires '@' separator
  /// - Requires valid domain part with alphanumeric labels separated by dots
  /// - Requires Top-Level Domain (TLD) with at least 2 alphabetic characters (e.g., .com, .org, .edu, .in, .io, .net)
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Checks if [email] is a strictly valid email address.
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final trimmed = email.trim();

    // Basic length constraints: e.g. "a@b.co" is 6 characters minimum
    if (trimmed.length < 6 || trimmed.length > 254) {
      return false;
    }

    // Must not contain spaces or consecutive dots
    if (trimmed.contains(' ') || trimmed.contains('..')) {
      return false;
    }

    final atIndex = trimmed.indexOf('@');
    final lastAtIndex = trimmed.lastIndexOf('@');
    // Exactly one '@' symbol
    if (atIndex <= 0 || atIndex != lastAtIndex || atIndex >= trimmed.length - 1) {
      return false;
    }

    final localPart = trimmed.substring(0, atIndex);
    final domainPart = trimmed.substring(atIndex + 1);

    // Local part constraints: minimum 1 character, cannot start or end with dot
    if (localPart.isEmpty || localPart.startsWith('.') || localPart.endsWith('.')) {
      return false;
    }

    // Domain part constraints: cannot start or end with dot or hyphen
    if (domainPart.isEmpty ||
        domainPart.startsWith('.') ||
        domainPart.endsWith('.') ||
        domainPart.startsWith('-') ||
        domainPart.endsWith('-')) {
      return false;
    }

    // Domain must contain at least one dot separating domain name and TLD
    final domainSegments = domainPart.split('.');
    if (domainSegments.length < 2) {
      return false;
    }

    // Each domain label must be non-empty and not start/end with a hyphen
    for (final segment in domainSegments) {
      if (segment.isEmpty || segment.startsWith('-') || segment.endsWith('-')) {
        return false;
      }
    }

    // TLD (the last segment) must be purely alphabetic and at least 2 characters (e.g. .com, .org, .co, .net)
    final tld = domainSegments.last;
    if (!RegExp(r'^[a-zA-Z]{2,}$').hasMatch(tld)) {
      return false;
    }

    // Domain name before TLD must have at least 1 character
    final domainName = domainSegments.sublist(0, domainSegments.length - 1).join('.');
    if (domainName.isEmpty) {
      return false;
    }

    // Overall regex match
    return emailRegex.hasMatch(trimmed);
  }

  /// FormField validator helper for email inputs.
  static String? validateEmail(
    String? value, {
    bool isRequired = true,
    String? fieldName,
    String? requiredMessage,
    String? invalidMessage,
  }) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      if (isRequired) {
        return requiredMessage ??
            (fieldName != null ? 'Please enter $fieldName' : 'Please enter your email address');
      }
      return null;
    }

    if (!isValidEmail(trimmed)) {
      return invalidMessage ??
          (fieldName != null
              ? 'Please enter a valid $fieldName (e.g. name@example.com)'
              : 'Please enter a valid email address (e.g. name@example.com)');
    }

    return null;
  }
}

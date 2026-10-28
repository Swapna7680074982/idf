class ApiConfig {
  /// Base API URL set to user's server IP
  static String baseUrl = 'https://apps.hhclservices.com/mdrf_activate';

  /// Helper to safely resolve media & file URLs whether relative or absolute
  static String resolveMediaUrl(String? path) {
    return resolveImageUrl(path) ?? '';
  }

  // System & Health
  static String get health => '$baseUrl/health';

  // Metadata & Lookups
  static String get orgTypes => '$baseUrl/api/meta/organization-types';
  static String get programTypes => '$baseUrl/api/meta/program-types';
  static String get countries => '$baseUrl/api/meta/countries';
  static String get regions => '$baseUrl/api/meta/regions';
  static String get cities => '$baseUrl/api/meta/cities';
  static String get legal => '$baseUrl/api/meta/legal';

  // Authentication & Account Lifecycle
  static String get registerStart => '$baseUrl/api/auth/register/start';
  static String get registerVerifyEmail => '$baseUrl/api/auth/register/verify-email';
  static String get resendCode => '$baseUrl/api/auth/resend-code';
  static String get registerChangeEmail => '$baseUrl/api/auth/register/change-email';
  static String get registerComplete => '$baseUrl/api/auth/register/complete';
  static String get login => '$baseUrl/api/auth/login';
  static String get adminLogin => '$baseUrl/api/auth/admin/login';
  static String get refresh => '$baseUrl/api/auth/refresh';
  static String get logout => '$baseUrl/api/auth/logout';
  static String get logoutAll => '$baseUrl/api/auth/logout-all';
  static String get me => '$baseUrl/api/auth/me';
  static String get changePassword => '$baseUrl/api/auth/change-password';
  static String get forgotPassword => '$baseUrl/api/auth/forgot-password';
  static String get verifyResetCode => '$baseUrl/api/auth/verify-reset-code';
  static String get resetPassword => '$baseUrl/api/auth/reset-password';

  // 04. Home Dashboard
  static String get home => '$baseUrl/api/home';

  // 05. Account & Profile Management
  static String get account => '$baseUrl/api/account';
  static String get accountProfile => '$baseUrl/api/account/profile';
  static String get accountPhoto => '$baseUrl/api/account/profile/photo';
  static String get accountOrganization => '$baseUrl/api/account/organization';
  static String get accountSettings => '$baseUrl/api/account/settings';

  // 06. Programs
  static String get programs => '$baseUrl/api/programs';
  static String get programBanner => '$baseUrl/api/programs/banner';
  static String get programsRegistered => '$baseUrl/api/programs/registered';
  static String programDetail(dynamic id) => '$baseUrl/api/programs/$id';
  static String programRegister(dynamic id) => '$baseUrl/api/programs/$id/register';
  static String programAiValidation(dynamic id) => '$baseUrl/api/programs/$id/ai-validation';
  static String programAiValidationV1(dynamic id) => '$baseUrl/api/v1/programs/$id/ai-validation';
  static String programReview(dynamic id) => '$baseUrl/api/programs/$id/review';
  static String programReviewV1(dynamic id) => '$baseUrl/api/v1/programs/$id/review';

  // 07. Program Applications
  static String get applicationsPrograms => '$baseUrl/api/applications/programs';
  static String applicationProgramDetail(dynamic id) => '$baseUrl/api/applications/programs/$id';

  // 08. Certification
  static String get certificationCategories => '$baseUrl/api/certification/categories';
  static String get certificationCategoryConfig => '$baseUrl/api/certification/categories/config';
  static String get certificationApplications => '$baseUrl/api/certification/applications';
  static String get certificationApplicationsSubmit => '$baseUrl/api/certification/applications/submit';
  static String get applicationsCertificates => '$baseUrl/api/applications/certificates';
  static String certificationApplication(dynamic id) => '$baseUrl/api/certification/applications/$id';
  static String certificationApplicationSubmit(dynamic id) => '$baseUrl/api/certification/applications/$id/submit';
  static String certificationApplicationDetail(dynamic id) => '$baseUrl/api/applications/certificates/$id';
  static String certificationApplicationDetailAlt(dynamic id) => '$baseUrl/api/certification/applications/$id';
  static String certificationAiValidation(dynamic id) => '$baseUrl/api/certification/applications/$id/ai-validation';
  static String certificationAiValidationAlt(dynamic id) => '$baseUrl/api/applications/certificates/$id/ai-validation';
  static String certificateRenew(dynamic id) => '$baseUrl/api/certification/certificates/$id/renew';
  static String certificateRenewAlt(dynamic id) => '$baseUrl/api/applications/certificates/$id/renew';

  // 10. Support & Tickets
  static String get supportIssueTypes => '$baseUrl/api/support/issue-types';
  static String get supportTickets => '$baseUrl/api/support/tickets';

  // 11. Notifications
  static String get notifications => '$baseUrl/api/notifications';
  static String get notificationsUnreadCount => '$baseUrl/api/notifications/unread-count';
  static String notificationRead(int id) => '$baseUrl/api/notifications/$id/read';
  static String get notificationsReadAll => '$baseUrl/api/notifications/read-all';
  static String get notificationsFcmToken => '$baseUrl/api/notifications/fcm-token';
  static String get notificationsPushToken => '$baseUrl/api/notifications/push-token';

  // 12. File Uploads
  static String get files => '$baseUrl/api/files';

  /// Extracts the first valid non-empty banner/cover image URL from a Map or dynamic data.
  /// Safely handles empty strings "", nested maps (program_information, event_details, etc.) and all key aliases.
  static String? extractBannerUrl(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final s = data.trim();
      return (s.isNotEmpty && s != 'null' && !s.contains('{{') && !s.contains('}}')) ? s : null;
    }
    if (data is! Map) return null;

    const directKeys = [
      'banner_image_url',
      'cover_image_url',
      'banner',
      'banner_url',
      'cover_image',
      'cover_url',
      'image_url',
      'image',
      'photo',
      'file_url',
      'file_path',
      'url',
    ];

    for (final key in directKeys) {
      final val = data[key]?.toString().trim();
      if (val != null && val.isNotEmpty && val != 'null' && !val.contains('{{') && !val.contains('}}')) {
        return val;
      }
    }

    const nestedKeys = [
      'program_information',
      'event_details',
      'program',
      'program_details',
      'submission_details',
      'application',
      'data',
    ];

    for (final nestedKey in nestedKeys) {
      final nested = data[nestedKey];
      if (nested is Map) {
        final found = extractBannerUrl(nested);
        if (found != null && found.isNotEmpty) {
          return found;
        }
      }
    }

    return null;
  }

  /// Resolves relative or localhost image/file URLs to full absolute URLs using [baseUrl].
  /// Converts any localhost/127.0.0.1/10.0.2.2/private IP paths to the live [baseUrl].
  static String? resolveImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;

    if (trimmed.contains('{{') || trimmed.contains('}}')) {
      return null;
    }

    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final baseUri = Uri.tryParse(cleanBase);
    final String basePath = (baseUri != null && baseUri.path.isNotEmpty && baseUri.path != '/')
        ? (baseUri.path.endsWith('/') ? baseUri.path.substring(0, baseUri.path.length - 1) : baseUri.path)
        : '';
    final String baseHost = baseUri?.host ?? 'apps.hhclservices.com';

    // Normalize slashes (replace Windows backslashes with forward slashes)
    String normalized = trimmed.replaceAll(r'\', '/');

    // Automatically remove double path prefix if present anywhere (e.g. /mdrf_activate/mdrf_activate/ -> /mdrf_activate/ or /idf/idf/ -> /idf/)
    if (basePath.isNotEmpty) {
      final doublePrefix = '$basePath$basePath';
      while (normalized.contains(doublePrefix)) {
        normalized = normalized.replaceAll(doublePrefix, basePath);
      }
    }
    while (normalized.contains('/idf/idf/')) {
      normalized = normalized.replaceAll('/idf/idf/', '/idf/');
    }

    // Pattern matching any localhost, 127.0.0.1, 0.0.0.0, 10.0.2.2, or 192.168.x.x with optional port
    final localHostRegex = RegExp(
      r'^https?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0|10\.0\.2\.2|192\.168\.\d+\.\d+)(:\d+)?',
      caseSensitive: false,
    );

    if (localHostRegex.hasMatch(normalized)) {
      normalized = normalized.replaceFirst(localHostRegex, '');
    }

    // Automatically upgrade cleartext http to https for our domain
    if (normalized.startsWith('http://$baseHost')) {
      normalized = normalized.replaceFirst('http://$baseHost', 'https://$baseHost');
    }

    // If it's a full external URL
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      final parsed = Uri.tryParse(normalized);
      if (parsed != null && (parsed.host == baseHost || parsed.host.contains('hhclservices.com'))) {
        // Same domain: Ensure basePath is present once and never duplicated
        var path = parsed.path;
        if (basePath.isNotEmpty) {
          // Remove old '/idf' if basePath is now '/mdrf_activate'
          if (basePath != '/idf' && path.startsWith('/idf/')) {
            path = path.substring(4);
          }
          // Avoid duplicate basePath in path (e.g. /mdrf_activate/mdrf_activate/...)
          final doublePath = '$basePath$basePath';
          while (path.startsWith(doublePath)) {
            path = path.substring(basePath.length);
          }
          // Ensure path starts with basePath
          if (!path.startsWith('$basePath/') && path != basePath) {
            path = '$basePath${path.startsWith('/') ? path : '/$path'}';
          }
        }
        final query = parsed.hasQuery ? '?${parsed.query}' : '';
        final res = '${parsed.origin}$path$query';
        return res.contains(' ') ? Uri.encodeFull(res) : res;
      } else {
        // Third-party external URL (e.g. AWS S3, Cloudinary)
        return normalized.contains(' ') ? Uri.encodeFull(normalized) : normalized;
      }
    }

    // It's a relative path:
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    // Replace old /idf/ if basePath is /mdrf_activate
    if (basePath.isNotEmpty && basePath != '/idf' && normalized.startsWith('/idf/')) {
      normalized = normalized.substring(4);
    }

    // Avoid duplicate basePath if cleanBase already has it and normalized starts with it
    if (basePath.isNotEmpty) {
      final doublePath = '$basePath$basePath';
      while (normalized.startsWith(doublePath)) {
        normalized = normalized.substring(basePath.length);
      }
      if (normalized.startsWith('$basePath/')) {
        normalized = normalized.substring(basePath.length);
      }
    }

    final fullUrl = '$cleanBase$normalized';
    return fullUrl.contains(' ') ? Uri.encodeFull(fullUrl) : fullUrl;
  }
}

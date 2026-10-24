class ApiConfig {
  /// Base API URL set to user's server IP
  static String baseUrl = 'https://apps.hhclservices.com/idf';

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

  // 10. Support & Tickets
  static String get supportIssueTypes => '$baseUrl/api/support/issue-types';
  static String get supportTickets => '$baseUrl/api/support/tickets';

  // 11. Notifications
  static String get notifications => '$baseUrl/api/notifications';
  static String get notificationsUnreadCount => '$baseUrl/api/notifications/unread-count';
  static String notificationRead(int id) => '$baseUrl/api/notifications/$id/read';
  static String get notificationsReadAll => '$baseUrl/api/notifications/read-all';

  // 12. File Uploads
  static String get files => '$baseUrl/api/files';

  /// Resolves relative or localhost image/file URLs to full absolute URLs using [baseUrl].
  /// Converts any localhost/127.0.0.1/10.0.2.2/private IP paths to the live [baseUrl].
  static String? resolveImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.contains('{{') || trimmed.contains('}}')) {
      return null;
    }

    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Pattern matching any localhost, 127.0.0.1, 0.0.0.0, 10.0.2.2, or 192.168.x.x with optional port
    final localHostRegex = RegExp(
      r'^https?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0|10\.0\.2\.2|192\.168\.\d+\.\d+)(:\d+)?',
      caseSensitive: false,
    );

    String normalized = trimmed;

    if (localHostRegex.hasMatch(normalized)) {
      normalized = normalized.replaceFirst(localHostRegex, '');
    }

    // If it's still a full external URL (e.g. AWS S3, Cloudinary, Unsplash), keep it
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      if (normalized.contains('localhost') || normalized.contains('127.0.0.1')) {
        final uri = Uri.tryParse(normalized);
        if (uri != null) {
          normalized = uri.path + (uri.hasQuery ? '?${uri.query}' : '');
        }
      } else {
        return normalized;
      }
    }

    // Ensure normalized starts with '/'
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    // Avoid duplicate /idf/ prefix if cleanBase already ends with /idf and normalized starts with /idf/
    if (cleanBase.endsWith('/idf') && normalized.startsWith('/idf/')) {
      normalized = normalized.substring(4);
    }

    return '$cleanBase$normalized';
  }
}

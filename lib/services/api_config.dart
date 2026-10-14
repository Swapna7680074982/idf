class ApiConfig {
  /// Base API URL set to user's server IP
  static String baseUrl = 'http://192.168.215.232:4000';

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

  // 07. Program Applications
  static String get applicationsPrograms => '$baseUrl/api/applications/programs';
  static String applicationProgramDetail(dynamic id) => '$baseUrl/api/applications/programs/$id';

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

  /// Resolves relative image/file URLs (e.g., /uploads/xyz.jpg) to full absolute URLs
  static String? resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }
}

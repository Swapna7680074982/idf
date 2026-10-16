class DateTimeUtils {
  /// Formats time string (e.g. '09:00', '14:30', '14:30:00', '09:00:00') into 12-hour format with minutes and AM/PM (e.g. '09:00 AM', '02:30 PM')
  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    final trimmed = timeStr.trim();

    // Already formatted with AM or PM
    if (trimmed.toUpperCase().contains('AM') || trimmed.toUpperCase().contains('PM')) {
      return trimmed;
    }

    // Full DateTime string (e.g. '2026-10-16 14:30:00' or ISO)
    if (trimmed.contains('-') && (trimmed.contains('T') || trimmed.contains(' '))) {
      final dt = DateTime.tryParse(trimmed.replaceAll(' ', 'T'));
      if (dt != null) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';
        return '${hour.toString().padLeft(2, '0')}:$minute $amPm';
      }
    }

    // HH:MM or HH:MM:SS
    final parts = trimmed.split(':');
    if (parts.isNotEmpty) {
      final hourInt = int.tryParse(parts[0]);
      if (hourInt != null) {
        final minuteInt = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        final hour12 = hourInt % 12 == 0 ? 12 : hourInt % 12;
        final minuteStr = minuteInt.toString().padLeft(2, '0');
        final amPm = hourInt >= 12 ? 'PM' : 'AM';
        return '${hour12.toString().padLeft(2, '0')}:$minuteStr $amPm';
      }
    }

    return trimmed;
  }

  /// Formats date and optional time (e.g. '2026-10-16' -> '16 Oct 2026', '2026-10-16 14:30:00' -> '16 Oct 2026, 02:30 PM')
  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    final trimmed = dateStr.trim();
    try {
      final dt = DateTime.tryParse(trimmed.replaceAll(' ', 'T'));
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final day = dt.day.toString().padLeft(2, '0');
        final month = months[dt.month - 1];
        final year = dt.year.toString();

        if (trimmed.contains(':')) {
          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'PM' : 'AM';
          return '$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $amPm';
        }
        return '$day $month $year';
      }
    } catch (_) {}
    return trimmed;
  }

  /// Formats a date range cleanly (e.g. '16 Oct 2026 - 18 Oct 2026' or just '16 Oct 2026')
  static String formatDateRange(String? start, String? end) {
    if ((start == null || start.trim().isEmpty) && (end == null || end.trim().isEmpty)) {
      return '—';
    }
    final s = formatDateTime(start);
    final e = formatDateTime(end);
    if (s.isEmpty || s == '—') return e;
    if (e.isEmpty || e == '—' || s == e) return s;
    return '$s - $e';
  }

  /// Formats date for program cards matching the design (e.g. '2025-11-14' or '2026-10-29 to 2026-10-31')
  static String formatCardDate(String? start, String? end) {
    String cleanDate(String? d) {
      if (d == null || d.trim().isEmpty) return '';
      final t = d.trim();
      final dt = DateTime.tryParse(t.replaceAll(' ', 'T'));
      if (dt != null) {
        final year = dt.year.toString();
        final month = dt.month.toString().padLeft(2, '0');
        final day = dt.day.toString().padLeft(2, '0');
        return '$year-$month-$day';
      }
      return t.split(' ').first;
    }

    final s = cleanDate(start);
    final e = cleanDate(end);
    if (s.isEmpty) return e.isNotEmpty ? e : '—';
    if (e.isEmpty || s == e) return s;
    return '$s to $e';
  }
}

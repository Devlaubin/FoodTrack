/// Small formatting helpers shared across the app.
class Formatters {
  Formatters._();

  /// Formats a date as a French-style "month year", e.g. "mars 2024".
  static String monthYear(DateTime date) {
    const months = [
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Formats a rating number always with 1 decimal, e.g. 4.5 -> "4,5".
  static String rating(double rating) {
    return rating.toStringAsFixed(1).replaceAll('.', ',');
  }

  /// Cleans up a social handle / url: strips leading @ and whitespace.
  static String cleanHandle(String value) {
    return value.trim().replaceAll('@', '');
  }
}


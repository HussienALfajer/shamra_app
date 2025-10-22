/////////////////////////////////////////////////////////////////////////////
// lib/core/helpers/currency_helper.dart
// Single source of truth for currency display (symbol/name/formatting).
// EN comments only.

enum CurrencyPlacement { prefix, suffix }

class CurrencyHelper {
  // Accepted currency codes are 3-letter ISO (upper/lower safe).
  static const String _defaultCode = 'USD';

  // Symbols used by UI.
  static const Map<String, String> _symbols = {
    'USD': '\$',
    'SYP': 'SYP',
    'EUR': '€',
    'TRY': '₺',
  };

  // Arabic display names.
  static const Map<String, String> _namesAr = {
    'USD': 'دولار',
    'SYP': 'ليرة سورية',
    'EUR': 'يورو',
    'TRY': 'ليرة تركية',
  };

  // English display names (optional).
  static const Map<String, String> _namesEn = {
    'USD': 'Dollar',
    'SYP': 'Syrian Pound',
    'EUR': 'Euro',
    'TRY': 'Turkish Lira',
  };

  /// Returns a normalized uppercase currency code, or the default code.
  static String _normalized(String? code) =>
      (code?.trim().isNotEmpty == true) ? code!.toUpperCase() : _defaultCode;

  /// Get currency symbol for a given code. Falls back to default.
  static String symbol([String? code]) {
    final key = _normalized(code);
    return _symbols[key] ?? _symbols[_defaultCode]!;
  }

  /// Get currency display name in Arabic.
  static String nameAr([String? code]) {
    final key = _normalized(code);
    return _namesAr[key] ?? _namesAr[_defaultCode]!;
  }

  /// Get currency display name in English.
  static String nameEn([String? code]) {
    final key = _normalized(code);
    return _namesEn[key] ?? _namesEn[_defaultCode]!;
  }

  /// Format a number like "1200" -> "1200" or "12.50" -> "12.5".
  static String formatNumber(num? value) {
    if (value == null) return '0';
    final v = value.toDouble();
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    final s = v.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Build a UI string: "12.5 $" (suffix, default) or "$ 12.5" (prefix).
  static String formatAmount(
      num? amount, {
        String? code,
        CurrencyPlacement placement = CurrencyPlacement.suffix,
      }) {
    final text = formatNumber(amount);
    final unit = symbol(code);
    return placement == CurrencyPlacement.prefix ? '$unit $text' : '$text $unit';
  }
}

/// Lightweight extensions for convenient usage in widgets/models.
extension CurrencyStringX on String? {
  String get currencySymbol => CurrencyHelper.symbol(this);
  String get currencyNameAr => CurrencyHelper.nameAr(this);
  String get currencyNameEn => CurrencyHelper.nameEn(this);
}

extension CurrencyNumFormatX on num? {
  String asCurrency({String? code, CurrencyPlacement placement = CurrencyPlacement.suffix}) =>
      CurrencyHelper.formatAmount(this, code: code, placement: placement);
}

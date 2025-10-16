import 'dart:core';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as pnp;

/// Phone normalization helpers (International via phone_numbers_parser).
class PhoneUtils {
  /// Convert Arabic/Persian numerals to Western digits.
  static String _toWesternDigits(String input) {
    const map = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
    };
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  static String _onlyDigits(String s) => s.replaceAll(RegExp(r'\D'), '');

  /// Build E.164 string from parser object.
  static String _toE164(pnp.PhoneNumber p) => '+${p.countryCode}${p.nsn}';

  /// Basic E.164 validity: + then 7..15 digits (ITU-T).
  static bool isValidE164(String e164) {
    return RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(e164);
  }

  static pnp.IsoCode? _isoFromAlpha2(String? alpha2) {
    if (alpha2 == null || alpha2.isEmpty) return null;
    try {
      return pnp.IsoCode.values.firstWhere(
            (e) => e.name.toUpperCase() == alpha2.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Normalize free-text to E.164 using optional defaults.
  /// - If input has '+', parse directly.
  /// - Else try [defaultIso2] (e.g., 'SY','US','DE'); if not, fallback to [defaultCountryDialCode].
  static String normalizeToE164(
      String input, {
        String defaultCountryDialCode = '+963',
        String? defaultIso2,
      }) {
    final raw = _toWesternDigits(input).trim();
    if (raw.isEmpty) return '';

    // 1) Try full international first
    try {
      final parsed = pnp.PhoneNumber.parse(raw);
      final e164 = _toE164(parsed);
      return isValidE164(e164) ? e164 : '';
    } catch (_) {}

    // 2) Try with ISO (national input)
    final iso = _isoFromAlpha2(defaultIso2);
    if (iso != null) {
      try {
        final parsed = pnp.PhoneNumber.parse(raw, destinationCountry: iso);
        final e164 = _toE164(parsed);
        return isValidE164(e164) ? e164 : '';
      } catch (_) {}
    }

    // 3) Fallback: prepend default CC and parse
    var nsn = _onlyDigits(raw);
    if (nsn.startsWith('0')) nsn = nsn.substring(1);
    final cc = defaultCountryDialCode.startsWith('+')
        ? defaultCountryDialCode
        : '+$defaultCountryDialCode';

    final tentative = '$cc$nsn';
    try {
      final parsed = pnp.PhoneNumber.parse(tentative);
      final e164 = _toE164(parsed);
      return isValidE164(e164) ? e164 : '';
    } catch (_) {
      return '';
    }
  }

  /// Build E.164 from IntlPhoneField parts (recommended in UI).
  /// - [countryDialCode]: like "+963" or "963"
  /// - [countryIso2]: like "SY", "DE", "US"
  /// - [national]: user-typed national number
  static String normalizeIntlParts({
    required String countryDialCode,
    required String national,
    String? countryIso2,
  }) {
    final iso = _isoFromAlpha2(countryIso2);
    final cleanNational = _onlyDigits(_toWesternDigits(national));

    if (iso != null) {
      try {
        final parsed =
        pnp.PhoneNumber.parse(cleanNational, destinationCountry: iso);
        final e164 = _toE164(parsed);
        return isValidE164(e164) ? e164 : '';
      } catch (_) {}
    }

    final cc =
    countryDialCode.startsWith('+') ? countryDialCode : '+$countryDialCode';
    final tentative = '$cc$cleanNational';
    try {
      final parsed = pnp.PhoneNumber.parse(tentative);
      final e164 = _toE164(parsed);
      return isValidE164(e164) ? e164 : '';
    } catch (_) {
      return '';
    }
  }
}

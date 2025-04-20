import 'package:diacritic/diacritic.dart';

import '../package_localizer.dart';
import 'info_with_link.dart';
import 'package_attribute.dart';

class Publisher {
  final String? id;

  /// The name as provided by the manifest file.
  final String? fullName;

  /// The id but with spaces and dots, or if [id] is null, the name of the publisher.
  final String? nameFittingId;
  final Uri? icon;
  final Uri? website;

  Publisher({
    this.id,
    this.fullName,
    this.nameFittingId,
    this.icon,
    this.website,
  });

  /// Title under which the publisher is displayed, is not the publisher name.
  String title(PackageLocalizer locale) =>
      PackageAttribute.publisher.title(locale);

  InfoWithLink? get infoWithLink {
    if (fullName == null && website == null) {
      return null;
    }
    return InfoWithLink(
      title: title,
      text: fullName,
      url: website,
    );
  }

  /// Canonicalizes a string so it could match a publisher id.
  /// Removes all spaces, dots and commas and convert to lowercase.
  /// [customDiacritics] if true, use custom diacritics, like ä -> ae.
  static String canonicalize(String string, {bool customDiacritics = false}) {
    if (customDiacritics) {
      string = _replaceDiacriticsWithCustom(string);
    }
    string = removeDiacritics(string);
    return string.replaceAll(RegExp(r"[\s.,\-&'´’!?\\/|()]"), '').toLowerCase();
  }

  static String _replaceDiacriticsWithCustom(String string) {
    return string.replaceAllMapped(RegExp(r'[äöüÄÖÜ]'), (match) {
      return switch (match.group(0)!) {
        'ä' => 'ae',
        'ö' => 'oe',
        'ü' => 'ue',
        'Ä' => 'ae',
        'Ö' => 'oe',
        'Ü' => 'ue',
        _ => match.group(0)!
      };
    });
  }
}

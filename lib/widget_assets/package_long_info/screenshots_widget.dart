import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

import 'expander_compartment.dart';

class ScreenshotsWidget extends ExpanderCompartment {
  final PackageScreenshots screenshots;
  const ScreenshotsWidget(this.screenshots, {super.key});

  @override
  final IconData titleIcon = FluentIcons.desktop_screenshot;

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;

    List<ImageProvider> imageProviders = screenshots.screenshots
            ?.map((Uri uri) => NetworkImage(uri.toString(), scale: 1))
            .toList() ??
        [];

    return fullCompartment(
      context: context,
      title: compartmentTitle(locale),
      mainColumn: [
        LayoutBuilder(builder: (context, constraints) {
          return GalleryImageView(
            boxFit: BoxFit.scaleDown,
            listImage: imageProviders,
            width: constraints.maxWidth,
            height: 200,
            galleryType: 1,
          );
        }),
      ],
    );
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return "Screenshots";
  }

  @override
  EdgeInsetsGeometry get bodyPadding =>
      const EdgeInsets.symmetric(horizontal: 0);
}

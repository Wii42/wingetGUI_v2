import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/buttons/abstract_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/route_parameter.dart';
import '../../routes.dart';
import 'normal_button.dart';

class PageButton extends NormalButton
    with TextButtonMixin, PlainButtonMixin, CustomToolTipMixin, PushPageMixin {
  @override
  final Routes pageRoute;
  @override
  final String buttonText;
  @override
  final String Function(AppLocalizations) tooltipMessage;
  @override
  final RouteParameter? routeParameter;
  PageButton({
    super.key,
    required this.pageRoute,
    required this.buttonText,
    required this.tooltipMessage,
    this.routeParameter,
  });
}

class PageIconButton extends NormalButton
    with IconButtonMixin, CustomToolTipMixin, PushPageMixin {
  @override
  final Routes pageRoute;
  @override
  final IconData icon;
  @override
  final EdgeInsetsGeometry padding;
  @override
  final String Function(AppLocalizations) tooltipMessage;
  @override
  final RouteParameter? routeParameter;
  PageIconButton({
    super.key,
    required this.pageRoute,
    required this.icon,
    this.padding = EdgeInsets.zero,
    required this.tooltipMessage,
    this.routeParameter,
  });
}

class CustomPageButton extends NormalButton
    with PlainButtonMixin, CustomToolTipMixin, PushPageMixin {
  @override
  final Widget child;
  @override
  final Routes pageRoute;
  @override
  final String Function(AppLocalizations) tooltipMessage;
  @override
  final RouteParameter? routeParameter;
  @override
  final bool useMousePosition;
  CustomPageButton({
    super.key,
    required this.pageRoute,
    required this.tooltipMessage,
    required this.child,
    this.routeParameter,
    super.disabled,
    this.useMousePosition = false,
  });
}

mixin PushPageMixin on NormalButton {
  @override
  void onPressed(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    navigator.pushNamed(pageRoute.route, arguments: routeParameter);
  }

  Routes get pageRoute;
  RouteParameter? get routeParameter;
}

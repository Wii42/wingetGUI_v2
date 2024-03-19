import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/buttons/abstract_button.dart';
import 'package:winget_gui/widget_assets/buttons/run_button.dart';
import 'package:winget_gui/widget_assets/buttons/tooltips.dart';

import '../../helpers/route_parameter.dart';
import '../../routes.dart';
import 'normal_button.dart';

class PageButton extends NormalButton with TextButtonMixin, PlainButtonMixin, CustomToolTipMixin {
  final Routes pageRoute;
  @override
  final String buttonText;
  @override
  final String tooltipMessage;
  final RouteParameter? routeParameter;
  PageButton({
    super.key,
    required this.pageRoute,
    required this.buttonText,
    this.tooltipMessage = 'Open page',
    this.routeParameter,
  });

  @override
  void onPressed(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    navigator.pushNamed(pageRoute.route, arguments: routeParameter);
  }
}

import 'package:fluent_ui/fluent_ui.dart';

class CustomInfoBar extends InfoBar {
  final bool isSmallHeight;
  const CustomInfoBar(
      {required super.title,
      super.key,
      super.content,
      super.action,
      super.severity,
      super.style,
      super.isLong,
      super.onClose,
      super.isIconVisible,
      this.isSmallHeight = false});

  CustomInfoBar copyWith({
    Widget? title,
    Widget? content,
    Widget? action,
    InfoBarSeverity? severity,
    InfoBarThemeData? style,
    bool? isLong,
    VoidCallback? onClose,
    bool? isIconVisible,
    bool? isSmallHeight,
  }) {
    return CustomInfoBar(
      title: title ?? this.title,
      content: content ?? this.content,
      action: action ?? this.action,
      severity: severity ?? this.severity,
      style: style ?? this.style,
      isLong: isLong ?? this.isLong,
      onClose: onClose ?? this.onClose,
      isIconVisible: isIconVisible ?? this.isIconVisible,
      isSmallHeight: isSmallHeight ?? this.isSmallHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    assert(debugCheckHasFluentLocalizations(context));

    final theme = FluentTheme.of(context);
    final localizations = FluentLocalizations.of(context);
    final style = InfoBarTheme.of(context).merge(this.style);

    final icon = isIconVisible ? style.icon?.call(severity) : null;
    final closeIcon = style.closeIcon;
    final title = Padding(
      padding: const EdgeInsetsDirectional.only(end: 6.0),
      child: DefaultTextStyle.merge(
        style: theme.typography.bodyStrong ?? const TextStyle(),
        child: this.title,
      ),
    );
    final content = () {
      if (this.content == null) return null;
      return DefaultTextStyle.merge(
        style: theme.typography.body ?? const TextStyle(),
        child: this.content!,
      );
    }();
    final action = () {
      if (this.action == null) return null;
      return ButtonTheme.merge(
        child: this.action!,
        data: ButtonThemeData.all(style.actionStyle),
      );
    }();
    return Container(
      constraints: isSmallHeight ? null : const BoxConstraints(minHeight: 48.0),
      decoration: style.decoration?.call(severity),
      padding: style.padding ??
          (isSmallHeight
              ? const EdgeInsets.symmetric(horizontal: 10)
              : const EdgeInsets.all(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isLong ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14.0),
              child: Icon(icon, color: style.iconColor?.call(severity)),
            ),
          if (isLong)
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (content != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: isSmallHeight? 0: 6.0),
                      child: content,
                    ),
                  if (action != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top:isSmallHeight? 0: 12.0),
                      child: action,
                    ),
                ],
              ),
            )
          else
            Flexible(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  title,
                  if (content != null) content,
                  if (action != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16.0),
                      child: action,
                    ),
                ],
              ),
            ),
          if (closeIcon != null && onClose != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10.0),
              child: Tooltip(
                message: localizations.closeButtonLabel,
                child: IconButton(
                  icon: Icon(closeIcon, size: style.closeIconSize),
                  onPressed: onClose,
                  style: style.closeButtonStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';

class CustomExpander extends Expander {
  static ShapeBorder _headerShape(bool _) => const RoundedRectangleBorder();

  CustomExpander({
    super.key,
    super.leading,
    required super.header,
    required super.content,
    super.animationCurve,
    super.animationDuration,
    super.direction = ExpanderDirection.down,
    super.initiallyExpanded = false,
    super.onStateChanged,
    WidgetStateProperty<Color>? headerBackgroundColor,
    super.headerShape = _headerShape,
    super.contentBackgroundColor = Colors.transparent,
    super.contentPadding = EdgeInsets.zero,
    super.contentShape,
  }) : super(
            headerBackgroundColor: headerBackgroundColor ??
                WidgetStateProperty.all(Colors.transparent));

  @override
  State<Expander> createState() => CustomExpanderState();
}

class CustomExpanderState extends State<CustomExpander>
    with SingleTickerProviderStateMixin {
  late FluentThemeData _theme;

  late bool _isExpanded;

  bool get isExpanded => _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isExpanded = PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded == true) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = FluentTheme.of(context);
  }

  void _handlePressed() {
    if (_isExpanded) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
        curve: widget.animationCurve ?? _theme.animationCurve,
      );
      _isExpanded = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
      );
      _isExpanded = true;
    }
    PageStorage.of(context).writeState(context, _isExpanded);
    widget.onStateChanged?.call(_isExpanded);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Duration expanderAnimationDuration = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final children = [
      // HEADER
      HoverButton(
        onPressed: _handlePressed,
        hitTestBehavior: HitTestBehavior.deferToChild,
        builder: (context, states) {
          return Container(
            constraints: const BoxConstraints(
              minHeight: 42.0,
            ),
            decoration: ShapeDecoration(
              color: widget.headerBackgroundColor?.resolve(states) ??
                  theme.resources.cardBackgroundFillColorDefault,
              shape: widget.headerShape?.call(_isExpanded) ??
                  RoundedRectangleBorder(
                    side: BorderSide(
                      color: theme.resources.cardStrokeColorDefault,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(6.0),
                      bottom: Radius.circular(_isExpanded ? 0.0 : 6.0),
                    ),
                  ),
            ),
            padding: EdgeInsets.zero,
            alignment: AlignmentDirectional.centerStart,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(child: widget.header),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 5),
                child: FocusBorder(
                  focused: states.isFocused,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: ButtonThemeData.uncheckedInputColor(
                        _theme,
                        states,
                        transparentWhenNone: true,
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: widget.icon ??
                        RotationTransition(
                          turns: Tween<double>(
                            begin: 0,
                            end: 0.5,
                          ).animate(CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              0.5,
                              1.0,
                              curve: widget.animationCurve ??
                                  _theme.animationCurve,
                            ),
                          )),
                          child: AnimatedSlide(
                            duration: theme.fastAnimationDuration,
                            curve: Curves.easeInCirc,
                            offset: states.isPressed
                                ? const Offset(0, 0.1)
                                : Offset.zero,
                            child: Icon(
                              _isDown
                                  ? FluentIcons.chevron_down
                                  : FluentIcons.chevron_up,
                              size: 8.0,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
      SizeTransition(
        sizeFactor: CurvedAnimation(
          curve: Interval(
            0.0,
            0.5,
            curve: widget.animationCurve ?? _theme.animationCurve,
          ),
          parent: _controller,
        ),
        child: Container(
          width: double.infinity,
          padding: widget.contentPadding,
          decoration: ShapeDecoration(
            shape: widget.contentShape?.call(_isExpanded) ??
                const RoundedRectangleBorder(),
            color: widget.contentBackgroundColor ??
                theme.resources.cardBackgroundFillColorSecondary,
          ),
          child: ExcludeFocus(
            excluding: !_isExpanded,
            child: widget.content,
          ),
        ),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}

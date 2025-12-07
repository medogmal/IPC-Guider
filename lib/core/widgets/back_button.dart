import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A standardized back button widget used across all screens
class AppBackButton extends StatelessWidget {
  final String? tooltip;
  final Color? color;
  final double? iconSize;
  final VoidCallback? onPressed;

  const AppBackButton({
    super.key,
    this.tooltip = 'Back',
    this.color,
    this.iconSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: color ?? Theme.of(context).iconTheme.color,
        size: iconSize ?? 24,
      ),
      onPressed: onPressed ?? () {
        if (context.canPop()) {
          context.pop();
        } else {
          // If can't pop, go to home screen as fallback
          context.go('/');
        }
      },
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// An AppBar that includes a standardized back button
class AppBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPress;
  final bool fitTitle;

  const AppBackAppBar({
    super.key,
    required this.title,
    this.actions,
    this.flexibleSpace,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.onBackPress,
    this.fitTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (fitTitle) {
      titleWidget = FittedBox(
        fit: BoxFit.scaleDown,
        child: titleWidget,
      );
    }

    return AppBar(
      title: titleWidget,
      leading: automaticallyImplyLeading
          ? AppBackButton(onPressed: onBackPress)
          : null,
      actions: actions,
      flexibleSpace: flexibleSpace,
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

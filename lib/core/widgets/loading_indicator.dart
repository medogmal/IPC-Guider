import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

/// Standardized loading indicator for the IPC Guider app
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: CircularProgressIndicator(
              color: color ?? AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A shimmer loading effect for lists
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final double? height;
  final double? width;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.height,
    this.width,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    )).addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A shimmer effect widget for placeholder content
class ShimmerPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.neutralLighter,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// A shimmer effect for list items
class ShimmerListItem extends StatelessWidget {
  final int index;

  const ShimmerListItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerPlaceholder(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                const ShimmerPlaceholder(
                  height: 14,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                const ShimmerPlaceholder(
                  height: 14,
                  width: 200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

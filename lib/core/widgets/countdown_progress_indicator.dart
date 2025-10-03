import 'package:flutter/material.dart';

/// A countdown progress bar that depletes from full to empty over the
/// provided [durationInSeconds].
///
/// Optional [onCompleted] callback fires once when the countdown reaches
/// zero.
class CountdownProgressIndicator extends StatefulWidget {
  const CountdownProgressIndicator({
    super.key,
    required this.durationInSeconds,
    this.onCompleted,
    this.backgroundColor,
    this.color,
    this.minHeight,
  }) : assert(
         durationInSeconds > 0,
         'durationInSeconds must be greater than zero',
       );

  /// Total countdown duration in seconds.
  final int durationInSeconds;

  /// Invoked once when the countdown reaches zero.
  final VoidCallback? onCompleted;

  /// Overrides the indicator background color when provided.
  final Color? backgroundColor;

  /// Overrides the indicator color when provided.
  final Color? color;

  /// Overrides the indicator minimum height when provided.
  final double? minHeight;

  @override
  State<CountdownProgressIndicator> createState() =>
      _CountdownProgressIndicatorState();
}

class _CountdownProgressIndicatorState extends State<CountdownProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _didNotifyCompletion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    )..addStatusListener(_handleStatusChange);

    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(CountdownProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationInSeconds != widget.durationInSeconds) {
      _controller
        ..duration = Duration(seconds: widget.durationInSeconds)
        ..reset()
        ..forward(from: 0);
      _didNotifyCompletion = false;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatusChange)
      ..dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_didNotifyCompletion) {
      _didNotifyCompletion = true;
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LinearProgressIndicator(
          value: 1 - _controller.value,
          minHeight: 8,
          backgroundColor: Colors.grey.shade800,
          color: Colors.green,
        );
      },
    );
  }
}

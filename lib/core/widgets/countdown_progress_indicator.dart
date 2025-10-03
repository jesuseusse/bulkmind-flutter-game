import 'package:flutter/material.dart';

/// A countdown progress bar that depletes from full to empty over the
/// provided [duration].
///
/// Optional [onCompleted] callback fires once when the countdown reaches
/// zero.
class CountdownProgressIndicator extends StatefulWidget {
  const CountdownProgressIndicator({
    super.key,
    required this.duration,
    this.onCompleted,
    this.backgroundColor,
    this.color,
    this.minHeight,
  });

  /// Total countdown duration in seconds.
  final Duration duration;

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
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener(_handleStatusChange);

    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(CountdownProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
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

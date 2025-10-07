import 'dart:async';

import 'package:flutter/widgets.dart';

/// Displays [child] for the provided [duration] before collapsing to an empty box.
///
/// When you need to re-show the content (similar to showing a new Snackbar),
/// rebuild the widget with a different [Widget.key] on [child] to restart the timer.
class TimedDisplay extends StatefulWidget {
  const TimedDisplay({
    super.key,
    required this.duration,
    required this.child,
  });

  /// How long the [child] remains visible before being dismissed.
  final Duration duration;

  /// The content that will be shown temporarily.
  final Widget child;

  @override
  State<TimedDisplay> createState() => _TimedDisplayState();
}

class _TimedDisplayState extends State<TimedDisplay> {
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _showAndStartTimer();
  }

  @override
  void didUpdateWidget(TimedDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final durationChanged = widget.duration != oldWidget.duration;
    final childKeyChanged = widget.child.key != oldWidget.child.key;
    final childChangedWhileHidden =
        !_visible && widget.child != oldWidget.child;

    if (durationChanged || childKeyChanged || childChangedWhileHidden) {
      _showAndStartTimer();
    }
  }

  void _showAndStartTimer() {
    _timer?.cancel();
    if (!_visible) {
      setState(() => _visible = true);
    }
    _timer = Timer(widget.duration, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}

import 'package:flutter/material.dart';

class AnswerFeedbackIcon extends StatefulWidget {
  final bool isVisible;
  final bool isCorrect;

  const AnswerFeedbackIcon({
    super.key,
    required this.isVisible,
    required this.isCorrect,
  });

  @override
  State<AnswerFeedbackIcon> createState() => _AnswerFeedbackIconState();
}

class _AnswerFeedbackIconState extends State<AnswerFeedbackIcon> {
  // No AnimationController needed
  // No explicit state for opacity/scale

  @override
  void didUpdateWidget(covariant AnswerFeedbackIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If it just became visible, we'll set a timer to hide it after 0.5 seconds.
    // This assumes the parent sets isVisible to true, and then this widget
    // handles the auto-hide.
    if (widget.isVisible && !oldWidget.isVisible) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // This setState is to trigger a rebuild to hide the icon.
          // The parent (StreamBuilder) will then eventually provide isVisible: false.
          // For a simple show/hide, it's cleaner to let the parent handle the hide signal.
          // So, we don't need internal state here to hide it.
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We only render the icon if isVisible is true.
    if (widget.isVisible) {
      if (widget.isCorrect) {
        return const Text(
          '✅', // We are only using this for correct answers feedback
          style: TextStyle(fontSize: 48),
        );
      } else {
        return const Text(
          'X', // We are only using this for correct answers feedback
          style: TextStyle(fontSize: 48),
        );
      }
    } else {
      return const Text(
        '', // We are only using this for correct answers feedback
        style: TextStyle(fontSize: 48),
      ); // Render nothing if not visible
    }
  }
}

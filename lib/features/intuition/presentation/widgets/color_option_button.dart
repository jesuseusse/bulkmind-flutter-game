import 'package:flutter/material.dart';

class ColorOptionButton extends StatefulWidget {
  final Color color;
  final bool isCorrect;
  final VoidCallback onFinished;

  const ColorOptionButton({
    super.key,
    required this.color,
    required this.isCorrect,
    required this.onFinished,
  });

  @override
  State<ColorOptionButton> createState() => _ColorOptionButtonState();
}

class _ColorOptionButtonState extends State<ColorOptionButton> {
  Color? _overlay;
  bool _isPressed = false; // Renamed for clarity

  @override
  void didUpdateWidget(covariant ColorOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reset state if the *identity* of the button changes (its color or correctness).
    // This prevents unnecessary animation resets if only other parts of the game state change.
    if (oldWidget.color != widget.color ||
        oldWidget.isCorrect != widget.isCorrect) {
      _resetButtonState();
    }
  }

  void _resetButtonState() {
    if (_isPressed || _overlay != null) {
      // Only call setState if there's actually a change
      setState(() {
        _isPressed = false;
        _overlay = null;
      });
    }
  }

  void _handleTap() {
    if (_isPressed) return; // Prevent multiple taps during animation

    setState(() {
      _isPressed = true;
      _overlay = widget.isCorrect
          ? Colors.green.withValues(alpha: .5)
          : Colors.red.withValues(alpha: .5);
    });

    // Use Future.microtask or ensure it's not directly in setState if possible
    // This delay is intentional for UX feedback.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Check if the widget is still in the tree before calling callback
        widget.onFinished();
        _resetButtonState(); // Reset button state after the game updates
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: _isPressed
                ? null
                : _handleTap, // Disable button while pressed
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor:
                  Colors.white, // Changed to white for better contrast
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              minimumSize: const Size.fromHeight(80),
            ),
            child:
                const SizedBox.shrink(), // No child needed if just a colored button
          ),
          if (_overlay != null) // Only build overlay if it's visible
            Positioned.fill(
              child: IgnorePointer(
                // Prevent interaction with overlay
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: _overlay,
                  child: Center(
                    child: Text(
                      widget.isCorrect ? '✅' : '❌',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

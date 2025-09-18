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
  bool _isPressed = false;

  @override
  void didUpdateWidget(covariant ColorOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset button state only if its core properties (color or correctness) change.
    if (oldWidget.color != widget.color ||
        oldWidget.isCorrect != widget.isCorrect) {
      _resetButtonState();
    }
  }

  void _resetButtonState() {
    if (_isPressed || _overlay != null) {
      setState(() {
        _isPressed = false;
        _overlay = null;
      });
    }
  }

  void _handleTap() {
    if (_isPressed) return;
    if (widget.isCorrect) {
      setState(() {
        _isPressed = true;
      });
      widget.onFinished();
    } else {
      setState(() {
        _isPressed = true;
        _overlay = Colors.red.withValues(alpha: .5);
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onFinished();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: _isPressed ? null : _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              minimumSize: const Size.fromHeight(80),
            ),
            child: const SizedBox.shrink(),
          ),
          if (_overlay != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: _overlay,
                  child: const Center(
                    child: Text('❌', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

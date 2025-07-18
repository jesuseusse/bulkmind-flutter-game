import 'package:flutter/material.dart';

class GameOptionButton extends StatelessWidget {
  final int value;
  final bool isPressed;
  final void Function() onPressed;

  const GameOptionButton({
    super.key,
    required this.value,
    required this.isPressed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: isPressed ? Colors.white.withAlpha(102) : Colors.white,
              width: 2,
            ),
          ),
          minimumSize: const Size.fromHeight(80),
        ),
        key: ValueKey(value.toString()),
        onPressed: isPressed ? null : onPressed,
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            color: isPressed ? Colors.white.withAlpha(102) : Colors.white,
          ),
        ),
      ),
    );
  }
}

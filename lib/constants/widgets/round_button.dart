import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool isLoading;

  const RoundButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 50,
        width: 400,
        child: isLoading
            ? Center(child: const CircularProgressIndicator(color: Colors.white))
            : Center(
              child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            ),
      ),
    );
  }
}

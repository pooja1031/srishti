import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message, 
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w500,
              )
            )
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade400 : const Color(0xFFC3A36E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(20),
      elevation: 6,
      duration: const Duration(seconds: 4),
    ),
  );
}

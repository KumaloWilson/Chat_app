import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  const CustomButtons(
      {super.key,
      required this.onTap,
      required this.icon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 166,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF00BAAB)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
            const SizedBox(width: 10),
            Icon(icon)
          ],
        ),
      ),
    );
  }
}

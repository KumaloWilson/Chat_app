import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;

  const SquareTile({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.70, // Corrected width calculation
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: child,
        ),
      ),
    );
  }
}

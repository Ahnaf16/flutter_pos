import 'package:flutter/material.dart';
import 'package:pos/_core/_core.dart';

class NoProductSelectedView extends StatelessWidget {
  const NoProductSelectedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.svg.productSvg.svg(
                width: 50,
                height: 50,
                colorFilter: Colors.black38.toFilter(),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Product Selected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a product from the list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

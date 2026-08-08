import 'package:flutter/material.dart';

/// Centered circular loading spinner — used as a placeholder while
/// Hive boxes are opening or async providers are resolving.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
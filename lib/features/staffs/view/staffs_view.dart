import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StaffsView extends HookConsumerWidget {
  const StaffsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Staffs')), body: const SingleChildScrollView(child: Column()));
  }
}

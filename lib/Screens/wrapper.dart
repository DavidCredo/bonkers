import 'package:bonkers/Screens/Authentication/handler.dart';
import 'package:bonkers/Screens/home_view.dart';
import 'package:bonkers/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateChangesProvider);

    return authStateAsync.when(
        data: (user) => user != null ? const HomeView() : const Handler(),
        error: ((error, stackTrace) => Text('Error: $error')),
        loading: (() => const CircularProgressIndicator()));
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// [MainScreen] - главный экран.
@RoutePage()
class MainScreen extends StatelessWidget {
  /// Создает [MainScreen].
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

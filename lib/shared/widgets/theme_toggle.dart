import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_management_app/features/settings/theme_provider.dart';

/// Theme toggle button widget that cycles through system → light → dark.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    final IconData icon;
    final String tooltip;

    switch (themeMode) {
      case ThemeMode.system:
        icon = Icons.brightness_auto_rounded;
        tooltip = 'Theme: System (tap to switch to Light)';
        break;
      case ThemeMode.light:
        icon = Icons.light_mode_rounded;
        tooltip = 'Theme: Light (tap to switch to Dark)';
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode_rounded;
        tooltip = 'Theme: Dark (tap to switch to System)';
        break;
    }

    return IconButton(
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          icon,
          key: ValueKey(themeMode),
        ),
      ),
      tooltip: tooltip,
    );
  }
}

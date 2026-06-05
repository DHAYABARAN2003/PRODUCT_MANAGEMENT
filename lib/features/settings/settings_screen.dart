import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_management_app/features/settings/theme_provider.dart';
import 'package:product_management_app/services/cache/cache_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _sectionHeader(theme, 'Appearance'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Theme',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _ThemeOptionTile(
                    icon: Icons.brightness_auto_rounded,
                    title: 'System',
                    subtitle: 'Follow device settings',
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                    colorScheme: cs,
                  ),
                  _ThemeOptionTile(
                    icon: Icons.light_mode_rounded,
                    title: 'Light',
                    subtitle: 'Always use light theme',
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                    colorScheme: cs,
                  ),
                  _ThemeOptionTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark',
                    subtitle: 'Always use dark theme',
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                    colorScheme: cs,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Cache Section
          _sectionHeader(theme, 'Storage'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_sweep_rounded, color: cs.error),
              title: const Text('Clear Cache'),
              subtitle: const Text('Remove cached product data'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                await ref.read(cacheServiceProvider).clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          // About Section
          _sectionHeader(theme, 'About'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                  title: const Text('Version'),
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1),
                // ListTile(
                //   leading: Icon(Icons.code_rounded, color: cs.primary),
                //   title: const Text('Architecture'),
                //   trailing: Text('Clean + MVVM', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Individual theme option tile with radio-style selection.
class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          key: ValueKey(selected),
          color: selected ? colorScheme.primary : colorScheme.outline,
        ),
      ),
      onTap: onTap,
    );
  }
}

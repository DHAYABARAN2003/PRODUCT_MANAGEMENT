import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_management_app/core/constants/app_constants.dart';
import 'package:product_management_app/core/theme/app_theme.dart';
import 'package:product_management_app/features/settings/theme_provider.dart';
import 'package:product_management_app/router/app_router.dart';
import 'package:product_management_app/services/local_storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ProductManagementApp(),
    ),
  );
}

class ProductManagementApp extends ConsumerWidget {
  const ProductManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

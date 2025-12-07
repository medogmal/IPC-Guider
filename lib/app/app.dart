import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import '../features/settings/data/settings_providers.dart';

class IpcApp extends ConsumerWidget {
  const IpcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'IPC Guider',
      theme: lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,

      // Language Support (RTL disabled for now)
      locale: const Locale('en', 'US'), // English only for now
      supportedLocales: const [
        Locale('en', 'US'), // English
        // Locale('ar', 'SA'), // Arabic - Coming soon
      ],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],

      // Text Scaling Support
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScaleFactor),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr, // LTR only for now
            child: child!,
          ),
        );
      },
    );
  }
}

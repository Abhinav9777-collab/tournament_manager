import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tournament_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: const TournamentManagerApp(),
    ),
  );
}

class TournamentManagerApp extends StatelessWidget {
  const TournamentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Tournament Manager',
          debugShowCheckedModeBanner: false,
          themeMode: provider.appThemeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFFF1F5F9),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF03040B),
            useMaterial3: true,
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'firebase_options.dart'; 
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart'; // Import Dashboard
import 'core/services/auth_service.dart';
void main() async {
  // Ensure widgets are bound before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MUStudyApp()));
}
// CHANGE: Make this a ConsumerWidget to listen to Riverpod
class MUStudyApp extends ConsumerWidget {
  const MUStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to whether the user is logged in or out
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'MU Study App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5A67D8),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A67D8)),
      ),
      // CHANGE: Automatically route based on login status
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen(); // Automatically go to Dashboard if logged in
          }
          return const LoginScreen(); // Show Login if not logged in
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
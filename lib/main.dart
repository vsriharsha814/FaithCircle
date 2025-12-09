import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    await dotenv.load(fileName: '.env');
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty) {
      print('❌ GOOGLE_CLIENT_ID NOT FOUND in .env file');
      print('   Make sure GOOGLE_CLIENT_ID is set in your .env file');
    }
  } catch (e) {
    print('⚠️  Could not load .env file: $e');
    print('   Make sure .env file exists in project root');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaithCircle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

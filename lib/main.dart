import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:products_repository/products_repository.dart';
import 'package:provider/provider.dart';
import 'package:waste_wise/common_network_check/firestore_provider.dart';
import 'package:waste_wise/routes/routes.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_wise/constants/constants.dart' as constants;
import 'package:waste_wise/screens/_main_screens/chatbot_screen.dart';
import 'package:waste_wise/screens/_main_screens/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      name: constants.dbName,
      options: FirebaseOptions(
        apiKey: constants.apiKey,
        authDomain: constants.authDomain,
        projectId: constants.projectId,
        storageBucket: constants.storageBucket,
        messagingSenderId: constants.messagingSenderId,
        appId: constants.appId,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
        ChangeNotifierProvider<FirebaseUserRepo>(
          create: (_) => FirebaseUserRepo(),
        ),
        StreamProvider<MyUser>(
          create: (context) =>
          Provider.of<FirebaseUserRepo>(context, listen: false).user,
          initialData: MyUser.empty,
        ),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => FirebaseCartRepo()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WasteManagement',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.greenAccent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: const TextStyle(color: Colors.white70),
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white70,
        ),
      ),
      routes: AppRoutes.getRoutes(),
      initialRoute: '/', // Default initial route
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: child ?? const SizedBox()),
                ],
              ),
              Positioned(
                bottom: 100, // Adjust this value to position FAB above the bottom bar
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to ChatbotScreen
                    Get.to(() => const ChatbotScreen());
                  },
                  child: const Icon(Icons.chat),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

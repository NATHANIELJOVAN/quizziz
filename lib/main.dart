import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Models
import 'models/question.dart';
import 'models/quiz.dart';
// Import Services
import 'services/quiz_manager.dart';
import 'services/auth_manager.dart';
// Import Views (Pages)
import 'views/pages/main_menu_page.dart';
import 'views/pages/create_quiz_list_page.dart';
import 'views/pages/create_quiz_page.dart';
import 'views/pages/edit_quiz_page.dart';
import 'views/pages/quiz_list_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/history_page.dart';
import 'views/pages/create_question_page.dart';
// Import Views (Widgets)
import 'views/widgets/quiz_review_page.dart';
import 'views/widgets/result_page.dart';
import 'views/widgets/quiz_timer.dart';

// Variabel Service Layer Global
final QuizManager quizManager = QuizManager();
final AuthManager authManager = AuthManager();

// --- VARIABEL GLOBAL OTENTIKASI ---
String? currentUserName;
String? currentUserRole;
String? currentUserEmail;

// Kunci penyimpanan
const String _KEY_QUIZ_DATA = 'quiz_data';
const String _KEY_USER_NAME = 'user_name';
const String _KEY_USER_ROLE = 'user_role';
const String _KEY_USER_EMAIL = 'user_email';


// --- FUNGSI PERSISTENSI ---

Future<void> saveAppState() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(_KEY_USER_NAME, currentUserName ?? '');
  await prefs.setString(_KEY_USER_ROLE, currentUserRole ?? '');
  await prefs.setString(_KEY_USER_EMAIL, currentUserEmail ?? '');

  final String quizJson = json.encode(quizManager.toJson());
  await prefs.setString(_KEY_QUIZ_DATA, quizJson);
}

Future<void> loadAppState() async {
  final prefs = await SharedPreferences.getInstance();

  currentUserName = prefs.getString(_KEY_USER_NAME);
  currentUserRole = prefs.getString(_KEY_USER_ROLE);
  currentUserEmail = prefs.getString(_KEY_USER_EMAIL);

  if (currentUserName == '') currentUserName = null;
  if (currentUserRole == '') currentUserRole = null;
  if (currentUserEmail == '') currentUserEmail = null;

  final String? quizJson = prefs.getString(_KEY_QUIZ_DATA);
  if (quizJson != null && quizJson.isNotEmpty) {
    try {
      final Map<String, dynamic> data = json.decode(quizJson);
      quizManager.fromJson(data);
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await loadAppState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),

      cardColor: const Color(0xFF1E1E1E),

      primaryColor: Colors.blueAccent,

      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.tealAccent,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );

    return MaterialApp(
      title: 'Quiz Creator & Solver',
      theme: darkTheme,
      themeMode: ThemeMode.dark,
      home: currentUserRole == null ? const LoginPage() : const MainMenuPage(),
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _loginError;
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _loginError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await authManager.login(email, password);

    if (result['role'] != null) {
      currentUserName = result['username'];
      currentUserRole = result['role'];
      currentUserEmail = result['email'];

      await saveAppState();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } else {
      setState(() {
        _loginError = 'Email atau password salah.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text("Quiz App", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 40),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Masuk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),

                      if (_loginError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(_loginError!, style: const TextStyle(color: Colors.redAccent)),
                        ),

                      const SizedBox(height: 25),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

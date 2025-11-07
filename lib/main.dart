import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './config/app_config.dart';
import './config/app_routes.dart';
import './config/app_theme.dart';
import './services/firebase_service.dart';
import './services/supabase_service.dart';
import './views/splash_view.dart';

void main() async {
  // 1. تأكد من الـ binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تحميل ملف .env
  await dotenv.load(fileName: '.env');

  // 3. تهيئة التكوين
  AppConfig.loadFromEnv();

  // 4. تهيئة Firebase
  await FirebaseService.initialize();

  // 5. تهيئة Supabase (بعد Firebase)
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TakkehApp();
  }
}

class TakkehApp extends StatelessWidget {
  const TakkehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takkeh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
      routes: {
        '/login': (_) => const LoginView(),
'/signupscreen': (context) => const SignUpView(),
        '/check': (_) => const FirebaseCheckPage(),
      },
    );
  }
}

class FirebaseCheckPage extends StatelessWidget {
  const FirebaseCheckPage({super.key});

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Check'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _firebaseAvailable
                  ? 'Firebase Connected!'
                  : 'Firebase NOT initialized',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('Firebase.apps: ${Firebase.apps}');
              },
              child: const Text('Print Firebase.apps'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const CounterPage(title: 'Flutter Demo Home Page'),
                  ),
                );
              },
              child: const Text('Go to Counter App'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpView())
                );
              },
              child: const Text('Open Sign Up Page'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: Run `flutterfire configure` to generate firebase_options.dart for web.',
            ),
          ],
        ),
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});
  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

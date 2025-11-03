import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './views/login_view.dart';
import './views/signup_view.dart';
import './views/splash_view.dart';


Future<void> _ensureFirebaseInitialized() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web requires explicit FirebaseOptions. These values come from
    // the Firebase Console -> Project settings -> Your apps (Web).
    const firebaseOptions = FirebaseOptions(
      apiKey: 'AIzaSyAehZDq0Ntf8escKP93-2PFQ3prx_0F1c8',
      authDomain: 'takkeh-94892.firebaseapp.com',
      projectId: 'takkeh-94892',
      storageBucket: 'takkeh-94892.firebasestorage.app',
      messagingSenderId: '656876491679',
      appId: '1:656876491679:web:1dc4e3cd6c28c99d5b63aa',
      measurementId: 'G-2SY5PCQNN1',
    );

    try {
      await Firebase.initializeApp(options: firebaseOptions);
    } catch (e) {
      debugPrint('Firebase.initializeApp() failed on web: $e');
    }
  } else {
    await Firebase.initializeApp();
  }
}

void main() async {
  await _ensureFirebaseInitialized();
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
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
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

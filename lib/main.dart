import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Store data locally

void main() {
  runApp(const SimpleApp());
}

// Main widget
class SimpleApp extends StatefulWidget {
  const SimpleApp({super.key});

  @override
  // Use createState
  State<SimpleApp> createState() => _MyAppState();
}

class _MyAppState extends State<SimpleApp> {
  bool _isDarkMode = false; // Dark mode

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      });
    }
  }

  // Save theme
  void _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  // Toggle dark/light mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
    });
  }

  // Core of homescreen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      routes: {'/profile': (context) => const ProfileScreen()},
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.brightness_3),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to My Profile App!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('View Profile'),
              onPressed: () {
                Navigator.pushNamed(context, '/profile'); // Go to profile page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Profile logic
class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  String _userName = "Your Name";
  String _role = "Your Role";
  final String _profilePic = "assets/image1.png"; // Profile picture

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    // Initialize controllers after data is loaded in _loadProfileData
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Your Name";
      _role = prefs.getString('role') ?? "Your Role";
      _nameController.text = _userName;
      _designationController.text = _role;
    });
  }

  // Save profile
  void saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _userName);
    prefs.setString('role', _role);
  }

  // Edit profile
  void _edit() {
    _nameController.text = _userName;
    _designationController.text = _role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile: '),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name:'),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: _designationController,
                  decoration: const InputDecoration(labelText: 'Role:'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Use navigator pop
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _userName = _nameController.text;
                  _role = _designationController.text;
                  saveProfileData();
                });
                Navigator.of(context).pop(); // Use navigator pop
              },
            ),
          ],
        );
      },
    );
  }

  // Profile page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _edit)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(_profilePic), // Profile pic
              ),

              const SizedBox(height: 20),
              Text(
                _userName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),
              Text(
                _role,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Back to Home'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

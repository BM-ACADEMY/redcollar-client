import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_Screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeEmailController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();

  bool _isDarkTheme = false;
  bool _receiveNotifications = true;

  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  // Initialize Hive and load preferences
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    settingsBox = await Hive.openBox('settings');
    _loadPreferences();
  }

  // Load preferences from Hive storage
  void _loadPreferences() {
    setState(() {
      _storeNameController.text =
          settingsBox.get('storeName', defaultValue: 'Fashion Store');
      _storeEmailController.text =
          settingsBox.get('storeEmail', defaultValue: 'info@fashionstore.com');
      _storeAddressController.text =
          settingsBox.get('storeAddress', defaultValue: '123 Fashion St, NY');
      _isDarkTheme = settingsBox.get('isDarkTheme', defaultValue: false);
      _receiveNotifications =
          settingsBox.get('receiveNotifications', defaultValue: true);
    });
  }

  // Save preferences to Hive storage
  void _savePreferences() {
    const emailPattern = r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    if (_storeNameController.text.isEmpty ||
        _storeEmailController.text.isEmpty ||
        !_storeEmailController.text.contains(RegExp(emailPattern)) ||
        _storeAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields with valid data.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    settingsBox.put('storeName', _storeNameController.text);
    settingsBox.put('storeEmail', _storeEmailController.text);
    settingsBox.put('storeAddress', _storeAddressController.text);
    settingsBox.put('isDarkTheme', _isDarkTheme);
    settingsBox.put('receiveNotifications', _receiveNotifications);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Navigate to Home Screen
  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          isAdmin: false,
          username: '',
          userId: '',
          email: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkTheme ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Border height
            child: Container(
              color: Colors.black26, // Border color
              height: 1.0, // Border thickness
            ),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _savePreferences,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Store Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Store Name
              TextField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Store Email
              TextField(
                controller: _storeEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Store Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Store Address
              TextField(
                controller: _storeAddressController,
                decoration: const InputDecoration(
                  labelText: 'Store Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Notifications Toggle
              SwitchListTile(
                title: const Text('Receive Notifications'),
                subtitle: const Text('Toggle to receive app notifications'),
                value: _receiveNotifications,
                onChanged: (value) {
                  setState(() {
                    _receiveNotifications = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Theme Toggle
              SwitchListTile(
                title: const Text('Dark Theme'),
                subtitle: const Text('Switch between light and dark themes'),
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Go to Home Button
              ElevatedButton(
                onPressed: _goToHomeScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeEmailController.dispose();
    _storeAddressController.dispose();
    Hive.close();
    super.dispose();
  }
}

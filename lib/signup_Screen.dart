import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'signin_Screen.dart'; // Ensure you have the LoginPage properly implemented in this file
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  static String? baseUrl = dotenv.env['BASE_URL'];
  Map<String, dynamic>? _fbUserData;
  AccessToken? _fbAccessToken;
  bool _checking = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String prettyPrint(Map json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      print("User is already logged in:\n${prettyPrint(accessToken.toJson())}");
      final userData = await FacebookAuth.instance.getUserData();
      setState(() {
        _fbAccessToken = accessToken;
        _fbUserData = userData;
      });
    }
  }

  void _printCredentials() {
    if (_fbAccessToken != null) {
      print("Access Token Details:\n${prettyPrint(_fbAccessToken!.toJson())}");
    }
    if (_fbUserData != null) {
      print("User Data:\n${prettyPrint(_fbUserData!)}");
    }
  }

  Future<void> _handleFacebookLogin() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'],
    );

    if (result.status == LoginStatus.success) {
      _fbAccessToken = result.accessToken;
      _printCredentials();

      final userData = await FacebookAuth.instance.getUserData();

      // Extract values from userData
      final String name = userData['name'] ?? "";
      final String email = userData['email'] ?? "";
      final String id = userData['id'] ?? "";

      // Log extracted data
      print("Facebook Name: $name");
      print("Facebook Email: $email");
      print("Facebook ID: $id");

      // Send data to backend for registration/login
      final url = Uri.parse('$baseUrl/users/register');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'username': name, // Using Facebook name as username
          'email': email, // Facebook email
          'id': id, // Facebook ID
        }),
      );

      // Parse response
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registration/Login Successful: ${responseData['message']}");

        // Navigate to Login Page after success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        print("Error: ${responseData['error']}");
      }

      setState(() {
        _fbUserData = userData;
      });
    } else {
      print("Facebook Login Failed: ${result.status} - ${result.message}");
    }
  }

  Future<void> getFacebookUserDetails(String accessToken) async {
    try {
      final url =
          'https://graph.facebook.com/v15.0/me?fields=id,name,email,phone&access_token=$accessToken';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? name = data['name'];
        String? email = data['email'];
        String? phone = data['phone'];

        print("Name: $name");
        print("Email: $email");
        print("Phone: $phone");

        // Use the phone number if available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Welcome $name! Email: $email, Phone: $phone')),
        );
      } else {
        throw Exception('Failed to fetch Facebook user details');
      }
    } catch (e) {
      print('Error fetching Facebook user details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleFacebookLogout() async {
    await FacebookAuth.instance.logOut();
    setState(() {
      _fbAccessToken = null;
      _fbUserData = null;
    });
  }

  Future<void> _signUpWithEmail() async {
    final url = Uri.parse('$baseUrl/users/register');
    final body = jsonEncode({
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'phoneNumber': _phoneController.text.trim()
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/first.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/Rc.png', width: 100, height: 100),
                    Text(
                      'Create\nYour account',
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 30),
                    CustomInputField(
                      controller: _emailController,
                      hintText: 'E-mail Address',
                      isPassword: false,
                    ),
                    const SizedBox(height: 19),
                    CustomInputField(
                      controller: _usernameController,
                      hintText: 'Username',
                      isPassword: false,
                    ),
                    const SizedBox(height: 19),
                    CustomInputField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      isPassword: false,
                    ),
                    CustomInputField(
                      controller: _passwordController,
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 29),
                    RoundedButton(
                      text: 'Sign Up',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      onPressed: _signUpWithEmail,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _checking
                          ? const Center(
                              child:
                                  CircularProgressIndicator()) // Show loading indicator
                          : ElevatedButton.icon(
                              onPressed: _handleFacebookLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(color: Colors.black12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: Image.asset(
                                'assets/facebook.png',
                                height: 30,
                              ),
                              label: Text(
                                'Continue with Facebook',
                                style: GoogleFonts.lato(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Color(0xFFA7A09D),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFFA7A09D),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.isPassword,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final Widget? icon;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            text,
            style: GoogleFonts.lato(color: textColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

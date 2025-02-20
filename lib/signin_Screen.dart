import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'home_Screen.dart';
import 'signup_Screen.dart';
import 'forgot.dart';
import 'admin_panel_screen.dart';
import 'provider/userProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  static String? baseUrl = dotenv.env['BASE_URL'];
  Map<String, dynamic>? _fbUserData;
  AccessToken? _fbAccessToken;
  bool _checking = true;
  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
    _emailController.addListener(() {
      setState(() {});
    });

    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] ?? false;

        if (success) {
          final username = data['username'] ?? 'Unknown User';
          final isAdmin = data['isAdmin'] ?? false;
          final userId = data['_id'] ?? '';
          final email = data['email'] ?? '';
          print('userId,$userId');
          // Update global state using UserProvider
          Provider.of<UserProvider>(context, listen: false)
              .login(userId, username, email);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome, $username'),
            ),
          );

          // Navigate based on user role (admin or regular)
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPanelScreen(username: username),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  username: username,
                  isAdmin: isAdmin,
                  userId: userId,
                  email: email,
                ),
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['redcollor465@gmail.com']);
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

  Future<void> _handleSignIn() async {
    try {
      var user = await _googleSignIn.signIn();
      print(user);
    } catch (error) {
      print('Google Sign-In failed: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    print("User signed out");
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

      // Call Login API with Facebook ID
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}), // Send only Facebook ID for login
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print("Facebook Login Successful!");

        // Extract user details from response
        final String username = responseData['username'];
        final bool isAdmin = responseData['isAdmin'];
        final String userId = responseData['_id'];
        final String userEmail = responseData['email'];
        Provider.of<UserProvider>(context, listen: false)
            .login(userId, username, email);
        // Navigate to HomeScreen with user details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: username,
              isAdmin: isAdmin,
              userId: userId,
              email: userEmail,
            ),
          ),
        );
      } else {
        print("Error: ${responseData['message']}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/first.jpg'),
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
                          Image.asset(
                            'assets/Rc.png',
                            width: 100,
                            height: 100,
                          ),
                          Text(
                            'Log into\nYour account',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 25),
                          _buildInputField(
                            controller: _emailController,
                            hintText: 'E-mail',
                            isPassword: false,
                          ),
                          const SizedBox(height: 25),
                          _buildInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),
                          RoundedButton(
                            text: 'Login',
                            onPressed: _loginWithEmail,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotResetPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          // RoundedButton(
                          //   text: 'Login with Google',
                          //   onPressed: _handleSignIn,
                          //   backgroundColor: Colors.white,
                          //   textColor: Colors.black,
                          //   icon: Image.asset("assets/G l.png", height: 24),
                          // ),
                          const SizedBox(height: 24),
                          RoundedButton(
                            text: 'Login with Facebook',
                            onPressed: _handleFacebookLogin,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            icon:
                                Image.asset("assets/facebook.png", height: 24),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Text(
                                'Don’t you have an account?',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateAccountPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lato(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: isPassword
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

// Rounded Button Component
class RoundedButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final Image? icon;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon!,
          if (icon != null) const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.lato(color: textColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}


  // Future<void> _loginWithGoogle() async {
  //   try {
  //     GoogleSignInAccount? user = await _googleSignIn.signIn();
  //     if (user != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Google login successful! Welcome, ${user.displayName}',
  //             style: GoogleFonts.lato(),
  //           ),
  //         ),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => HomeScreen(
  //             username: user.displayName ?? 'Unknown User',
  //             isAdmin: false, userId: null, email: null,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Error: $e',
  //           style: GoogleFonts.lato(),
  //         ),
  //       ),
  //     );
  //   }
  // }

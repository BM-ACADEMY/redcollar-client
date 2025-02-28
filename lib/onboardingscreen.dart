import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Replace with your actual sign-up screen
import 'signin_screen.dart'; // Replace with your actual sign-in screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/client.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Part 1: Logo & Title
              Expanded(
                flex: 2, // Adjust flex as needed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/Rc.png",
                      height: 100.0,
                      width: 100.0,
                    ),
                    const SizedBox(height: 16), // Proper spacing
                    const Text(
                      'Red Collar',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Part 2: Sign-up & Links
              Expanded(
                flex: 3, // Adjust flex to balance layout
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundedButton(
                      icon: Image.asset(
                        "assets/G l.png",
                        height: 24.0,
                        width: 24.0,
                      ),
                      text: 'Sign up with Google',
                      onPressed: () {
                        debugPrint('Sign up with Google');
                      },
                    ),
                    const SizedBox(height: 16),
                    RoundedButton(
                      icon: Image.asset(
                        "assets/apple.png",
                        height: 24.0,
                        width: 24.0,
                      ),
                      text: 'Sign up with Apple',
                      onPressed: () {
                        debugPrint('Sign up with Apple');
                      },
                    ),
                    const SizedBox(height: 16),
                    RoundedButton(
                      icon: Image.asset(
                        "assets/facebook.png",
                        height: 30.0,
                        width: 30.0,
                      ),
                      text: 'Sign up with Facebook',
                      onPressed: () {
                        debugPrint('Sign up with Facebook');
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sign-in/Sign-up Links
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                            height: 8), // Space between text and buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateAccountPage()),
                                );
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const Text(
                              ' / ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                'in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    // Privacy Notice
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'We collect data to improve your experience. ',
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'Learn More',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  debugPrint('Learn More tapped');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rounded Button Widget
class RoundedButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const RoundedButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.8, // Dynamic width based on screen size
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon, // Icon on the left
            const SizedBox(width: 8), // Space between icon and text
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
 
 LOGIN PAGE

 on this page, an existing user can login with:
- email
- pwd


------------------------------------------------------

once the user successfully logged in they will be redirected to the home page.

if the user does not have account they can go to register page.
 */

import 'package:flutter/material.dart';
import 'package:social_app/features/auth/presentation/components/my_button.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                // welcome back msg
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 25),
                // email text field
                MyTextField(
                  controller: emailController,
                  hintText: 'email',
                  obscureText: false,
                ),
                SizedBox(height: 12),

                // pwd text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: true,
                ),
                SizedBox(height: 25),
                // login btn
                MyButton(onTap: () {}, text: 'Sign In'),

                SizedBox(height: 50),
                // register now btn
                Text("Not a member? Register now"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:social_app/features/auth/presentation/components/my_button.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

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

                // divider
                SizedBox(height: 25),

                // name text field
                MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),

                // divider
                SizedBox(height: 12),

                // email text field
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                // divider
                SizedBox(height: 12),

                // pwd text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                // divider
                SizedBox(height: 12),

                // confirm pwd text field
                MyTextField(
                  controller: confirmPwController,
                  hintText: 'Retype password',
                  obscureText: true,
                ),

                // divider
                SizedBox(height: 25),

                // login btn
                MyButton(onTap: () {}, text: 'Sign Up'),

                // divider
                SizedBox(height: 50),

                // register now btn
                Text(
                  "Already a member? Log in now",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

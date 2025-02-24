import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/components/my_button.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void register() {
    // prepare user info
    final String name = nameController.text;
    final String email = emailController.text;
    final String pwd = passwordController.text;
    final String confirmPwd = confirmPwController.text;

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // check empty field
    if (email.isEmpty || name.isEmpty || pwd.isEmpty || confirmPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill all fields'),
          backgroundColor: const Color.fromARGB(255, 234, 121, 121),
        ),
      );
    }
    // check matching pwds
    else if (pwd != confirmPwd) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('passwords does not match')));
      passwordController.text = '';
      confirmPwController.text = '';
    } else {
      authCubit.register(name, email, pwd);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

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

                // register btn
                MyButton(onTap: register, text: 'Sign Up'),

                // divider
                SizedBox(height: 50),

                // login now btn
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "already a user?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        " login now",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

import 'package:chat_app/app/controller/auth/bloc/auth_bloc.dart';
import 'package:chat_app/app/utils/components/continue_with.dart';
import 'package:chat_app/app/utils/components/my_button.dart';
import 'package:chat_app/app/utils/components/my_square_tile.dart';
import 'package:chat_app/app/utils/components/my_textfield.dart';
import 'package:chat_app/app/utils/constants/app_theme.dart';
import 'package:chat_app/app/utils/constants/text_constants.dart';
import 'package:chat_app/app/utils/constants/validators.dart';
import 'package:chat_app/app/view/home/home.dart';
import 'package:chat_app/app/view/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterPageNavigatedState) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ));
        } else if (state is LoggedInSuccessState) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged in successfully!")));
        } else if (state is LoggedInErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Image.asset(
                      'assets/images/chatify.png',
                      height: 100,
                    ),
                    const SizedBox(height: 50),
                    Text(TextConstants.appTitle,
                        style: TextConstants.titleStyle(context)),

                    const SizedBox(height: 25),

                    // email textfield
                    MyTextField(
                      validator: emailValidate,
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // password textfield
                    MyTextField(
                      validator: passwordValidate,
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    // forgot password?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Text(TextConstants.forgot,
                                style: TextConstants.forgotStyle(context)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // sign in button
                    MyButton(
                      onTap: () {
                        if (formkey.currentState!.validate()) {
                          BlocProvider.of<AuthBloc>(context).add(
                              LoginButtonClickedEvent(
                                  email: emailController.text,
                                  password: passwordController.text));
                        }
                      },
                      text: TextConstants.login,
                    ),

                    const SizedBox(height: 25),

                    continueWIth(context),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(
                          onTap: () async {},
                          child: Image.asset(
                            google,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(TextConstants.notMember,
                            style: TextConstants.primarystyle(context)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            BlocProvider.of<AuthBloc>(context)
                                .add(RegisterPageNavigateEvent());
                          },
                          child: Text(TextConstants.register,
                              style: TextConstants.registerStyle(context)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

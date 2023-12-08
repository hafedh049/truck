import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:footy_shorts/utils/globals.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _passwordState = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneNumberController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40),
              IconButton(splashColor: teal, onPressed: () => Get.back(), icon: const Icon(FontAwesome.chevron_left, color: teal)),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "E-mail", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          TextSpan(text: " *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: teal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextFormField(
                          onChanged: (String value) {
                            _(() => _emailState = _emailController.text.trim().isNotEmpty);
                          },
                          controller: _emailController,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "E-mail",
                            suffixIcon: Icon(_emailState ? FontAwesome.circle_check : null),
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          TextSpan(text: " *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: teal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextFormField(
                          onChanged: (String value) => _(() => _usernameState = _usernameController.text.trim().isNotEmpty),
                          controller: _usernameController,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "Name",
                            suffixIcon: Icon(_usernameState ? FontAwesome.circle_check : null),
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        const Text.rich(TextSpan(children: <TextSpan>[TextSpan(text: "Password", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), TextSpan(text: " *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: teal))])),
                        const Spacer(),
                        IconButton(highlightColor: transparent, splashColor: transparent, hoverColor: transparent, onPressed: () async => await _showInfo(), icon: const Icon(FontAwesome.circle_info, size: 25, color: teal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextFormField(
                          controller: _passwordController,
                          onChanged: (String text) => _passwordStrengthKey.currentState!.setState(() => _computeStrength()),
                          obscureText: !_passwordState,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "Password",
                            suffixIcon: IconButton(onPressed: () => _(() => _passwordState = !_passwordState), icon: Icon(!_passwordState ? Icons.visibility_off : Icons.visibility)),
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      key: _passwordStrengthKey,
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return Row(children: <Widget>[for (Color strength in _passwordStrength) Expanded(child: AnimatedContainer(duration: 300.ms, height: 3, color: strength, margin: const EdgeInsets.symmetric(horizontal: 4)))]);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: "Confirm Password", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          TextSpan(text: " *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: teal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordState,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "Confirm Password",
                            suffixIcon: IconButton(onPressed: () => _(() => _confirmPasswordState = !_confirmPasswordState), icon: Icon(!_confirmPasswordState ? Icons.visibility_off : Icons.visibility)),
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(12)),
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.all(20),
                child: const Center(child: Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
              ),
              const SizedBox(height: 20),
              const Divider(color: gray, height: .5, thickness: .5),
              const SizedBox(height: 20),
              InkWell(
                highlightColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                onTap: () => Get.back(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?", style: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    const Text("Login", style: TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
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

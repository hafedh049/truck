import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:harmonix/models/user_model.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:harmonix/utils/globals.dart';
import 'package:harmonix/utils/methods.dart';
import 'package:harmonix/auth/sign_up.dart';
import 'package:harmonix/home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordState = false;
  bool _signInState = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.sizeOf(context).height * .35),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: gray, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text("Welcome\nBack", style: TextStyle(fontSize: 28, color: white, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(color: white.withOpacity(.2), shape: BoxShape.circle),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(FontAwesome.fingerprint, color: teal, size: 25),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(color: white.withOpacity(.2), shape: BoxShape.circle),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(FontAwesome.hands, color: yellow, size: 25),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                                  hintText: "Email",
                                  contentPadding: const EdgeInsets.all(24),
                                  hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(height: 20),
                              StatefulBuilder(
                                builder: (BuildContext context, void Function(void Function()) _) {
                                  return TextFormField(
                                    controller: _passwordController,
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
                              const SizedBox(height: 20),
                              Row(
                                children: <Widget>[
                                  const Spacer(),
                                  InkWell(
                                    highlightColor: transparent,
                                    splashColor: transparent,
                                    hoverColor: transparent,
                                    onTap: () {},
                                    child: Text("Forget Password?", style: TextStyle(color: white.withOpacity(.8), fontSize: 16, fontWeight: FontWeight.w400)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) _) {
                            return InkWell(
                              highlightColor: transparent,
                              splashColor: transparent,
                              hoverColor: transparent,
                              onTap: () async {
                                try {
                                  if (!_signInState) {
                                    _(() => _signInState = false);
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
                                    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot<Map<String, dynamic>> value) async {
                                      user = UserModel.fromJson(value.data()!);
                                      await Get.to(const Home());
                                      // ignore: use_build_context_synchronously
                                      showSnack("User Authenitificated", 1, context);
                                    });
                                  }
                                } catch (e) {
                                  _(() => _signInState = false);
                                  // ignore: use_build_context_synchronously
                                  showSnack(e.toString(), 3, context);
                                }
                              },
                              child: AnimatedContainer(
                                duration: 700.ms,
                                decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(12)),
                                width: MediaQuery.sizeOf(context).width,
                                padding: const EdgeInsets.all(20),
                                child: Center(child: Text(_signInState ? "Waiting..." : "Sign in", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          highlightColor: transparent,
                          splashColor: transparent,
                          hoverColor: transparent,
                          onTap: () async => Get.to(const SignUp()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an account?", style: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400)),
                              const SizedBox(width: 5),
                              const Text("Get Started", style: TextStyle(color: teal, fontSize: 23, fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

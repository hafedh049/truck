import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:truck/auth/sign_up.dart';
import 'package:truck/home.dart';
import 'package:truck/models/user_model.dart';
import 'package:truck/utils/globals.dart';
import 'package:truck/utils/methods.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> /*with WidgetsBindingObserver*/ {
  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    if (userLocalSettings!.get("first_time")) {
      userLocalSettings!.put("first_time", false);
    }
    super.dispose();
  }

/*  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    super.didChangeAppLifecycleState(state);
  }*/

  PhoneNumber _number = PhoneNumber();
  bool _signInState = false;
  String _smsCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.sizeOf(context).height * .5),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: gray, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text("Welcome", style: TextStyle(fontSize: 28, color: white, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(color: white.withOpacity(.2), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(16),
                          child: const Icon(FontAwesome.hands, color: yellow, size: 25),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) => _number = number,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useBottomSheetSafeArea: true,
                            setSelectorButtonAsPrefixIcon: true,
                            leadingPadding: 8,
                            trailingSpace: false,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _number,
                          formatInput: true,
                          selectorTextStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          inputDecoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "Phone",
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                        ),
                      ],
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
                                _(() => _signInState = true);
                                await FirebaseAuth.instance.verifyPhoneNumber(
                                  verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
                                    await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
                                    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
                                      (DocumentSnapshot<Map<String, dynamic>> value) async {
                                        user = UserModel.fromJson(value.data()!);
                                      },
                                    );
                                    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home())); // ignore: use_build_context_synchronously
                                    // ignore: use_build_context_synchronously
                                    showSnack("User Authenitificated", 1, context);
                                  },
                                  verificationFailed: (FirebaseAuthException error) {
                                    _(() => _signInState = false);
                                    // ignore: use_build_context_synchronously
                                    showSnack(error.toString(), 3, context);
                                  },
                                  codeSent: (String verificationId, int? forceResendingToken) {
                                    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _smsCode);
                                  },
                                  codeAutoRetrievalTimeout: (String verificationId) {},
                                );
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
                      onTap: () async => await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const SignUp())),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account?", style: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400)),
                          const SizedBox(width: 5),
                          const Text("Get Started", style: TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

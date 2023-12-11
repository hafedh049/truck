import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:truck/views/home.dart';
import 'package:truck/utils/globals.dart';
import 'package:truck/utils/methods.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  PhoneNumber _number = PhoneNumber(dialCode: "+216", isoCode: "TN", phoneNumber: "23566502");
  bool _signInState = false;
  bool _phoneIsValidate = false;

  bool _showOTP = false;
  String _verificationID = "";

  final GlobalKey<State> _otpKey = GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Container(
              decoration: const BoxDecoration(color: gray, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text("Welcome", style: TextStyle(fontSize: 28, color: white, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(color: white.withOpacity(.2), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(FontAwesome.hands, color: teal, size: 25),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) => _number = number,
                    onInputValidated: (bool value) => _phoneIsValidate = value,
                    selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.BOTTOM_SHEET, useBottomSheetSafeArea: true, setSelectorButtonAsPrefixIcon: true, leadingPadding: 8, trailingSpace: false),
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
                  StatefulBuilder(
                    key: _otpKey,
                    builder: (BuildContext context, void Function(void Function()) setS) {
                      return _showOTP
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(height: 20),
                                OTPTextField(
                                  fieldStyle: FieldStyle.box,
                                  length: 6,
                                  fieldWidth: 40,
                                  otpFieldStyle: OtpFieldStyle(borderColor: white, focusBorderColor: teal, enabledBorderColor: teal, disabledBorderColor: white),
                                  width: MediaQuery.of(context).size.width,
                                  onCompleted: (String value) async {
                                    try {
                                      print("starting");
                                      final PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationID, smsCode: value);
                                      await FirebaseAuth.instance.signInWithCredential(credential);
                                      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
                                        (DocumentSnapshot<Map<String, dynamic>> value) async {
                                          if (!value.exists) {
                                            final Map<String, dynamic> data = <String, dynamic>{"phone": _number.phoneNumber!, "uid": FirebaseAuth.instance.currentUser!.uid};
                                            value.reference.set(data);
                                          }
                                        },
                                      );
                                      // ignore: use_build_context_synchronously
                                      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
                                      // ignore: use_build_context_synchronously
                                      showSnack("User Authenitificated", 1, context);
                                    } catch (e) {
                                      setS(() => _signInState = false);
                                      _otpKey.currentState!.setState(
                                        () {
                                          _verificationID = "";
                                          _showOTP = false;
                                        },
                                      );
                                      // ignore: use_build_context_synchronously
                                      showSnack(e.toString(), 3, context);
                                    }
                                  },
                                ),
                              ],
                            )
                          : const SizedBox();
                    },
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
                            if (!_signInState && _phoneIsValidate) {
                              _(() => _signInState = true);
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber: _number.phoneNumber!,
                                verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {},
                                verificationFailed: (FirebaseAuthException error) {
                                  _(() => _signInState = false);
                                  // ignore: use_build_context_synchronously
                                  showSnack(error.toString(), 3, context);
                                },
                                codeSent: (String verificationId, int? forceResendingToken) async {
                                  _otpKey.currentState!.setState(
                                    () {
                                      _verificationID = verificationId;
                                      _showOTP = true;
                                    },
                                  );
                                },
                                codeAutoRetrievalTimeout: (String verificationId) {
                                  _verificationID = verificationId;
                                },
                              );
                            } else {
                              _(() => _signInState = false);
                              // ignore: use_build_context_synchronously
                              showSnack("CHECK THE PHONE NUMBER", 2, context);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

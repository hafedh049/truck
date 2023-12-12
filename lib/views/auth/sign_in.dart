import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:truck/views/helpers/utils/globals.dart';
import 'package:truck/views/helpers/utils/methods.dart';
import 'package:truck/views/home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  PhoneNumber _number = PhoneNumber(dialCode: "+216", phoneNumber: "23566502");
  bool _signInState = false;
  bool _phoneIsValide = false;
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
                    onInputValidated: (bool value) => _phoneIsValide = value,
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
                  const SizedBox(height: 40),
                  StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return InkWell(
                        highlightColor: transparent,
                        splashColor: transparent,
                        hoverColor: transparent,
                        onTap: () async {
                          try {
                            if (!_signInState && _phoneIsValide) {
                              _(() => _signInState = true);
                              final QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance.collection("users").where("phone", isEqualTo: _number.phoneNumber!).limit(1).get();
                              if (query.docs.isNotEmpty) {
                                showSnack("User Connected");
                                showSnack("Welcome");
                                final Map<String, dynamic> data = query.docs.first.data();
                                await userLocalSettings!.putAll(
                                  <String, dynamic>{
                                    "uid": data["uid"],
                                    "phone": <String, String>{"number": _number.phoneNumber!, "country_code": _number.dialCode!},
                                  },
                                );
                                // ignore: use_build_context_synchronously
                                await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
                              } else {
                                showSnack("USER DOES NOT EXIST");
                              }
                            } else {
                              _(() => _signInState = false);
                              // ignore: use_build_context_synchronously
                              showSnack("CHECK THE PHONE NUMBER");
                            }
                          } catch (e) {
                            _(() => _signInState = false);
                            // ignore: use_build_context_synchronously
                            showSnack(e.toString());
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

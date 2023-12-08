import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  bool _signUpState = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneNumberController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async => await _speechToText.initialize();

  void _startListening(TextEditingController controller) async => await _speechToText.listen(onResult: (SpeechRecognitionResult result) => _onSpeechResult(result, controller));

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result, TextEditingController controller) {
    controller.text = result.recognizedWords;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              IconButton(splashColor: teal, onPressed: () => Get.back(), icon: const Icon(FontAwesome.chevron_left, color: teal)),
              Form(
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                            controller: _emailController,
                            style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                              hintText: "E-mail",
                              suffix: InkWell(
                                onTap: () {
                                  _(() {});
                                  _speechToText.isNotListening ? _startListening(_emailController) : _stopListening();
                                },
                                child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, size: 20, color: teal),
                              ),
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
                            controller: _usernameController,
                            style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                              suffix: InkWell(
                                onTap: () {
                                  _(() {});
                                  _speechToText.isNotListening ? _startListening(_usernameController) : _stopListening();
                                },
                                child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, size: 20, color: teal),
                              ),
                              hintText: "Name",
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
                          IconButton(highlightColor: transparent, splashColor: transparent, hoverColor: transparent, onPressed: () async => await _showInfo(), icon: const Icon(FontAwesome.circle_info, size: 15, color: teal)),
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
                              suffix: InkWell(
                                onTap: () => _(() => _passwordState = !_passwordState),
                                child: Icon(_passwordState ? Icons.visibility_off : Icons.visibility, size: 15, color: teal),
                              ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) _) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          highlightColor: transparent,
                          splashColor: transparent,
                          hoverColor: transparent,
                          onTap: () {
                            if (_type != "Deaf") {
                              _(() => _type = "Deaf");
                            }
                          },
                          child: AnimatedContainer(
                            duration: 500.ms,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(color: _type == "Deaf" ? teal : gray.withOpacity(.5), borderRadius: BorderRadius.circular(12), border: _type == "Deaf" ? Border.all(width: .5, color: gray) : null),
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.all(20),
                            child: const Center(child: Text("Deaf", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: InkWell(
                          highlightColor: transparent,
                          splashColor: transparent,
                          hoverColor: transparent,
                          onTap: () {
                            if (_type != "Mute") {
                              _(() => _type = "Mute");
                            }
                          },
                          child: AnimatedContainer(
                            duration: 500.ms,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(color: _type == "Mute" ? teal : gray.withOpacity(.5), borderRadius: BorderRadius.circular(12), border: _type == "Mute" ? Border.all(width: .5, color: gray) : null),
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.all(20),
                            child: const Center(child: Text("Mute", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) _) {
                  return InkWell(
                    highlightColor: transparent,
                    splashColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      try {
                        if (!_signUpState) {
                          _(() => _signUpState = true);
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
                          final Map<String, String> userData = <String, String>{
                            "uid": FirebaseAuth.instance.currentUser!.uid,
                            "username": _usernameController.text.trim(),
                            "email": _emailController.text.trim(),
                            "password": _passwordController.text.trim(),
                            "type": _type,
                          };
                          await FirebaseFirestore.instance.collection("users").add(userData);
                          user = UserModel.fromJson(userData);
                          await Get.to(const Home());
                          // ignore: use_build_context_synchronously
                          showSnack("Account Created", 1, context);
                        }
                      } catch (e) {
                        _(() => _signUpState = false);
                        // ignore: use_build_context_synchronously
                        showSnack(e.toString(), 3, context);
                      }
                    },
                    child: AnimatedContainer(
                      duration: 700.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(12)),
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text(_signUpState ? "Waiting..." : "Create Account", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                    ),
                  );
                },
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
                    Text("Already have an account ?", style: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    const Text("Login", style: TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  highlightColor: transparent,
                  splashColor: transparent,
                  hoverColor: transparent,
                  onTap: () {},
                  child: const Icon(FontAwesome.fingerprint, color: teal, size: 45),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

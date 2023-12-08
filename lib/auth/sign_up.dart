import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truck/utils/globals.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

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
              IconButton(splashColor: teal, onPressed: () => Navigator.pop(context), icon: const Icon(FontAwesome.chevron_left, color: teal)),
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
                          controller: _emailController,
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "E-mail",
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
                            hintText: "Name",
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
                          TextSpan(text: "Phone", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          TextSpan(text: " *", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: teal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (BuildContext context, void Function(void Function()) _) {
                        return TextFormField(
                          controller: _phoneNumberController,
                          validator: (value) {},
                          style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .6, color: gray.withOpacity(.1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: .8, color: white.withOpacity(.6))),
                            hintText: "Phone",
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
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(12)),
                  width: MediaQuery.sizeOf(context).width,
                  padding: const EdgeInsets.all(20),
                  child: const Center(child: Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: gray, height: .5, thickness: .5),
              const SizedBox(height: 20),
              InkWell(
                highlightColor: transparent,
                splashColor: transparent,
                hoverColor: transparent,
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account?", style: TextStyle(color: white.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    const Text("Sign In", style: TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
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

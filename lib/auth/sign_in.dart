import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:footy_shorts/home.dart';
import 'package:footy_shorts/utils/globals.dart';
import 'package:footy_shorts/views/auth/sign_up.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordState = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    if (userLocalSettings!.get("first_time")) {
      userLocalSettings!.put("first_time", false);
    }
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
            CarouselSlider.builder(
              itemCount: 4,
              options: CarouselOptions(
                viewportFraction: 1,
                height: MediaQuery.sizeOf(context).height * .6,
                autoPlay: true,
                autoPlayCurve: Curves.easeIn,
                enlargeFactor: 0,
              ),
              itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                return Image.asset("assets/pictures/football/${itemIndex + 1}.jpg", fit: BoxFit.cover);
              },
            ),
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.sizeOf(context).height * .4),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: gray, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(userLocalSettings!.get("first_time") ? "Welcome" : "Welcome\nBack", style: const TextStyle(fontSize: 28, color: white, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(color: white.withOpacity(.2), shape: BoxShape.circle),
                              padding: const EdgeInsets.all(16),
                              child: Icon(FontAwesome.hands, color: yellow, size: 25),
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
                        InkWell(
                          onTap: () async {
                            await Get.to(const Home());
                          },
                          child: Container(
                            decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(12)),
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.all(20),
                            child: const Center(child: Text("Sign in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                          ),
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
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:terrestra/helpers/utils/globals.dart';
import 'package:terrestra/helpers/utils/methods.dart';
import 'package:terrestra/views/hold.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _signInState = false;
  final TextEditingController _rut = TextEditingController();

  @override
  void dispose() {
    _rut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Center(child: Image.asset("assets/logo.png", width: MediaQuery.sizeOf(context).width * .7)),
              const SizedBox(height: 30),
              const Text("Hola !", style: TextStyle(fontSize: 45, fontWeight: FontWeight.w500, color: accent1, letterSpacing: 2)),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(color: accent1.withOpacity(.2), borderRadius: BorderRadius.circular(12), border: Border.all(width: .6, color: accent1)),
                child: TextField(
                  style: const TextStyle(color: accent1),
                  cursorColor: accent1,
                  controller: _rut,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "RUT",
                    prefixIcon: const Icon(Bootstrap.lock_fill, color: accent1, size: 15),
                    contentPadding: const EdgeInsets.all(24),
                    hintStyle: GoogleFonts.ibmPlexSans(color: accent1.withOpacity(.5), fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const Spacer(),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) _) {
                  return InkWell(
                    highlightColor: transparent,
                    splashColor: transparent,
                    hoverColor: transparent,
                    onTap: () async {
                      try {
                        if (!_signInState && _rut.text.trim().isNotEmpty) {
                          _(() => _signInState = true);
                          final DocumentSnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance.collection("users").doc(_rut.text.trim()).get();
                          if (query.exists) {
                            showSnack("Bienvenido");
                            userLocalSettings!.put("RUT", _rut.text.trim());
                            _(() => _signInState = false);
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Hold()));
                          } else {
                            _(() => _signInState = false);
                            showSnack("EL USUARIO NO EXISTE, POR FAVOR CONTACTAR AL CENTRO DE OPERACIONES");
                          }
                        } else {
                          _(() => _signInState = false);
                          showSnack("EL CÓDIGO RUT NO DEBE ESTAR VACÍO");
                        }
                      } catch (e) {
                        _(() => _signInState = false);
                        showSnack(e.toString());
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent1,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: <BoxShadow>[BoxShadow(color: foregroundColor.withOpacity(.1), offset: const Offset(2, 4), blurStyle: BlurStyle.outer)],
                      ),
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text(_signInState ? "Espera..." : "Entrar", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/nav.dart';
import '../../core/theme.dart';
import '../../models/role.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final Role role;
  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [
            const SizedBox(height: 30),
            const Logo(),
            const SizedBox(height: 20),
            Text(role.loginTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            if (role.loginSub.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(role.loginSub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.black87)),
            ],
            const SizedBox(height: 30),
            for (final f in role.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    obscureText: f == 'Password',
                    keyboardType: f == 'Mobile number'
                        ? TextInputType.phone
                        : TextInputType.text,
                    textInputAction: f == 'Password'
                        ? TextInputAction.done
                        : TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: f == 'Password' ? 'Enter Password' : '09XXXXXXXXX',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: kGrey,
                      isDense: true,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ]),
              ),
            const SizedBox(height: 6),
            Pressable(
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: role.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  onPressed: () {
                    if (!AuthController.I.login(role)) return;
                    Nav.resetTo(context, const Shell());
                  },
                  child: const Text('Log in'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Nav.push(context, SignUpScreen(role: role)),
              child: Text('New here? Create a ${role.name} account.',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      decoration: TextDecoration.underline)),
            ),
          ]),
        ),
      );
}

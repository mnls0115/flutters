import 'package:flutter/material.dart';
import 'package:soaproject/Screens/Auths/find_auth_screen.dart';
import 'signup_screen.dart';
import '../../Widgets/Auths/login_input_widget.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/Login Screeen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('login screen');
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.only(top: 60, left: 32, right: 32),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const Text(
                  '첫 걸 음',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1568B3),
                  ),
                ),
                Text(
                  '건강하게, 처음 걸을 때까지',
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color(0xFF1568B3).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                const LoginInputWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(SignUpScreen.routeName),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(FindAuthScreen.routeName),
                      child: const Text(
                        '아이디/비밀번호 찾기',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

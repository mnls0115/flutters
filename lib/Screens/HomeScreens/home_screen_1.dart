import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/Auths/login_screen.dart';
import 'package:soaproject/Screens/Settings/setting_screen.dart';
import 'package:soaproject/Widgets/HomeScreens/info_photo_widget.dart';
import 'package:soaproject/Widgets/HomeScreens/info_widget_1.dart';
import 'package:soaproject/Widgets/HomeScreens/info_widget_2.dart';
import 'package:soaproject/Widgets/divider.dart';

class HomeScreen1 extends StatelessWidget {
  static const routeName = 'HomeScreen1';
  final User? user;
  final double height, width;
  const HomeScreen1({
    this.user,
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('page 1');

    var _provider = Provider.of<UserInfoprovider>(context);
    HealthInformations _healthInfo = _provider.getHealthInformagions;
    EvalInformations _evalInfo = _provider.getEvalInformagions;
    UserInformations _userInfo = user != null
        ? _provider.getUserInformagions
        : UserInformations(nickname: '손님');

    if (user != null && _userInfo.nickname == null) {
      print('load on null');
      _provider.loadUserInfos(user);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhotoWidget(
                    user: user,
                    userInformations: _userInfo,
                  ),
                  const SizedBox(width: 16),
                  LoginTextWidget(userInfo: _userInfo),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        SettingScreen.routeName,
                        arguments: user,
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const MyDivider(),
            const SizedBox(height: 8),
            SizedBox(
              height: height - 220,
              child: PageView(
                children: [
                  InfoSubWidget1(
                    userInfo: _userInfo,
                    healthInfo: _healthInfo,
                    user: user,
                    width: width,
                  ),
                  InfoSubWidget2(
                    userInfo: _userInfo,
                    healthInfo: _healthInfo,
                    evalInfo: _evalInfo,
                    width: width,
                    user: user,
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

class LoginTextWidget extends StatelessWidget {
  const LoginTextWidget({
    Key? key,
    required UserInformations userInfo,
  })  : _userInfo = userInfo,
        super(key: key);

  final UserInformations _userInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: _userInfo.email != null
          ? Text(
              _userInfo.nickname!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          : TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(LoginScreen.routeName),
              child: const Text(
                '로그인 하시고,\n기록을 저장해보세요.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
    );
  }
}

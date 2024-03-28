import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soaproject/Provider/record.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/Settings/re_signup_screen.dart';
import 'package:soaproject/Screens/tab_bar_screen.dart';
import 'package:soaproject/Widgets/Settings/asking_button_widget.dart';

class SettingScreen extends StatelessWidget {
  static const routeName = '/Setting';
  const SettingScreen({Key? key}) : super(key: key);

  Future<void> sharedClear() async {
    var _shared = await SharedPreferences.getInstance();
    _shared.clear();
  }

  Future<void> emailVerify({
    required User user,
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이메일 인증'),
        content: const Text('인증 이메일이 발송 되었어요.\n인증 후 다시 로그인 해주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    await user.sendEmailVerification();
  }

  Future<void> logOutFx(
    BuildContext context,
    UserInfoprovider userProvider,
  ) async {
    await FirebaseAuth.instance.signOut();
    await sharedClear();
    userProvider.clearInfos();
    Provider.of<Record>(context, listen: false).clearRecords();
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, TabBarScreen.routeName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('로그아웃 되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void needLogin(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          '로그인 이후에 가능해요.',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Screen setting');
    var _mediaquery = MediaQuery.of(context).size;
    User? _user = ModalRoute.of(context)!.settings.arguments as User?;
    var _userProvider = Provider.of<UserInfoprovider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          height: _mediaquery.height,
          width: _mediaquery.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  '로그 아웃',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  if (_user == null) {
                    needLogin(context);
                    return;
                  } else {
                    logOutFx(context, _userProvider);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text(
                  '회원 정보 변경',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  if (_user == null) {
                    needLogin(context);
                    return;
                  } else {
                    Navigator.of(context).pushNamed(
                      ResignUpScreen.routeName,
                      arguments: _user,
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _user != null && _user.emailVerified
                  ? Container(
                      alignment: Alignment.center,
                      height: 40,
                      child: const Text(
                        '이메일 인증 완료',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.email_outlined),
                          label: const Text(
                            '이메일 인증하기',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () {
                            if (_user == null) {
                              needLogin(context);
                              return;
                            }
                            if (!_user.emailVerified) {
                              emailVerify(
                                user: _user,
                                context: context,
                              );
                            }
                          },
                        ),
                        const Tooltip(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          showDuration: Duration(seconds: 2),
                          message: '이메일 인증을 하시면\n'
                              '1. 비밀번호를 잊어버렸을 때 찾으실 수 있어요.\n'
                              '2. 더 많은 기록을 저장하실 수 있어요.\n'
                              '    - 현재 : 기록 최대 30개\n'
                              '    - 인증 후 : 무제한',
                          child: Icon(
                            Icons.help_outline,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              AskingWidget(
                provider: _userProvider,
                user: _user,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FindAuthScreen extends StatefulWidget {
  static const routeName = 'findauth';
  const FindAuthScreen({Key? key}) : super(key: key);

  @override
  State<FindAuthScreen> createState() => _FindAuthScreenState();
}

class _FindAuthScreenState extends State<FindAuthScreen> {
  final TextEditingController _textcontroller = TextEditingController();
  bool _validate = true;

  @override
  void dispose() {
    _textcontroller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이메일 전송 오류'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('아이디/비밀번호 찾기'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 12,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    '가입하셨던 이메일을 적어주세요.\n비밀번호를 재설정 할 수 있는 이메일을 보내드려요.\n이전에 인증하셨던 이메일만 가능합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                    width: double.maxFinite,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      maxLines: 1,
                      controller: _textcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: '이메일',
                        errorText: _validate ? null : '올바른 이메일을 입력해주세요.',
                      ),
                      onSubmitted: (value) {
                        _textcontroller.text = value;
                      },
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      String _temp = _textcontroller.text;
                      if (!_temp.contains('@')) {
                        if (_validate) {
                          setState(() {
                            _validate = false;
                          });
                        }
                        return;
                      } else if (!_temp.endsWith('.com') &&
                          !_temp.endsWith('.net')) {
                        if (_validate) {
                          setState(() {
                            _validate = false;
                          });
                        }
                        return;
                      } else {
                        setState(() {
                          _validate = true;
                        });
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: _temp,
                          );

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('전송 성공'),
                              content:
                                  const Text('해당 이메일로 가셔서,\n비밀번호를 다시 설정해주세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          ).then(
                            (value) => Navigator.of(context).pop(),
                          );
                        } on FirebaseAuthException catch (e) {
                          var errorMessage = '로그인 실패';
                          print(e);
                          if (e.code.contains('network-request-failed')) {
                            errorMessage = '인터넷 연결이 불안정합니다.\n다음에 다시 시도해주세요.';
                          } else if (e.code.contains('invalid-email')) {
                            errorMessage = '올바른 이메일 형식이 아닙니다.';
                          } else if (e.code.contains('user-not-found')) {
                            errorMessage = '해당 이메일로 가입된 계정이 없습니다.';
                          }
                          _showErrorDialog(errorMessage);
                        } catch (error) {
                          const errorMessage = '다음에 다시 시도해주세요.';
                          _showErrorDialog(errorMessage);
                        }
                      }
                    },
                    child: const Text(
                      '재설정 이메일 보내기',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

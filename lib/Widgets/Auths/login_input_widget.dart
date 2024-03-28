/// Packages ///
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/record.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/tab_bar_screen.dart';

class LoginInputWidget extends StatefulWidget {
  const LoginInputWidget({Key? key}) : super(key: key);

  @override
  _LoginInputWidgetState createState() => _LoginInputWidgetState();
}

class _LoginInputWidgetState extends State<LoginInputWidget> {
  final _formkey = GlobalKey<FormState>();
  String? _inputId, _inputPassword;
  bool _isLoading = false;
  bool _obscure = true;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그인 오류'),
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

  Future<void> saveform() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential _user =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _inputId!,
        password: _inputPassword!,
      );

      var _provider = Provider.of<UserInfoprovider>(context, listen: false);
      _provider.clearInfos();
      Provider.of<Record>(context, listen: false).clearRecords();
      await _provider.loadUserInfos(_user.user);

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(TabBarScreen.routeName);
    } on FirebaseAuthException catch (e) {
      var errorMessage = '로그인 실패';
      if (e.code.contains('wrong-password')) {
        errorMessage = '비밀번호가 틀립니다.';
      } else if (e.code.contains('network-request-failed')) {
        errorMessage = '인터넷 연결이 불안정합니다.\n다음에 다시 시도해주세요.';
      } else if (e.code.contains('invalid-email')) {
        errorMessage = '올바른 이메일 형식이 아닙니다.';
      } else if (e.code.contains('user-not-found')) {
        errorMessage = '해당 이메일로 가입된 계정이 없습니다.';
      }
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = '다음에 다시 시도해주세요.';

      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: SizedBox(
        height: 240,
        width: 280,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextFormField(
                    initialValue: _inputId,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                    ),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _inputId = value;
                    },
                    validator: (value) {
                      if (value == null ||
                          !value.contains('@') ||
                          !(value.endsWith('.com') || value.endsWith('.net'))) {
                        return '올바른 이메일을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _inputPassword,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    onSaved: (value) {
                      _inputPassword = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: saveform,
                    child: const Text(
                      '시작하기',
                      style: TextStyle(fontSize: 22),
                    ),
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(const Size.fromHeight(48)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

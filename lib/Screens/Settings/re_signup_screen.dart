import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/user_info.dart';

class ResignUpScreen extends StatefulWidget {
  static const routeName = '/ReSign_UpScreen';
  const ResignUpScreen({Key? key}) : super(key: key);

  @override
  _ResignUpScreenState createState() => _ResignUpScreenState();
}

class _ResignUpScreenState extends State<ResignUpScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey();
  String? _email, _password, _nickname;
  bool _isLoading = false;
  bool _obscure = true;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 정보 변경 오류'),
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

  Future<void> saveform(User? users) async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      var _provider = Provider.of<UserInfoprovider>(context, listen: false);
      UserInformations _userInfo = _provider.getUserInformagions;

      if (_nickname == _userInfo.nickname && _password == _userInfo.password) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
        return;
      }

      if (_nickname != _userInfo.nickname) {
        await FirebaseFirestore.instance
            .collection('checks')
            .where('nickname', isEqualTo: _nickname)
            .get()
            .then((value) async {
          if (value.size != 0) {
            throw Exception();
          } else {
            await FirebaseFirestore.instance
                .collection('checks')
                .doc(_email)
                .set({'nickname': _nickname});
          }
        });
      }

      _provider.changeUserInfo(
        changedNickname: _nickname,
        changedPassword: _password,
      );

      String _now = _provider.nowTime;
      _provider.uploadData(
        user: users,
        list: 'UserInformations',
        date: _now,
        map: {
          'email': _email,
          'password': _password,
          'nickname': _nickname,
          'imageFileName': _userInfo.imageFileName,
          'date': _now,
        },
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('회원 정보가 변경되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      var errorMessage = '회원 가입 실패';
      if (e.code.contains('network-request-failed')) {
        errorMessage = '인터넷 연결이 불안정합니다.\n다음에 다시 시도해주세요.';
      } else if (e.code.contains('weak-password')) {
        errorMessage = '비밀번호 보안이 약합니다.';
      }
      _showErrorDialog(errorMessage);
    } on Exception {
      const errorMessage = '이미 있는 닉네임입니다.';
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = '다음에 다시 시도해주세요.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('re signup');

    var _userInfo = Provider.of<UserInfoprovider>(context, listen: false)
        .getUserInformagions;
    _email = _userInfo.email;
    _password = _userInfo.password;
    User? _user = ModalRoute.of(context)!.settings.arguments as User?;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원 정보 변경'),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '잠시만 기다려주세요.',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF1568B3),
                        ),
                      ),
                      SizedBox(height: 12),
                      CircularProgressIndicator(),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Form(
                        key: _formkey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 32,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(
                                    width: 80,
                                    child: Text(
                                      '이메일',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextFormField(
                                      enabled: false,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                      initialValue: _email,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(
                                    width: 80,
                                    child: Text(
                                      '비밀번호',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: _password,
                                      obscureText: _obscure,
                                      decoration: InputDecoration(
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
                                      onChanged: (value) {
                                        _password = value;
                                      },
                                      onSaved: (value) {
                                        _password = value!;
                                      },
                                      validator: (v) {
                                        if (v == null || v.length < 6) {
                                          return '6자 이상의 비밀번호를 입력해주세요';
                                        }
                                        if (v.contains(' ')) {
                                          return '띄어쓰기 없이 비밀번호를 설정해주세요.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(
                                    width: 80,
                                    child: Text(
                                      '비밀번호 확인',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: _password,
                                      obscureText: true,
                                      validator: (v) {
                                        if (v != _password) {
                                          return '위 비밀번호와 다릅니다.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(
                                    width: 80,
                                    child: Text(
                                      '닉네임',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: _userInfo.nickname,
                                      onSaved: (value) {
                                        _nickname = value!;
                                      },
                                      validator: (v) {
                                        if (v == null || v.length < 2) {
                                          return '두 글자 이상의 닉네임을 지어주세요.';
                                        }
                                        if (v.contains(' ')) {
                                          return '띄어쓰기 없이 닉네임을 설정해주세요.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 60),
                              ElevatedButton(
                                onPressed: () => saveform(_user),
                                child: const Text(
                                  '변경하기',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(240, 48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

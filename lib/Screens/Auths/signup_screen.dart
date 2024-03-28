import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/record.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/tab_bar_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/Sign_UpScreen';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey();
  String? _email, _password, _nickname;
  bool _isLoading = false;
  bool _obscure = true;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 가입 오류'),
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
      print('1');
      await FirebaseFirestore.instance
          .collection('checks')
          .where('nickname', isEqualTo: _nickname)
          .get()
          .then((value) {
        if (value.size != 0) {
          throw Exception();
        }
      });

      print('2');

      UserCredential _user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );
      print('3');
      var _provider = Provider.of<UserInfoprovider>(context, listen: false);
      String _now = _provider.nowTime;

      await FirebaseFirestore.instance
          .collection('user_Info')
          .doc(_email)
          .collection('UserInformations')
          .doc(_now)
          .set(
        {
          'email': _email,
          'password': _password,
          'nickname': _nickname,
          'imageFileName': null,
          'date': _now,
        },
      );

      await FirebaseFirestore.instance
          .collection('user_Info')
          .doc(_email)
          .collection('HealthInformations')
          .doc(_now)
          .set(
        {
          'weight': null,
          'height': null,
          'headcircum': null,
          'bloodType': null,
          'gender': null,
          'year': null,
          'month': null,
          'date': null,
        },
      );
      await FirebaseFirestore.instance
          .collection('user_Info')
          .doc(_email)
          .collection('EvalInformations')
          .doc(_now)
          .set(
        {
          'bigMuscle': null,
          'smallMuscle': null,
          'language': null,
          'date': null,
        },
      );
      print('4');

      await FirebaseFirestore.instance
          .collection('checks')
          .doc(_email)
          .set({'nickname': _nickname});

      print('6');

      _provider.clearInfos();
      Provider.of<Record>(context, listen: false).clearRecords();
      await _provider.loadUserInfos(_user.user);

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(TabBarScreen.routeName);
    } on FirebaseAuthException catch (e) {
      var errorMessage = '회원 가입 실패';
      if (e.code.contains('email-already-in-use')) {
        errorMessage = '이미 사용 중인 이메일입니다.';
      } else if (e.code.contains('network-request-failed')) {
        errorMessage = '인터넷 연결이 불안정합니다.\n다음에 다시 시도해주세요.';
      } else if (e.code.contains('invalid-email')) {
        errorMessage = '올바른 이메일 형식이 아닙니다.';
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
    print('회원가입');
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원 가입'),
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
                                      initialValue: _email,
                                      onSaved: (value) {
                                        _email = value!;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null ||
                                            v.contains(' ') ||
                                            !v.contains('@') &&
                                                (!v.endsWith('.com') ||
                                                    !v.endsWith('.net'))) {
                                          return '올바른 이메일을 입력해주세요.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
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
                              const SizedBox(height: 28),
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
                              const SizedBox(height: 28),
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
                                      initialValue: _nickname,
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
                                onPressed: saveform,
                                child: const Text(
                                  '가입하기',
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

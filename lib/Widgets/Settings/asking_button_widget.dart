import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soaproject/Provider/user_info.dart';

class AskingWidget extends StatelessWidget {
  const AskingWidget({
    Key? key,
    required UserInfoprovider provider,
    required User? user,
  })  : _provider = provider,
        _user = user,
        super(key: key);

  final UserInfoprovider _provider;
  final User? _user;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.question_answer_outlined),
      label: const Text(
        '문의 / 건의하기',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            String? _askString;
            return Dialog(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                height: 420,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const Text(
                        '문의 / 건의',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                        ),
                        child: TextField(
                          autocorrect: false,
                          maxLength: 300,
                          maxLines: null,
                          onChanged: (input) {
                            _askString = input;
                          },
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (_askString == null) {
                                return;
                              }
                              _provider.askString(_askString!, _user);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content:
                                      Text('문의가 정상적으로 접수되었습니다.\n소중한 의견 감사합니다.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text(
                              '제출하기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1568B3),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB31568),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

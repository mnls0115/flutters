import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soaproject/Widgets/Eval/eval_more.dart';
import 'package:soaproject/Widgets/Eval/eval_widget.dart';

class EvaluationScreen extends StatelessWidget {
  static const routeName = '/Evaluation_Screen';
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int _currentmode =
        (ModalRoute.of(context)!.settings.arguments as List)[0];
    final User? _user = (ModalRoute.of(context)!.settings.arguments as List)[1];

    const List<String> _stringList = [
      '대근육 발달 평가',
      '소근육 발달 평가',
      '기타 발달 평가',
    ];

    /// Eval 처음 0,1,2는 대근육, 소근육, 기타를 뜻함.
    /// 뒤에 4개 숫자는 질문 number이며, 한페이지에 최대 4개 질문까지.

    final List<List<Widget>> _pageList = [
      [
        Eval(0, 0, 1, 2, 3, _user),
        Eval(0, 4, 5, 6, 7, _user),
        Eval(0, 8, 9, 10, null, _user),
      ],
      [
        Eval(1, 0, 1, 2, 3, _user),
        Eval(1, 4, 5, null, null, _user),
        Eval(1, 6, 7, null, null, _user),
      ],
      [
        Eval(2, 0, 1, 2, null, _user),
        Eval(2, 3, 4, 5, null, _user),
        Evalmore(_user),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_stringList[_currentmode]),
        backgroundColor: const Color(0xFF1568B3),
      ),
      body: PageView(
        children: _pageList[_currentmode],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'evaluation_screens.dart';

class EvaliationBeforeScreen extends StatelessWidget {
  static const routeName = '/Eval_before_Screen';
  const EvaliationBeforeScreen({Key? key}) : super(key: key);

  Widget commonText(String input) {
    return Text(
      input,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaquary = MediaQuery.of(context).size;
    User? _user = ModalRoute.of(context)!.settings.arguments as User?;
    print(_user);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            commonText('발달 평가를 해보세요.'),
            const SizedBox(height: 8),
            const Text(
              '해당 평가는 아이의 대략적인 발달 상황을 알기 위한 평가입니다.\n아이의 발달 상태에 대한 자세한 평가를 원하신다면, 가까운 병원이나 시설을 찾아가세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                EvaluationScreen.routeName,
                arguments: [0, _user],
              ),
              child: commonText('대근육 발달 평가'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                EvaluationScreen.routeName,
                arguments: [1, _user],
              ),
              child: commonText('소근육 발달 평가'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                EvaluationScreen.routeName,
                arguments: [2, _user],
              ),
              child: commonText('기타 발달 평가'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

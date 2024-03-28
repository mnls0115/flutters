import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/Evals/evaluation_before_screens.dart';
import 'package:soaproject/Widgets/HomeScreens/description_builder.dart';
import 'package:soaproject/Widgets/box_widget.dart';
import 'package:soaproject/Widgets/divider.dart';
import 'package:intl/intl.dart';

class InfoSubWidget2 extends StatelessWidget {
  final UserInformations userInfo;
  final HealthInformations healthInfo;
  final EvalInformations evalInfo;
  final User? user;
  final double width;

  const InfoSubWidget2({
    Key? key,
    required this.userInfo,
    required this.healthInfo,
    required this.evalInfo,
    required this.width,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _shortnickname = userInfo.nickname == null
        ? '손님'
        : userInfo.nickname!.length > 5
            ? '${userInfo.nickname!.substring(0, 5)}...'
            : userInfo.nickname!;

    print('page 1-2');
    return Column(
      children: [
        SizedBox(
          height: 36,
          child: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              EvaliationBeforeScreen.routeName,
              arguments: user,
            ),
            child: const Text(
              '발달 정보 입력',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const MyDivider(),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_shortnickname의 발달 정보 ',
                    style: const TextStyle(
                      fontSize: 22,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (evalInfo.date != null)
                    Text(
                      '(${DateFormat('yyyy.MM.dd').format(evalInfo.date!)} 기록 )',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              BoxWidget(
                value: evalInfo.bigMuscle,
                title: '대근육 발달',
                unit: '개월',
              ),
              const SizedBox(height: 8),
              BoxWidget(
                value: evalInfo.smallMuscle,
                title: '소근육 발달',
                unit: '개월',
              ),
              const SizedBox(height: 8),
              BoxWidget(
                value: evalInfo.language,
                title: '언어 발달',
                unit: '개월',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const MyDivider(),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: width * 0.8,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          alignment: Alignment.topCenter,
          child: const DescriptionBuilder(descriptions: []),
        ),
        const Spacer(),
        const Text('<  2 / 2  '),
      ],
    );
  }
}

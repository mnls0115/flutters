import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/health_input_Screen.dart';
import 'package:soaproject/Widgets/HomeScreens/description_builder.dart';
import 'package:soaproject/Widgets/box_widget.dart';
import 'package:soaproject/Widgets/divider.dart';
import 'package:intl/intl.dart';
import 'package:soaproject/Provider/health_info_enum.dart';

class InfoSubWidget1 extends StatelessWidget {
  final UserInformations userInfo;
  final HealthInformations healthInfo;
  final User? user;
  final double width;

  const InfoSubWidget1({
    Key? key,
    required this.userInfo,
    required this.healthInfo,
    required this.width,
    this.user,
  }) : super(key: key);

  Text _textWidget(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('page 1-1');
    bool _front = healthInfo.year != null || healthInfo.month != null;
    bool _back = healthInfo.gender != null || healthInfo.bloodType != null;
    String _shortnickname = userInfo.nickname == null
        ? '손님'
        : userInfo.nickname!.length > 5
            ? '${userInfo.nickname!.substring(0, 5)}...'
            : userInfo.nickname!;

    return Column(
      children: [
        if (_front || _back) const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (healthInfo.year != null) _textWidget('${healthInfo.year}년'),
            if (healthInfo.month != null) _textWidget(' ${healthInfo.month}개월'),
            if (_front && _back) _textWidget(', '),
            if (healthInfo.gender != null)
              _textWidget('${healthInfo.gender!.getGenderString}'),
            if (healthInfo.gender != null && healthInfo.bloodType != null)
              _textWidget(', '),
            if (healthInfo.bloodType != null)
              _textWidget('${healthInfo.bloodType!.getTypeString}'),
          ],
        ),
        SizedBox(
          height: 36,
          child: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              HealthInputScreen.routeName,
              arguments: user,
            ),
            child: const Text(
              '건강 정보 입력',
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
                    '$_shortnickname의 건강 정보 ',
                    style: const TextStyle(
                      fontSize: 22,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (healthInfo.date != null)
                    Text(
                      '(${DateFormat('yyyy.MM.dd').format(healthInfo.date!)}기록 )',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    )
                ],
              ),
              const SizedBox(height: 16),
              BoxWidget(
                value: healthInfo.height == null
                    ? null
                    : double.parse(healthInfo.height!.toStringAsFixed(1)),
                title: '키',
                unit: 'cm',
              ),
              const SizedBox(height: 8),
              BoxWidget(
                value: healthInfo.weight == null
                    ? null
                    : double.parse(healthInfo.weight!.toStringAsFixed(1)),
                title: '체중',
                unit: 'kg',
              ),
              const SizedBox(height: 8),
              BoxWidget(
                value: healthInfo.headcircum == null
                    ? null
                    : double.parse(healthInfo.headcircum!.toStringAsFixed(1)),
                title: '머리 둘레',
                unit: 'cm',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const MyDivider(),
        const SizedBox(height: 8),
        Container(
          width: width * 0.8,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 20,
          ),
          alignment: Alignment.topCenter,
          child: const DescriptionBuilder(descriptions: []),
        ),
        const Spacer(),
        const Text('  1 / 2  >'),
      ],
    );
  }
}

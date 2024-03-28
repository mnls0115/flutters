import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/eval_provider.dart';
import 'package:soaproject/Provider/user_info.dart';
import './question1.dart';

class Eval extends StatelessWidget {
  final int listtype, int1, int2;
  final int? int3, int4;
  final User? user;
  const Eval(
      this.listtype, this.int1, this.int2, this.int3, this.int4, this.user,
      {Key? key})
      : super(key: key);

  int get pageNum {
    if (listtype != 2) {
      if (int1 >= 6) {
        return 3;
      } else {
        return int1 ~/ 4 + 1;
      }
    } else {
      if (int1 == 0) {
        return 1;
      }
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('eval widget');
    var mediaquary = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      height: mediaquary.height,
      width: mediaquary.width,
      child: Column(children: [
        Question1(
          listtype: listtype,
          index: int1,
        ),
        const SizedBox(height: 40),
        Question1(
          listtype: listtype,
          index: int2,
        ),
        if (int3 != null) const SizedBox(height: 40),
        if (int3 != null)
          Question1(
            listtype: listtype,
            index: int3!,
          ),
        if (int4 != null) const SizedBox(height: 40),
        if (int4 != null)
          Question1(
            listtype: listtype,
            index: int4!,
          ),
        const Spacer(),
        if (pageNum == 3)
          ElevatedButton(
            onPressed: () async {
              var _provider = Provider.of<EvalProdiver>(context, listen: false);

              await _provider
                  .saveEvalInfo(
                context: context,
                listtype: listtype,
                user: user,
              )
                  .then((_) {
                List<int> _monthList = _provider.getMonthList();
                Provider.of<UserInfoprovider>(context, listen: false)
                    .tempEvalInformagions(EvalInformations(
                  bigMuscle: _monthList[0],
                  smallMuscle: _monthList[1],
                  language: _monthList[2],
                  date: DateTime.now(),
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('평가가 완료되었습니다.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('제출하기'),
          ),
        const SizedBox(height: 20),
        Text('$pageNum / 3'),
      ]),
    );
  }
}

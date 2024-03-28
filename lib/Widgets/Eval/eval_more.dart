import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/eval_provider.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Widgets/Eval/radio_button.dart';

class Evalmore extends StatelessWidget {
  final User? user;
  const Evalmore(
    this.user, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object?>> _list =
        Provider.of<EvalProdiver>(context).getList(2);
    String? _groupvalue = _list[6]['value'] as String?;

    void _changeFx(String val) {
      print(val);
      Provider.of<EvalProdiver>(context, listen: false).editList(2, 6, val);
    }

    var mediaquary = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 40,
      ),
      height: mediaquary.height,
      width: mediaquary.width,
      child: Consumer<EvalProdiver>(
        builder: ((context, value, child) => Column(
              children: [
                const Text(
                  '7. 환아의 언어 기능이\n대략적으로 어디에 해당하나요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                RadiobuttonWidgett(
                  inputvalue: '3',
                  groupvalue: _groupvalue,
                  inputString: '모음 위주의 옹알이 (으아, 아 등)',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '8',
                  groupvalue: _groupvalue,
                  inputString: '‘맘맘’, ‘빠빠’ 등 자음이 포함된 옹알이',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '10',
                  groupvalue: _groupvalue,
                  inputString: '‘엄마’만 할 수 있음',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '12',
                  groupvalue: _groupvalue,
                  inputString: '‘엄마’, ‘아빠’ 등 간단한 단어 10개 정도',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '16',
                  groupvalue: _groupvalue,
                  inputString: '‘물 줘’ 등 두 개의 단어를 붙여서 말함',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '22',
                  groupvalue: _groupvalue,
                  inputString: '‘엄마 이건 뭐야’ 등 3단어 이상 간단한 대화 ',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '24',
                  groupvalue: _groupvalue,
                  inputString: '일상적인 의사소통에 문제가 없음',
                  function: _changeFx,
                ),
                RadiobuttonWidgett(
                  inputvalue: '?',
                  groupvalue: _groupvalue,
                  inputString: '모름',
                  function: _changeFx,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    var _provider =
                        Provider.of<EvalProdiver>(context, listen: false);
                    await _provider
                        .saveEvalInfo(
                      context: context,
                      listtype: 2,
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
                const Text('3 / 3')
              ],
            )),
      ),
    );
  }
}

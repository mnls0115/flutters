import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/user_info.dart';

class EvalProdiver with ChangeNotifier {
  final List<int> _evalMonthList = [0, 0, 0];
  final List<List<Map<String, Object?>>> _evalList = [
    [
      {'value': null, 'Q': '1. 목을 가눌 수 있나요?', 'month': 3},
      {'value': null, 'Q': '2. 뒤집기/되집기가 가능한가요?', 'month': 4},
      {'value': null, 'Q': '3. 팔을 짚고 앉을 수 있나요?', 'month': 5},
      {'value': null, 'Q': '4. 팔을 짚지 않고 앉을 수 있나요?', 'month': 7},
      {'value': null, 'Q': '5. 배밀이가 가능한가요?', 'month': 7},
      {'value': null, 'Q': '6. 네 발 기기가 가능한가요?', 'month': 8},
      {'value': null, 'Q': '7. 잡은 상태로 서있을 수 있나요?', 'month': 9},
      {'value': null, 'Q': '8. 가구나 책상 등을 짚고\n옆으로 이동할 수 있나요?', 'month': 10},
      {'value': null, 'Q': '9. 혼자 걸을 수 있나요?', 'month': 12},
      {'value': null, 'Q': '10. 달리기가 가능한가요?', 'month': 15},
      {'value': null, 'Q': '11. 난간을 잡고\n계단 오를 수 있나요?', 'month': 18}
    ],
    [
      {'value': null, 'Q': '1. 딸랑이를 쥐어주면 입으로 가져가나요?', 'month': 4},
      {'value': null, 'Q': '2. 장난감을 보면서 잡을 수 있나요?', 'month': 5},
      {'value': null, 'Q': '3. 두 물건을 양손에 각각 따로 쥘 수 있나요?', 'month': 5},
      {'value': null, 'Q': '4. 한 손으로 물건을 쥐고\n반대쪽 손으로 옮길 수 있나요?', 'month': 7},
      {'value': null, 'Q': '5. 손잡이로 컵을 쥘 수 있나요?', 'month': 9},
      {'value': null, 'Q': '6. 엄지와 검지 손가락을 이용하여\n물건을 집을 수 있나요?', 'month': 9},
      {'value': null, 'Q': '7. 손을 이용하여\n물건을 상자에 넣고 뺄 수 있나요?', 'month': 12},
      {'value': null, 'Q': '8. 입방체를 2개 쌓을 수 있나요?', 'month': 15},
    ],
    [
      {'value': null, 'Q': '1. 소리가 나는 곳을 쳐다보나요?', 'month': 2},
      {'value': null, 'Q': '2. 소리내어 웃나요?', 'month': 3},
      {'value': null, 'Q': '3. 움직이는 사물을 보고\n눈을 따라가나요?', 'month': 3},
      {'value': null, 'Q': '4. 이름을 부르면 반응하나요?', 'month': 5},
      {'value': null, 'Q': '5. ‘바이바이’, ‘까꿍’ 등을\n 할 수 있나요?', 'month': 9},
      {'value': null, 'Q': '6. ‘엄마’, ‘아빠’를\n 할 수 있나요?', 'month': 10},
      {'value': null, 'Q': '7. 환아의 언어 기능이 대략적으로\n어디에 해당하나요?', 'month': 0}
    ],
  ];

  List<Map<String, Object?>> getList(int listtype) {
    return _evalList[listtype];
  }

  List<int> getMonthList() {
    return _evalMonthList;
  }

  void editList(
    int listtype,
    int listindex,
    String? value,
  ) {
    _evalList[listtype][listindex]['value'] = value;
    notifyListeners();
  }

  List<List<String?>> get extractInfo {
    List<List<String?>> _tempList = [[], [], []];
    for (var i = 0; i < 3; i++) {
      for (var e in _evalList[i]) {
        _tempList[i].add(e['value'] as String?);
      }
    }
    return _tempList;
  }

  void resetInfos() {
    for (var i = 0; i < 3; i++) {
      for (var e in _evalList[i]) {
        e['value'] = null;
      }
    }
    notifyListeners();
  }

  Future<void> saveEvalInfo({
    required BuildContext context,
    required int listtype,
    User? user,
  }) async {
    String date = DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
    List<List<String?>> _extractedList = extractInfo;
    List<int> _evalMonthList = evaluation(
      extractedInfo: _extractedList,
      listtype: listtype,
    );

    var _provider = Provider.of<UserInfoprovider>(context, listen: false);
    EvalInformations _evalInfo = _provider.getEvalInformagions;
    EvalInformations _tempEval = _evalInfo.copywith(
      redate: DateTime.parse(date),
      inputbigmuscle: _evalMonthList[0],
      inputsmallmuscle: _evalMonthList[1],
      inputlanguage: _evalMonthList[2],
    );
    _provider.tempEvalInformagions(_tempEval);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_Info')
          .doc(user.email)
          .collection('Z_Evaluation_answers_$listtype')
          .doc(date)
          .set({
        'date': date,
        'eval_informations': _extractedList[listtype],
      });

      await FirebaseFirestore.instance
          .collection('user_Info')
          .doc(user.email)
          .collection('EvalInformations')
          .doc(date)
          .set({
        'bigMuscle': _tempEval.bigMuscle,
        'smallMuscle': _tempEval.smallMuscle,
        'language': _tempEval.language,
        'date': date,
      });
    }

    resetInfos();
    notifyListeners();
  }

  List<int> evaluation({
    required List<List<String?>> extractedInfo,
    required int listtype,
  }) {
    print('evaluation');
    List<int> _tempList = [0, 0, 0];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < extractedInfo[i].length; j++) {
        String? val = extractedInfo[i][j];
        if (i == 2 && j == 6 && val != null && val != '?') {
          _tempList[2] = max(_tempList[2], int.parse(val));
        } else if (val != 'y') {
          continue;
        } else if (i == 0) {
          _tempList[0] = max(_tempList[0], _evalList[0][j]['month'] as int);
        } else if (i == 1) {
          _tempList[1] = max(_tempList[1], _evalList[1][j]['month'] as int);
        } else {
          _tempList[2] = max(_tempList[2], _evalList[2][j]['month'] as int);
        }
      }
    }
    return _tempList;
  }
}

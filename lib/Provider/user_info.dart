import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'health_info_enum.dart';

class UserInformations {
  String? email, password, nickname, imageFileName;
  DateTime? date;

  UserInformations({
    this.email,
    this.password,
    this.nickname,
    this.date,
    this.imageFileName,
  });

  UserInformations usercopyWith({
    required DateTime redate,
    String? inputpassword,
    String? inputnickname,
    String? inputimageFileName,
  }) {
    return UserInformations(
      date: redate,
      email: email,
      password: inputpassword ?? password,
      nickname: inputnickname ?? nickname,
      imageFileName: inputimageFileName ?? imageFileName,
    );
  }
}

class HealthInformations {
  int? year, month;
  double? weight, height, headcircum;
  Gender? gender;
  BloodType? bloodType;
  DateTime? date;

  HealthInformations({
    this.weight,
    this.height,
    this.headcircum,
    this.gender,
    this.bloodType,
    this.year,
    this.month,
    this.date,
  });
}

class EvalInformations {
  int? bigMuscle, smallMuscle, language;
  DateTime? date;

  EvalInformations({
    this.bigMuscle,
    this.smallMuscle,
    this.language,
    this.date,
  });

  EvalInformations copywith({
    required DateTime redate,
    required int inputbigmuscle,
    required int inputsmallmuscle,
    required int inputlanguage,
  }) {
    return EvalInformations(
      date: redate,
      bigMuscle: inputbigmuscle == 0 ? bigMuscle : inputbigmuscle,
      smallMuscle: inputsmallmuscle == 0 ? smallMuscle : inputsmallmuscle,
      language: inputlanguage == 0 ? language : inputlanguage,
    );
  }
}

class UserInfoprovider with ChangeNotifier {
  UserInformations _userInformations = UserInformations();
  HealthInformations _healthInformations = HealthInformations();
  EvalInformations _evalInformations = EvalInformations();

  String formatDate(DateTime time) {
    return DateFormat('yyyy-MM-dd hh:mm').format(time);
  }

  String get nowTime {
    return DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
  }

  UserInformations get getUserInformagions {
    return _userInformations;
  }

  HealthInformations get getHealthInformagions {
    return _healthInformations;
  }

  EvalInformations get getEvalInformagions {
    return _evalInformations;
  }

  void tempHealthInformagions(HealthInformations healthInformations) {
    _healthInformations = healthInformations;
    notifyListeners();
  }

  void tempEvalInformagions(EvalInformations evalInformations) {
    _evalInformations = _evalInformations.copywith(
      redate: DateTime.parse(nowTime),
      inputbigmuscle: evalInformations.bigMuscle ?? 0,
      inputsmallmuscle: evalInformations.smallMuscle ?? 0,
      inputlanguage: evalInformations.language ?? 0,
    );

    notifyListeners();
  }

  Map<String, String?> get userInfotoShared {
    return {
      'email': _userInformations.email,
      'password': _userInformations.password,
      'nickname': _userInformations.nickname,
      'imageFileName': _userInformations.imageFileName,
      'date': DateFormat('yyyy-MM-dd hh:mm').format(_userInformations.date!),
    };
  }

  Future<void> loadUserInfos(User? user) async {
    print('loadUserInfos');

    if (user == null) {
      return;
    }

    print('----------------------------------------------------');

    await FirebaseFirestore.instance
        .collection('user_Info')
        .doc(user.email)
        .collection('UserInformations')
        .orderBy("date", descending: true)
        .limit(1)
        .get()
        .then((value) {
      var temp1 = value.docs.single;
      _userInformations = UserInformations(
        email: temp1['email'],
        password: temp1['password'],
        nickname: temp1['nickname'],
        imageFileName: temp1['imageFileName'],
        date: DateTime.parse(temp1['date']),
      );
    });

    await FirebaseFirestore.instance
        .collection('user_Info')
        .doc(user.email)
        .collection('HealthInformations')
        .orderBy("date", descending: true)
        .limit(1)
        .get()
        .then((value) {
      var temp2 = value.docs.single;
      _healthInformations = HealthInformations(
        weight: temp2['weight'],
        height: temp2['height'],
        headcircum: temp2['headcircum'],
        year: temp2['year'],
        month: temp2['month'],
        gender: (temp2['gender'] as String?)?.getStringGender,
        bloodType: (temp2['bloodType'] as String?)?.getStringType,
        date: temp2['date'] == null ? null : DateTime.parse(temp2['date']),
      );
    });

    await FirebaseFirestore.instance
        .collection('user_Info')
        .doc(user.email)
        .collection('EvalInformations')
        .orderBy("date", descending: true)
        .limit(1)
        .get()
        .then((value) {
      var temp3 = value.docs.single;
      _evalInformations = EvalInformations(
        bigMuscle: temp3['bigMuscle'],
        smallMuscle: temp3['smallMuscle'],
        language: temp3['language'],
        date: temp3['date'] == null ? null : DateTime.parse(temp3['date']),
      );
    });

    notifyListeners();
    return;
  }

  Future<void> uploadData({
    required String list,
    required String date,
    required Map<String, dynamic> map,
    User? user,
  }) async {
    print('uploadData');

    await FirebaseFirestore.instance
        .collection('user_Info')
        .doc(user!.email)
        .collection(list)
        .doc(date)
        .set(map);
  }

  Future<void> changeUserInfo({
    String? fileName,
    String? changedPassword,
    String? changedNickname,
  }) async {
    print('changeUserInfo');
    String now = nowTime;

    UserInformations _temp = _userInformations.usercopyWith(
      redate: DateTime.parse(now),
      inputimageFileName: fileName,
      inputnickname: changedNickname,
      inputpassword: changedPassword,
    );

    _userInformations = _temp;

    await FirebaseFirestore.instance
        .collection('user_Info')
        .doc(_userInformations.email)
        .collection('UserInformations')
        .doc(now)
        .set({
      'email': _userInformations.email,
      'date': now,
      'imageFileName': _userInformations.imageFileName,
      'nickname': _userInformations.nickname,
      'password': _userInformations.password,
    }).then((value) async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('User_informations', jsonEncode(userInfotoShared));
      return;
    });

    notifyListeners();
  }

  void clearInfos() {
    print('clearInfos');
    _userInformations = UserInformations(nickname: '손님');
    _healthInformations = HealthInformations();
    _evalInformations = EvalInformations();
    notifyListeners();
  }

  Future<void> askString(
    String askString,
    User? loginUser,
  ) async {
    print('askString');
    String _email = 'Anonymous';
    if (loginUser != null) {
      _email = loginUser.email!;
    }

    await FirebaseFirestore.instance
        .collection('Ask')
        .doc(DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()))
        .set({
      'user': _email,
      'content': askString,
    });
  }

  Future<void> getDescriptions(
    User? user,
  ) async {
    if (user == null) {}
  }
}

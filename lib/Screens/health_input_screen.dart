import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/health_info_enum.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Screens/tab_bar_screen.dart';

class HealthInputScreen extends StatefulWidget {
  static const routeName = '/Health_Input_Screen';
  const HealthInputScreen({Key? key}) : super(key: key);

  @override
  State<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends State<HealthInputScreen> {
  final GlobalKey<FormBuilderState> _formkey = GlobalKey();
  int? _year, _month;
  Gender? _gender;
  BloodType? _bloodType;
  double? _height, _weight, _headCircum;
  User? _user;

  Future<void> saveform() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();

    var _provider = Provider.of<UserInfoprovider>(context, listen: false);
    String _now = _provider.nowTime;
    HealthInformations _temp = HealthInformations(
      year: _year,
      month: _month,
      gender: _gender,
      bloodType: _bloodType,
      height: _height,
      weight: _weight,
      headcircum: _headCircum,
      date: DateTime.now(),
    );

    if (_user != null) {
      await _provider.uploadData(
        user: _user,
        list: 'HealthInformations',
        date: _now,
        map: {
          'weight': _temp.weight,
          'height': _temp.height,
          'headcircum': _temp.headcircum,
          'bloodType': _temp.bloodType?.getTypeString,
          'gender': _temp.gender?.getGenderString,
          'year': _temp.year,
          'month': _temp.month,
          'date': _now,
        },
      );
    }

    Provider.of<UserInfoprovider>(context, listen: false)
        .tempHealthInformagions(_temp);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('건강 정보가 입력되었습니다.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, TabBarScreen.routeName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HealthInformations _initHealth =
        Provider.of<UserInfoprovider>(context, listen: false)
            .getHealthInformagions;
    _year = _initHealth.year;
    _month = _initHealth.month;
    _gender = _initHealth.gender;
    _bloodType = _initHealth.bloodType;
    _height = _initHealth.height;
    _weight = _initHealth.weight;
    _headCircum = _initHealth.headcircum;
  }

  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context)!.settings.arguments as User?;
    print('heal input');

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('건강 정보 입력'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                FormBuilder(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '성별',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: FormBuilderDropdown(
                                initialValue: _gender?.getGenderString,
                                name: '성별',
                                onSaved: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  value as String;
                                  _gender = value.getStringGender;
                                },
                                items: [
                                  '남아',
                                  '여아',
                                  '지금은 비워둘래요.',
                                ].map((gender) {
                                  return DropdownMenuItem(
                                    alignment: Alignment.center,
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '현재 나이',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 96,
                              height: 48,
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                initialValue: _year?.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: '년',
                                ),
                                onSaved: (value) {
                                  if (value == null ||
                                      int.tryParse(value) == null) {
                                    _year = null;
                                    return;
                                  }
                                  _year = int.parse(value);
                                },
                                validator: (v) {
                                  if (v != null &&
                                      int.tryParse(v) != null &&
                                      (int.parse(v) > 99 || int.parse(v) < 0)) {
                                    return '올바른 년 수가 아니에요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 96,
                              height: 48,
                              child: TextFormField(
                                initialValue: _month?.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: '개월',
                                ),
                                onSaved: (value) {
                                  if (value == null ||
                                      int.tryParse(value) == null) {
                                    _month = null;
                                    return;
                                  }
                                  _month = int.parse(value);
                                },
                                validator: (v) {
                                  if (v != null &&
                                      int.tryParse(v) != null &&
                                      (int.parse(v) > 12 || int.parse(v) < 0)) {
                                    return '올바른 개월 수가 아니에요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '혈액형',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: FormBuilderDropdown(
                                initialValue: _bloodType?.getTypeString,
                                name: '혈액형',
                                onSaved: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  value as String;
                                  _bloodType = value.getStringType;
                                  return;
                                },
                                items: [
                                  'A +',
                                  'A -',
                                  'B +',
                                  'B -',
                                  'O +',
                                  'O -',
                                  'AB +',
                                  'AB -',
                                  '지금은 비워둘래요.',
                                ].map((item) {
                                  return DropdownMenuItem(
                                    alignment: Alignment.center,
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '키',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: TextFormField(
                                initialValue: _height?.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'cm',
                                ),
                                onSaved: (value) {
                                  if (value == null ||
                                      double.tryParse(value) == null) {
                                    _height = null;
                                    return;
                                  }
                                  _height = double.parse(value);
                                },
                                validator: (v) {
                                  if (v != null &&
                                      double.tryParse(v) != null &&
                                      (double.parse(v) > 300 ||
                                          double.parse(v) < 0)) {
                                    return '올바른 키를 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '몸무게',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: TextFormField(
                                initialValue: _weight?.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'kg',
                                ),
                                onSaved: (value) {
                                  if (value == null ||
                                      double.tryParse(value) == null) {
                                    _weight = null;
                                    return;
                                  }
                                  _weight = double.parse(value);
                                },
                                validator: (v) {
                                  if (v != null &&
                                      double.tryParse(v) != null &&
                                      (double.parse(v) > 200 ||
                                          double.parse(v) < 0)) {
                                    return '올바른 몸무게를 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '머리 둘레',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: TextFormField(
                                initialValue: _headCircum?.toString(),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'cm',
                                ),
                                onSaved: (value) {
                                  if (value == null ||
                                      double.tryParse(value) == null) {
                                    _headCircum = null;
                                    return;
                                  }
                                  _headCircum = double.parse(value);
                                },
                                validator: (v) {
                                  if (v != null &&
                                      double.tryParse(v) != null &&
                                      (double.parse(v) > 100 ||
                                          double.parse(v) < 0)) {
                                    return '올바른 머리 둘레를 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          '알고 계신 것만 채우셔도 돼요.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: saveform,
                          child: const Text(
                            '입력하기',
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

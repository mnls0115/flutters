import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/record.dart';

class RecordScreen extends StatefulWidget {
  static const routeName = '/recordPage';
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final GlobalKey<FormBuilderState> _formkey = GlobalKey();
  int? _inputType;
  User? _user;
  DateTime _date = DateTime.now();
  DateTime? _temp;
  String? _inputString;
  Key? _key;
  bool _changedEdit = false;
  Event? _previusEvent;
  final _formatter = DateFormat('MM.dd');
  static const List _list = ['복용 기록', '식사 기록', '대소변 기록'];

  Future<void> saveform() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();

    Event _event = Event(
      date: _date,
      recordType: _inputType!,
      title: _inputString!,
      key: _key ?? ValueKey('$_date, $_inputString'),
    );

    var _provider = Provider.of<Record>(context, listen: false);

    if (_changedEdit) {
      await _provider.deleteRecord(
        event: _previusEvent!,
        user: _user,
      );
      _provider.addRecord(_event, true);
    } else {
      _provider.addRecord(_event, true);
    }

    if (_user != null) {
      await _provider.uploadRecord(
        event: _event,
        user: _user,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('기록이 입력되었습니다.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool _isEditMode = true;

    if (!_changedEdit) {
      Map<String, dynamic> _argMap =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _user = _argMap['user'] as User?;

      if (_argMap['date'] != null) {
        _inputType = _argMap['type'] as int;
        _date = _argMap['date'] as DateTime;
        _inputString = _argMap['title'] as String;
        _key = _argMap['key'] as Key;

        _previusEvent = Event(
            date: _date,
            title: _inputString!,
            recordType: _inputType!,
            key: _key!);
      }
      _isEditMode = _argMap['isEditMode'] as bool;
    }

    String _noon = _date.hour > 11 ? '오후' : '오전';
    String _today =
        _formatter.format(_date) == _formatter.format(DateTime.now())
            ? '오늘'
            : _formatter.format(_date);

    print('Screen record input');

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? '기록하기' : '기록'),
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
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '기록 종류',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: FormBuilderDropdown(
                                enabled: _isEditMode ? true : false,
                                initialValue: _inputType == null
                                    ? null
                                    : _list[_inputType!],
                                name: '기록 종류',
                                onChanged: (value) {
                                  if (value == '복용 기록') {
                                    _inputType = 0;
                                  } else if (value == '식사 기록') {
                                    _inputType = 1;
                                  } else {
                                    _inputType = 2;
                                  }
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return '어느 기록인지 정해주세요.';
                                  }
                                  return null;
                                },
                                items: _list.map((recordType) {
                                  return DropdownMenuItem(
                                    alignment: Alignment.center,
                                    value: recordType,
                                    child: Text(
                                      recordType,
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            const SizedBox(
                              width: 80,
                              child: Text(
                                '기록 시간',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 180,
                              height: 48,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat('$_today $_noon hh : mm  ')
                                        .format(_date),
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 1,
                                    width: 180,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              child: !_isEditMode
                                  ? null
                                  : IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isDismissible: false,
                                          context: context,
                                          builder: (context) => Container(
                                            color: Colors.white,
                                            height: 280,
                                            width: 400,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          _temp = null;
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          '취소',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_temp != null) {
                                                              _date = _temp!;
                                                            }
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          '확인',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: CupertinoDatePicker(
                                                    onDateTimeChanged: (value) {
                                                      _temp = value;
                                                    },
                                                    initialDateTime: _date,
                                                    minimumDate:
                                                        DateTime(2022, 1, 1),
                                                    maximumDate:
                                                        DateTime(2022, 12, 31),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: const [
                            SizedBox(width: 8),
                            Text(
                              '기록 내용',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 340,
                          width: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black38),
                          ),
                          child: FormBuilderTextField(
                            enabled: _isEditMode ? true : false,
                            name: '기록',
                            initialValue: _inputString,
                            maxLines: null,
                            maxLength: 200,
                            keyboardType: TextInputType.multiline,
                            autocorrect: false,
                            style: const TextStyle(
                              letterSpacing: 1,
                              wordSpacing: 1,
                              fontSize: 18,
                            ),
                            validator: (value) {
                              if (value == null || value.trim() == '') {
                                return '기록을 입력해주세요.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _inputString = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        _isEditMode
                            ? ElevatedButton(
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
                              )
                            : TextButton(
                                onPressed: () {
                                  setState(() {
                                    _changedEdit = true;
                                    _isEditMode = true;
                                  });
                                },
                                child: const Text('수정하기'),
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

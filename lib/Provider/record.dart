import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final int recordType;
  final DateTime date;
  final Key key;

  const Event({
    required this.date,
    required this.title,
    required this.recordType,
    required this.key,
  });

  @override
  String toString() => jsonEncode({
        'date': date.toIso8601String(),
        'title': title,
        'type': recordType,
        'key': key.toString(),
      });
}

class Record with ChangeNotifier {
  Map<String, List<Event>> _drugList = {},
      _mealList = {},
      _toiletList = {},
      _eventList = {};

  Map<String, List<Event>> get drugList {
    return {..._drugList};
  }

  Map<String, List<Event>> get mealList {
    return {..._mealList};
  }

  Map<String, List<Event>> get toiletList {
    return {..._toiletList};
  }

  Map<String, List<Event>> get eventList {
    return _eventList;
  }

  /// 0 = drug, 1 = meal, 2 = toilet ///
  Map<String, List<Event>> mapByType(int type, [bool isEdit = false]) {
    switch (type) {
      case 0:
        if (!isEdit) return drugList;
        return _drugList;
      case 1:
        if (!isEdit) return mealList;
        return _mealList;
      case 2:
        if (!isEdit) return toiletList;
        return _toiletList;
      default:
        return {};
    }
  }

  Future<void> deleteRecord({
    required Event event,
    User? user,
  }) async {
    print('deleteRecord');
    var _targetList = mapByType(event.recordType, true);
    String date = DateFormat('yyyy-MM-dd hh:mm').format(event.date);
    String _eventDate = date.substring(0, 10);

    if (!_targetList.containsKey(date)) {
      return;
    }

    _targetList[date]!.removeWhere((element) => element.key == event.key);
    _eventList[_eventDate]!.removeWhere((element) => element.key == event.key);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_Records')
          .doc(user.email)
          .collection('Records_${event.recordType}')
          .doc(date)
          .delete();
    }
    notifyListeners();
  }

  void addRecord(Event event, [bool nofity = false]) {
    print('addRecord');
    var _targetList = mapByType(event.recordType, true);
    String date = DateFormat('yyyy-MM-dd hh:mm').format(event.date);
    String _eventDate = date.substring(0, 10);

    if (_targetList.containsKey(date)) {
      int idx =
          _targetList[date]!.indexWhere((element) => element.key == event.key);
      if (idx >= 0) {
        return;
      }
      _targetList[date]!.add(event);
      _eventList[_eventDate]!.add(event);
    } else {
      _targetList[date] = [event];
      if (_eventList.containsKey(_eventDate)) {
        _eventList[_eventDate]!.add(event);
      } else {
        _eventList[_eventDate] = [event];
      }
    }

    if (nofity) {
      notifyListeners();
    }
  }

  Future<void> downloadRecords(User? user) async {
    print('downloadRecords');
    if (user == null) {
      return;
    }

    if (_eventList.isNotEmpty) {
      return;
    }

    print('---------------------------------------');

    for (int i = 0; i < 3; i++) {
      var temp = await FirebaseFirestore.instance
          .collection('user_Records')
          .doc(user.email)
          .collection('Records_$i')
          .orderBy("date", descending: true)
          .limit(user.emailVerified ? 300 : 30)
          .get();

      for (var element in temp.docs) {
        addRecord(
          Event(
            date: DateTime.parse(element['date']),
            title: element['title'],
            recordType: i,
            key: ValueKey(
                element['key'].substring(3, element['key'].length - 3)),
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> uploadRecord({
    required Event event,
    User? user,
  }) async {
    print('uploadRecord');
    String date = DateFormat('yyyy-MM-dd hh:mm').format(event.date);
    await FirebaseFirestore.instance
        .collection('user_Records')
        .doc(user!.email)
        .collection('Records_${event.recordType}')
        .doc(date)
        .set({
      'date': date,
      'title': event.title,
      'key': event.key.toString(),
    });
  }

  void clearRecords() {
    _drugList = {};
    _mealList = {};
    _toiletList = {};
    _eventList = {};
    notifyListeners();
  }
}

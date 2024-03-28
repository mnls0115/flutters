import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Board {
  final String title, contents, nickname;
  final Key? key;
  final String? imageUrl;
  final DateTime date;
  int recommand, reply;

  Board({
    required this.title,
    required this.contents,
    required this.imageUrl,
    required this.nickname,
    required this.date,
    this.recommand = 0,
    this.reply = 0,
    this.key,
  });
}

class Reply {
  final String contents, nickname;
  final Key? key;
  final DateTime date;

  Reply({
    required this.nickname,
    required this.contents,
    required this.date,
    this.key,
  });
}

class BoardProvider with ChangeNotifier {
  final List<Board> _boardList = [];
  List<Reply> _replyList = [];

  List<Board> get boardlist {
    return [..._boardList];
  }

  List<Reply> get replyList {
    return [..._replyList];
  }

  Future<void> updateBoard(Board board) async {
    print('updateBoard');
    String _then = DateFormat('yyyy-MM-dd hh:mm:ss').format(board.date);

    var _temp =
        await FirebaseFirestore.instance.collection('Boards').doc(_then).get();
    Map<String, dynamic> _tempmap = _temp.data()!;

    int idx = _boardList.indexWhere((element) => element.key == board.key);

    _boardList[idx] = Board(
      title: _tempmap['title'],
      contents: _tempmap['contents'],
      imageUrl: _tempmap['imageUrl'],
      nickname: _tempmap['nickname'],
      date: DateTime.parse(_tempmap['date']),
      recommand: _tempmap['recommand'].length,
      reply: _tempmap['reply'],
      key: ValueKey(_tempmap['key'].substring(3, _tempmap['key'].length - 3)),
    );

    var _temp2 = await FirebaseFirestore.instance
        .collection('Boards')
        .doc(_then)
        .collection('Replys')
        .get();

    _replyList = [];

    for (var element in _temp2.docs) {
      _tempmap = element.data();
      if (_replyList.any((element) =>
          element.key ==
          ValueKey(_tempmap['key'].substring(3, _tempmap['key'].length - 3)))) {
        continue;
      } else {
        _replyList.add(
          Reply(
            nickname: _tempmap['nickname'],
            contents: _tempmap['contents'],
            date: DateTime.parse(_tempmap['date']),
            key: ValueKey(
                _tempmap['key'].substring(3, _tempmap['key'].length - 3)),
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> getBoardList() async {
    if (_boardList.isNotEmpty) {
      print('getBoardList - little');
      String _then =
          DateFormat('yyyy-MM-dd hh:mm:ss').format(_boardList[0].date);

      var _collection = await FirebaseFirestore.instance
          .collection('Boards')
          .where('date', isEqualTo: _then)
          .get();

      DocumentSnapshot _doc = _collection.docs.single;
      QuerySnapshot _temp = await FirebaseFirestore.instance
          .collection('Boards')
          .orderBy('date', descending: true)
          .endBeforeDocument(_doc)
          .get();

      for (var element in _temp.docs.reversed) {
        print('repete');
        Map<String, dynamic> _tempmap = element.data() as Map<String, dynamic>;
        if (_boardList.any((element) =>
            element.key ==
            ValueKey(
                _tempmap['key'].substring(3, _tempmap['key'].length - 3)))) {
          continue;
        } else {
          _boardList.insert(
              0,
              Board(
                title: _tempmap['title'],
                contents: _tempmap['contents'],
                imageUrl: _tempmap['imageUrl'],
                nickname: _tempmap['nickname'],
                date: DateTime.parse(_tempmap['date']),
                recommand: _tempmap['recommand'].length,
                reply: _tempmap['reply'],
                key: ValueKey(
                    _tempmap['key'].substring(3, _tempmap['key'].length - 3)),
              ));
        }
      }
    } else {
      print('getBoardList');
      QuerySnapshot _temp = await FirebaseFirestore.instance
          .collection('Boards')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      for (var element in _temp.docs) {
        Map<String, dynamic> _tempmap = element.data() as Map<String, dynamic>;
        _boardList.add(Board(
          title: _tempmap['title'],
          contents: _tempmap['contents'],
          imageUrl: _tempmap['imageUrl'],
          nickname: _tempmap['nickname'],
          date: DateTime.parse(_tempmap['date']),
          recommand: _tempmap['recommand'].length,
          reply: _tempmap['reply'],
          key: ValueKey(
              _tempmap['key'].substring(3, _tempmap['key'].length - 3)),
        ));
      }
    }

    notifyListeners();
  }

  Future<void> upLoadBoard({
    required Board boardinfo,
    User? user,
  }) async {
    print('upLoadBoard');
    if (user == null) {
      return;
    }

    String _now = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    Key _key = ValueKey(_now + user.email!);

    await FirebaseFirestore.instance.collection('Boards').doc(_now).set({
      'nickname': boardinfo.nickname,
      'title': boardinfo.title,
      'contents': boardinfo.contents,
      'imageUrl': boardinfo.imageUrl,
      'date': _now,
      'key': _key.toString(),
      'recommand': [],
      'reply': 0,
    });
  }

  Future<void> uplaodReply({
    required Board board,
    required Reply reply,
    User? user,
  }) async {
    print('uplaodReply');
    if (user == null) {
      return;
    }
    String _then = DateFormat('yyyy-MM-dd hh:mm:ss').format(board.date);
    String _now = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    Key _key = ValueKey(_now + user.email!);
    try {
      await FirebaseFirestore.instance
          .collection('Boards')
          .doc(_then)
          .collection('Replys')
          .doc(_now)
          .set({
        'nickname': reply.nickname,
        'contents': reply.contents,
        'date': _now,
        'key': _key.toString(),
      });

      await FirebaseFirestore.instance
          .collection('Boards')
          .doc(_then)
          .update({'reply': FieldValue.increment(1)});
    } catch (e) {
      return;
    }
  }

  Future<void> recommand({
    required Board boardinfo,
    User? user,
  }) async {
    print('recommand');
    if (user == null) {
      return;
    }
    String _time = DateFormat('yyyy-MM-dd hh:mm:ss').format(boardinfo.date);
    var document = FirebaseFirestore.instance.collection('Boards').doc(_time);

    await document.update({
      'recommand': FieldValue.arrayUnion([user.email]),
    });
  }
}

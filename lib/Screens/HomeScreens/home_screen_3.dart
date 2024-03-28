import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/board.dart';
import 'package:soaproject/Screens/Board/board_detail_screen.dart';

class HomeScreen3 extends StatefulWidget {
  static const routeName = 'Homescreen3';
  final User? user;
  final double height, width;
  const HomeScreen3({
    this.user,
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen3> createState() => _HomeScreen3State();
}

class _HomeScreen3State extends State<HomeScreen3> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<BoardProvider>(context, listen: false);
    print('page 3');

    return FutureBuilder(
      future: _provider.getBoardList(),
      builder: (context, snap) {
        List<Board> _boardList = _provider.boardlist;
        int _listLength = ((_boardList.length - 1) ~/ 10) + 1;
        int _itemLength = min(10, _boardList.length - _pageIndex * 10);

        return Padding(
          padding: const EdgeInsets.only(
            top: 20,
            right: 20,
            left: 20,
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const Text(
                  '게시판',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: widget.height - 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black38,
                    ),
                  ),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      Board _tempboard = _boardList[_pageIndex * 10 + index];
                      return NewWidget(
                        provider: _provider,
                        board: _tempboard,
                        widget: widget,
                        height: widget.height - 200,
                        width: widget.width,
                      );
                    },
                    itemCount: min(10, _itemLength),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  width: _listLength * 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 40,
                        child: TextButton(
                          child: Text('${index + 1}'),
                          onPressed: () {
                            setState(() {
                              _pageIndex = index;
                            });
                          },
                        ),
                      );
                    },
                    itemCount: min(5, _listLength),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NewWidget extends StatelessWidget {
  final BoardProvider provider;
  final Board board;
  final HomeScreen3 widget;
  final double height, width;

  const NewWidget({
    Key? key,
    required this.provider,
    required this.board,
    required this.widget,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _istoday = DateTime.now().difference(board.date).inDays == 0 &&
        DateTime.now().day == board.date.day;
    return InkWell(
      onTap: () async {
        await provider.updateBoard(board);
        Navigator.of(context)
            .pushNamed(BoardDetailScreen.routeName, arguments: {
          'board': board,
          'user': widget.user,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 12,
        ),
        height: height / 10,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: width - 120,
                  child: Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: width - 140,
                        ),
                        child: Text(
                          board.title,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (board.imageUrl != null) const SizedBox(width: 4),
                      if (board.imageUrl != null)
                        const Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: Colors.black45,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: width - 120,
                  child: Row(
                    children: [
                      commontext(board.nickname),
                      const SizedBox(width: 8),
                      commontext(DateFormat(_istoday ? 'hh:mm' : 'MM.dd')
                          .format(board.date)),
                      const SizedBox(width: 8),
                      commontext('추천:${board.recommand}'),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1568B3),
              child: Text(
                '${board.reply}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
      ),
    );
  }
}

Widget commontext(String string) {
  return Text(
    string,
    style: const TextStyle(
      fontSize: 12,
      color: Colors.black38,
    ),
  );
}

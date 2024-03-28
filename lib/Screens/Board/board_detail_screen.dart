import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/board.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Widgets/divider.dart';

class BoardDetailScreen extends StatefulWidget {
  static const routeName = '/BoardDetailscreen';
  const BoardDetailScreen({Key? key}) : super(key: key);

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  String? nickname;
  bool didrecommand = false;
  final TextEditingController _textcontroller = TextEditingController();

  @override
  void dispose() {
    _textcontroller.dispose();
    super.dispose();
  }

  void needLogin(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          '로그인 이후에 가능해요.',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('연결 오휴'),
        content: const Text('다음에 다시 시도해주세요.'),
        actions: <Widget>[
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('board detail');
    Map<String, dynamic> _temp =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Board _board = _temp['board'];
    User? _user = _temp['user'];
    if (_user != null) {
      nickname = Provider.of<UserInfoprovider>(context, listen: false)
          .getUserInformagions
          .nickname;
    }

    double _width = MediaQuery.of(context).size.width;
    var _provider = Provider.of<BoardProvider>(context, listen: false);

    return FutureBuilder(
      future: _provider.updateBoard(_board),
      builder: (context, sn) {
        List<Reply> _replyList = _provider.replyList;
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _board.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            _board.nickname,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('yyyy.MM.dd hh:mm').format(_board.date),
                            style: const TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MyDivider(length: _width),
                      const SizedBox(height: 12),
                      if (_board.imageUrl != null)
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 400,
                          ),
                          child: Image.network(
                            _board.imageUrl!,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (_board.imageUrl != null) const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(minHeight: 60),
                        child: Text(
                          _board.contents,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (_user == null) {
                                  needLogin(context);
                                  return;
                                }
                                try {
                                  await _provider.recommand(
                                    boardinfo: _board,
                                    user: _user,
                                  );
                                  setState(() {
                                    if (!didrecommand) {
                                      _board.recommand += 1;
                                      didrecommand = true;
                                    }
                                    _replyList.add(
                                      Reply(
                                        nickname: nickname!,
                                        contents: _textcontroller.text,
                                        date: DateTime.now(),
                                      ),
                                    );
                                  });
                                } catch (e) {
                                  return _showErrorDialog();
                                }
                              },
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(
                                Icons.thumb_up_alt_outlined,
                                color: Color(0xFF1568B3),
                              ),
                            ),
                            Text('${_board.recommand}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '댓글',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyDivider(length: _width),
                      _replyList.isEmpty
                          ? Column(
                              children: const [
                                SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    '아직 댓글이 없어요.',
                                    style: TextStyle(
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, idx) {
                                  return const Divider(
                                    indent: 12,
                                    endIndent: 12,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  Reply _item = _replyList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      top: 4,
                                      bottom: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _item.nickname,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat('MM.dd hh:mm')
                                                  .format(_item.date),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _item.contents,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: _replyList.length,
                              ),
                            ),
                      MyDivider(length: _width),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            child: TextField(
                              maxLines: 1,
                              controller: _textcontroller,
                              decoration: const InputDecoration(
                                hintText: '댓글 달기',
                              ),
                              onSubmitted: (value) {
                                _textcontroller.text = value;
                              },
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                            width: 280,
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 60,
                            child: TextButton(
                              onPressed: () async {
                                if (_user == null) {
                                  needLogin(context);
                                  return;
                                }
                                if (_textcontroller.text.trim() == '') {
                                  return;
                                }
                                try {
                                  await _provider.uplaodReply(
                                    user: _user,
                                    board: _board,
                                    reply: Reply(
                                      nickname: nickname!,
                                      contents: _textcontroller.text,
                                      date: DateTime.now(),
                                    ),
                                  );
                                  setState(() {
                                    _textcontroller.text = '';
                                  });
                                } catch (e) {
                                  _showErrorDialog();
                                  return;
                                }
                              },
                              child: const Text(
                                '등록',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

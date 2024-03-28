import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/board.dart';
import 'package:soaproject/Provider/user_info.dart';

class BoardInputScreen extends StatefulWidget {
  static const routeName = '/BoardInputscreen';
  const BoardInputScreen({Key? key}) : super(key: key);

  @override
  State<BoardInputScreen> createState() => _BoardInputScreenState();
}

class _BoardInputScreenState extends State<BoardInputScreen> {
  final GlobalKey<FormBuilderState> _formkey = GlobalKey();
  String? _title, _contents, _imageFileUrl;
  File? _storedImage;
  bool _isLoading = false;

  PreferredSizeWidget appBar = AppBar(
    title: const Text('게시물 작성'),
  );

  Future<void> saveform(User user) async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    String _now = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    try {
      await Future(() async {
        if (_storedImage != null) {
          var data = await firebase_storage.FirebaseStorage.instance
              .ref('Boards/$_now/${user.email}')
              .putFile(_storedImage!);

          _imageFileUrl = await data.ref.getDownloadURL();
        }
      });

      await Provider.of<BoardProvider>(context, listen: false).upLoadBoard(
          user: user,
          boardinfo: Board(
            title: _title!,
            contents: _contents!,
            imageUrl: _imageFileUrl,
            nickname: Provider.of<UserInfoprovider>(context, listen: false)
                .getUserInformagions
                .nickname!,
            date: DateTime.now(),
          ));

      Navigator.of(context).pop();
    } catch (erorr) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('작성 오류'),
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getPicture() async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1200,
      maxWidth: 1200,
    );

    if (imageFile == null) {
      return;
    }

    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('board input');
    var _mediaquery = MediaQuery.of(context);
    double _width = _mediaquery.size.width;
    double _height = _mediaquery.size.height -
        appBar.preferredSize.height -
        _mediaquery.padding.top -
        _mediaquery.padding.bottom;

    User _user = ModalRoute.of(context)!.settings.arguments as User;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: appBar,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    FormBuilder(
                      key: _formkey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 20,
                          left: 20,
                          top: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: _width * 0.1,
                                  child: const Text(
                                    '제목',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: _width * 0.7,
                                  height: 48,
                                  child: FormBuilderTextField(
                                    name: '제목',
                                    initialValue: _title,
                                    onSaved: (value) {
                                      _title = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.trim() == '') {
                                        return '제목을 입력해주세요.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                const Text(
                                  '내용',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  label: const Text('사진 첨부'),
                                  onPressed: _getPicture,
                                  icon: const Icon(Icons.camera_alt_outlined),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: _height - 240,
                              width: _width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black38),
                              ),
                              child: FormBuilderTextField(
                                name: '내용',
                                initialValue: _contents,
                                maxLines: null,
                                maxLength: 500,
                                keyboardType: TextInputType.multiline,
                                onSaved: (value) {
                                  _contents = value;
                                },
                                validator: (value) {
                                  if (value == null || value.trim() == '') {
                                    return '제목을 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_storedImage != null)
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: _width,
                                  maxWidth: _width,
                                ),
                                child: Image.file(
                                  _storedImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            if (_storedImage != null)
                              const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => saveform(_user),
                              child: const Text(
                                '글 쓰기',
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

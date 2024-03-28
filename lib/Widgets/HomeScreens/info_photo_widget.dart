import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:soaproject/Provider/user_info.dart';

class PhotoWidget extends StatefulWidget {
  final User? user;
  final UserInformations userInformations;
  const PhotoWidget({
    required this.user,
    required this.userInformations,
    Key? key,
  }) : super(key: key);

  @override
  State<PhotoWidget> createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State<PhotoWidget> {
  SharedPreferences? sharedPrefs;
  File? _storedImage;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => sharedPrefs = prefs);
    });
  }

  Future<void> _loadFile() async {
    print('load');
    String _filepath = widget.user != null ? '${widget.user!.email}' : 'ano';

    if (sharedPrefs != null &&
        sharedPrefs!.containsKey('user_photo_$_filepath')) {
      print('shared');
      _storedImage = File(sharedPrefs!.getString('user_photo_$_filepath')!);
      return;
    }

    if (widget.user == null || widget.userInformations.imageFileName == null) {
      return;
    }

    Directory appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = widget.userInformations.imageFileName!;
    _storedImage = File('${appDir.path}/$fileName');

    print('download');
    await firebase_storage.FirebaseStorage.instance
        .ref('UserImages/${widget.user!.email}/profile')
        .writeToFile(_storedImage!);
  }

  Future<void> _getPicture() async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (imageFile == null) {
      return;
    }

    setState(() {
      _storedImage = File(imageFile.path);
    });

    Directory appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(imageFile.path);
    await _storedImage!.copy('${appDir.path}/$fileName');
    await sharedPrefs!.clear();
    String _filepath = widget.user != null ? '${widget.user!.email}' : 'ano';
    await sharedPrefs!.setString('user_photo_$_filepath', imageFile.path);

    if (widget.user != null) {
      try {
        if (widget.userInformations.imageFileName != null) {
          await firebase_storage.FirebaseStorage.instance
              .ref('UserImages/${widget.user!.email}/profile')
              .delete();
        }

        await firebase_storage.FirebaseStorage.instance
            .ref('UserImages/${widget.user!.email}/profile')
            .putFile(_storedImage!);

        await Provider.of<UserInfoprovider>(context, listen: false)
            .changeUserInfo(fileName: fileName);
      } on firebase_core.FirebaseException catch (e) {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(
              e.toString(),
            ),
          ),
        );
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    if (_storedImage == null) _loadFile();

    print('page photo');
    return GestureDetector(
      onTap: () {
        bool _isLoading = false;
        showDialog(
          barrierDismissible: false,
          barrierColor: Colors.black87,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 650,
                        width: _size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 600,
                                maxWidth: _size.width - 40,
                              ),
                              child: _storedImage == null
                                  ? const Text(
                                      '프로필 사진이 없어요.',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  : ClipRRect(
                                      child: Image.file(
                                        _storedImage!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await _getPicture();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: const Text(
                                    '프로필 사진 설정',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    '취소',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
              },
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: _storedImage != null
            ? ClipRRect(
                child: Image.file(
                  _storedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(30),
              )
            : const Center(
                child: Text(
                  '프로필 사진을\n설정해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
      ),
    );
  }
}

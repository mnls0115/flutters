import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/eval_provider.dart';
import 'package:soaproject/Widgets/Eval/radio_button.dart';
import './radio_button.dart';

class Question1 extends StatelessWidget {
  final int listtype, index;
  const Question1({
    required this.listtype,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object?>> _list =
        Provider.of<EvalProdiver>(context).getList(listtype);
    String? _groupvalue = _list[index]['value'] as String?;

    void _changeFx(String val) {
      print(val);
      Provider.of<EvalProdiver>(context, listen: false)
          .editList(listtype, index, val);
    }

    return SizedBox(
      child: Column(
        children: [
          Text(
            _list[index]['Q'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<EvalProdiver>(
            builder: (context, value, child) => Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RadiobuttonWidgett(
                    inputvalue: 'y',
                    groupvalue: _groupvalue,
                    inputString: '가능함',
                    function: _changeFx,
                  ),
                  RadiobuttonWidgett(
                    inputvalue: 'n',
                    groupvalue: _groupvalue,
                    inputString: '불가능함',
                    function: _changeFx,
                  ),
                  RadiobuttonWidgett(
                    inputvalue: '?',
                    groupvalue: _groupvalue,
                    inputString: '모름',
                    function: _changeFx,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

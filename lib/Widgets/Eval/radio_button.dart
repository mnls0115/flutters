import 'package:flutter/material.dart';

class RadiobuttonWidgett extends StatelessWidget {
  final String inputvalue;
  final String? groupvalue;
  final String inputString;
  final Function function;

  const RadiobuttonWidgett({
    required this.inputvalue,
    required this.groupvalue,
    required this.inputString,
    required this.function,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: inputvalue,
            groupValue: groupvalue,
            onChanged: (val) => function(val),
            activeColor: Theme.of(context).primaryColor,
          ),
          Text(
            inputString,
            style: groupvalue == inputvalue
                ? const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    // color: Color(0xFF1568B3),
                  )
                : const TextStyle(
                    fontSize: 16,
                    color: Colors.black38,
                  ),
          ),
        ],
      ),
    );
  }
}

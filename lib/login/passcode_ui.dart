import 'package:flutter/material.dart';

class PasscodeInput extends StatefulWidget {
  final Function(String) onCompleted;

  const PasscodeInput({super.key, required this.onCompleted});

  @override
  _PasscodeInputState createState() => _PasscodeInputState();
}

class _PasscodeInputState extends State<PasscodeInput> {
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          5,
              (index) => SizedBox(
            width: 40,
            height: 40,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < 4) {
                    _focusNodes[index + 1].requestFocus();
                  } else {
                    String passcode = _controllers.map((controller) => controller.text).join('');
                    widget.onCompleted(passcode);
                  }
                } else {
                  if (index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                }
              },
              showCursor: false,
            ),
          ),
        ),
      ),
    );
  }
}

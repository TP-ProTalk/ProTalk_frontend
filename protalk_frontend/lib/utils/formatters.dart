import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    String formatted = '';
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < digits.length && i < 8; i++) {
      formatted += digits[i];
      if (i == 1 || i == 3) {
        formatted += '.';
        if (i < newValue.selection.end) {
          selectionIndex++;
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

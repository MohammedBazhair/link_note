import 'package:flutter/material.dart';

enum NotePopupAction {
  deleteNote('حذف الملاحظة', Icons.delete),
  qrGenerator('توليد رمز QR', Icons.qr_code),
  qrScanner('مسح رمز QR', Icons.qr_code_scanner);

  const NotePopupAction(this.label,this.icon);

  final String label;
  final IconData icon;
}

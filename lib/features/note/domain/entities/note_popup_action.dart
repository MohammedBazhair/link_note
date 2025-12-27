enum NotePopupAction {
  qrGenerator('Genereate Qr Code'),
  qrScanner('Scanner Qr Code');

  const NotePopupAction(this.label);

  final String label;
}

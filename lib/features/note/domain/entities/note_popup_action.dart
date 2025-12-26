enum NotePopupAction {
  qrGenerator('Genereate Qr Code'),
  qrScanner('Scanner Qr Code'),
  improveNote('Improve Note by AI');

  const NotePopupAction(this.label);

  final String label;
}

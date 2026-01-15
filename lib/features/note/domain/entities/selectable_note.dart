class SelectableNote {
  SelectableNote({this.isSelectable = false, this.noteId});

  final bool isSelectable;
  final String? noteId;

  bool get hasNoteId => noteId?.isNotEmpty ?? false;

  SelectableNote init() {
    return SelectableNote();
  }

  SelectableNote copyWith({bool? isSelectable, String? noteId}) {
    return SelectableNote(
      isSelectable: isSelectable ?? this.isSelectable,
      noteId: noteId ?? this.noteId,
    );
  }
}

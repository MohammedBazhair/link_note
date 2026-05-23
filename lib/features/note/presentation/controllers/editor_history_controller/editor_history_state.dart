import '../../../domain/entities/editor_content.dart';

class EditorHistoryState {
  const EditorHistoryState({
    this.editorContent = const EditorContent(),
    this.hasUndo = false,
    this.hasRedo = false,
  });

  final EditorContent editorContent;
  final bool hasUndo;
  final bool hasRedo;

  EditorHistoryState copyWith({
    EditorContent? editorContent,

    bool? hasUndo,

    bool? hasRedo,
  }) {
    return EditorHistoryState(
      editorContent: editorContent ?? this.editorContent,
      hasUndo: hasUndo ?? this.hasUndo,
      hasRedo: hasRedo ?? this.hasRedo,
    );
  }
}

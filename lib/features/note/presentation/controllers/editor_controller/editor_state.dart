import 'dart:ui';
import '../../../../../core/utils/directionality.dart';
import '../../../domain/entities/editor_content.dart';

class EditorState {
  const EditorState({
    required this.editorContent,
    this.hasUndo = false,
    this.hasRedo = false,
    this.isSaving = false,
    this.isSaved = true,
    this.hasChanges = false,
  });

  final EditorContent editorContent;

  final bool hasUndo;
  final bool hasRedo;
  final bool isSaving;
  final bool isSaved;
  final bool hasChanges;

  TextDirection? get titleDirection =>
      DirectionalityUtils.detectByText(editorContent.title);

  TextDirection? get contentDirection =>
      DirectionalityUtils.detectByText(editorContent.content);

  EditorState copyWith({
    EditorContent? editorContent,
    bool? hasUndo,
    bool? hasRedo,
    bool? isSaving,
    bool? isSaved,
    bool? hasChanges,
  }) {
    return EditorState(
      editorContent: editorContent ?? this.editorContent,
      hasUndo: hasUndo ?? this.hasUndo,
      hasRedo: hasRedo ?? this.hasRedo,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}

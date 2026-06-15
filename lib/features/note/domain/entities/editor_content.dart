import 'package:equatable/equatable.dart';

class EditorContent extends Equatable {
  const EditorContent({this.title = '', this.content = ''});

  final String title;
  final String content;

  @override
  List<Object?> get props => [title, content];

  EditorContent copyWith({String? title, String? content}) {
    return EditorContent(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}

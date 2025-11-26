import 'dart:convert';

class Note {
  final String? id;
  final String? uuid; // user id
  final String title;
  final String content;

  Note({this.id, this.uuid, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'title': title,
      'content': content,
      'uuid': ?uuid,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Note{id: $id, uuid: $uuid, title: $title, content: $content}.\n';
  }

  Note copyWith({
    String? id,
    String? uuid,
    String? title,
    String? content,
  }) {
    return Note(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}

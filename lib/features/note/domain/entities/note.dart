
class Note {

  Note({this.id, this.uuid, required this.title, required this.content});

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      uuid: map['owner_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }
  final String? id;
  final String? uuid; // user id
  final String title;
  final String content;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'title': title,
      'content': content,
      'owner_id': ?uuid,
    };
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

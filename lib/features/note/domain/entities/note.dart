import 'dart:convert';

class Note {
  Note({
    this.id,
    this.uuid,
    required this.updatedAt,
    required this.title,
    required this.content,
    this.deletedAt,
  });

  factory Note.fromJson(String json) {
    try {
      final map = jsonDecode(json);
      return Note.fromMap(map);
    } catch (e) {
      return Note(title: '', content: '', updatedAt: DateTime.now().toUtc());
    }
  }
  factory Note.fake() {
    return Note(
      updatedAt: DateTime(2025),
      title: 'title tutjmn',
      content: 'asfafsfafjhkgjkgkjgjj',
    );
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String?,
      uuid: map['owner_id'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt: DateTime.tryParse(map['deleted_at'] ?? ''),
    );
  }
  final String? id;
  final String? uuid; // user id
  final String title;
  final String content;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
      'owner_id': ?uuid,
      'deleted_at': ?(deletedAt?.toUtc().toIso8601String()),
    };
  }

  String get lastUpdateText {
    final date = updatedAt.toLocal();
    final years = date.year;
    final months = date.month;
    final hours = date.hour;
    final minuts = date.minute;
    return '$years/$months $hours:$minuts';
  }

  String toJson() {
    return jsonEncode(toMap());
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
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

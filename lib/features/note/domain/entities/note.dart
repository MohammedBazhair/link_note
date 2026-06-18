import 'dart:convert';

import '../../../../core/constants/internal_constants/log.dart';

class Note {
  Note({
    this.id,
    this.ownerId,
    required this.updatedAt,
    required this.title,
    required this.content,
    this.isDeleted = false,
  });

  factory Note.fromJson(String json) {
    try {
      Logger.log(message: json);
      final map = jsonDecode(json);

      Logger.log(message: map.toString());
      return Note.fromMap(map);
    } catch (e) {
      return Note(title: '', content: json, updatedAt: DateTime.now().toUtc());
    }
  }
  factory Note.fake() {
    return Note(
      id: 'id',
      updatedAt: DateTime(2025),
      title: 'title tutjmn',
      content: 'asfafsfafjhkgjkgkjgjj',
    );
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String?,
      ownerId: map['owner_id'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      updatedAt: DateTime.parse(map['updated_at']),
      isDeleted: map['is_deleted'] == 1 ? true : false,
    );
  }
  final String? id;
  final String? ownerId;
  final String title;
  final String content;
  final DateTime updatedAt;
  final bool isDeleted;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': ?id,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
      'owner_id': ?ownerId,
      'is_deleted': isDeleted ? 1 : 0,
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

  String toJson() => jsonEncode(toMap());

  String toQrJson() {
    final map = {
      'title': title,
      'content': content,
    };

    return jsonEncode(map);
  }

  @override
  String toString() {
    return 'Note{id: $id, uuid: $ownerId, title: $title, content: $content}.\n';
  }

  Note copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

import '../../domain/entities/image_memory.dart';

class ImageMemoryModel extends ImageMemory {
  const ImageMemoryModel({
    required super.id,
    required super.userId,
    required super.imagePath,
    super.title,
    super.description,
    super.tags,
    required super.memoryDate,
    required super.createdAt,
  });

  factory ImageMemoryModel.fromMap(Map<String, dynamic> map) {
    return ImageMemoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      imagePath: map['image_url'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      tags:
          (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      memoryDate: _parseDate(map['memory_date']) ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'image_url': imagePath,
      'title': title,
      'description': description,
      'tags': tags,
      'memory_date': memoryDate.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'tags': tags,
      'memory_date': memoryDate.toIso8601String(),
    };
  }
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  final s = raw.toString();
  // Supabase may send date as "YYYY-MM-DD"
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    return DateTime.tryParse('${s}T00:00:00.000Z')?.toLocal();
  }
  return DateTime.tryParse(s);
}

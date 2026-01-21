class ImageMemory {
  const ImageMemory({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.title,
    this.description,
    this.tags = const [],
    required this.memoryDate,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// Path in Supabase storage bucket (NOT a public URL).
  /// Expected format: `{userId}/{imageId}.jpg`
  final String imagePath;

  final String? title;
  final String? description;
  final List<String> tags;

  /// User-selected date for the memory (defaults to today).
  final DateTime memoryDate;

  final DateTime createdAt;

  ImageMemory copyWith({
    String? id,
    String? userId,
    String? imagePath,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? memoryDate,
    DateTime? createdAt,
  }) {
    return ImageMemory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      memoryDate: memoryDate ?? this.memoryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}



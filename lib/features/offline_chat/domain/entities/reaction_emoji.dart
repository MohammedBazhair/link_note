import 'package:link_note/core/constants/internal_constants/log.dart';

enum ReactionEmoji {
  like(1, '👍'),
  dislike(2, '👎'),
  love(3, '❤️'),
  laugh(4, '😂'),
  fire(5, '🔥'),
  cry(6, '😢'),
  wow(7, '😮'),
  angry(8, '😡'),
  surprised(9, '😲'),
  heartEyes(10, '😍'),
  clap(11, '👏'),
  party(12, '🥳'),
  thinking(13, '🤔'),
  praying(14, '🙏'),
  hundred(15, '💯');

  const ReactionEmoji(this.code, this.emoji);

  final String emoji;
  final int code;

  static ReactionEmoji? fromCode(int? code) {
    try {
      if (code == null || code == 0) return null;
      return ReactionEmoji.values.firstWhere((r) => r.code == code);
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return null;
    }
  }
}

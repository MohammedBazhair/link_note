enum ReactionEmoji {
  like('👍'),
  dislike('👎'),
  love('❤️'),
  laugh('😂'),
  fire('🔥'),
  cry('😢'),
  wow('😮'),
  angry('😡'),
  surprised('😲'),
  heartEyes('😍'),
  clap('👏'),
  party('🥳'),
  thinking('🤔'),
  praying('🙏'),
  hundred('💯');

  const ReactionEmoji(this.emoji);

  final String emoji;

  static ReactionEmoji fromString(String name) {
    return ReactionEmoji.values.byName(name);
  }
}

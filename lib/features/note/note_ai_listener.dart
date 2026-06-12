import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/features/note/presentation/controllers/note_ai_controller/note_ai_state.dart';

import 'presentation/controllers/note_providers.dart';

void noteAiListener({
  required BuildContext context,
  required NoteAiState state,
  required WidgetRef ref,
}) {
  switch (state) {
    case ShowMessageAiNoteState(:final message):
      context.showSnakbar(message);

    case SuccessAiNoteState():
      ref.invalidate(getCreditsProvider);
    case UpdatingAiNoteState():
    case ResetAiNoteState():
  }
}

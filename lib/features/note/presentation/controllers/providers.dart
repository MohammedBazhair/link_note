import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../core/presentation/providers/provider.dart';
import '../../../session/presentation/controllers/session_controller.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

final notesRepositoryProvider = Provider((_) {
  return GetIt.I<NotesRepository>();
});

final userRepositoryProvider = Provider((_) {
  return GetIt.I<UserRepository>();
});

final isInNotesListScreen = StateProvider((_) => false);

final notesStreamProvider = StreamProvider.autoDispose((ref) {
  final notesRepo = ref.watch(notesRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final network = ref.watch(networkProvider);
  final userId = userRepo.currentUser?.id;
  final controller = StreamController<List<Note>>();

  controller.addStream(notesRepo.fetchNotesRealTime(userId));

  final subscription = network.listenToConnectionChanges((status) async{
    if (status == InternetStatus.connected) {
      try {
        final stream = notesRepo.fetchNotesRealTime(userId);

        await controller.addStream(stream);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final singleNoteStreamProvider = StreamProvider.family
    .autoDispose<Note?, String>((ref, noteId) {
      ref.onDispose(() {
        print('Disposed singleNoteStreamProvider for noteId: $noteId');
      });
      final repo = ref.watch(notesRepositoryProvider);
      return repo.fetchNoteStream(noteId);
    });

final getNoteByIdProvider = FutureProvider.family.autoDispose<Note?, String>((
  ref,
  noteId,
) {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.getNoteById(noteId);
});

final sessionMembersStreamProvider = StreamProvider.autoDispose((ref) {
  final sessionController = ref.read(sessionControllerProvider.notifier);

  return sessionController.fetchMembersOfSession();
});

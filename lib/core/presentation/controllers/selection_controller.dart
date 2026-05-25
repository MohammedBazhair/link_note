import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  
  bool get isSelectionMode => state.isNotEmpty;

  bool isSelected(String id) => state.contains(id);

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void clear() {
    state = {};
  }

  void selectAll(List<String> ids) {
    state = ids.toSet();
  }

}


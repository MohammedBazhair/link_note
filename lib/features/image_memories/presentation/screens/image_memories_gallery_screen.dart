import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/custom_drawer.dart';
import '../controllers/image_memories_providers.dart';
import '../widgets/memory_empty_state.dart';
import '../widgets/memory_grid_tile.dart';
import 'add_image_memory_screen.dart';
import 'image_memory_details_screen.dart';

class ImageMemoriesGalleryScreen extends ConsumerStatefulWidget {
  const ImageMemoriesGalleryScreen({super.key});

  @override
  ConsumerState<ImageMemoriesGalleryScreen> createState() =>
      _ImageMemoriesGalleryScreenState();
}

class _ImageMemoriesGalleryScreenState
    extends ConsumerState<ImageMemoriesGalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInImageMemoriesScreen.notifier).state = true;
    });
  }

  @override
  void dispose() {
    ref.read(isInImageMemoriesScreen.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(imageMemoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ذكريات الصور'),
        actions: [
          IconButton(
            tooltip: 'إضافة ذكرى',
            onPressed: () => context.pushTo(const AddImageMemoryScreen()),
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushTo(const AddImageMemoryScreen()),
        child: const Icon(Icons.add_rounded),
      ),
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) return const MemoryEmptyState();

          final columns = MediaQuery.of(context).size.width >= 700 ? 3 : 2;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: GridView.builder(
              key: const ValueKey('memories-grid'),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                return MemoryGridTile(
                  memory: memory,
                  onTap: () => context.pushTo(
                    ImageMemoryDetailsScreen(memory: memory),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 36),
                const SizedBox(height: 10),
                const Text('حدث خطأ أثناء تحميل الذكريات'),
                const SizedBox(height: 12),
                Text(
                  e.toString(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(imageMemoriesControllerProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



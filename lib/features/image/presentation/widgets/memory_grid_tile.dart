// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// import '../../../../core/constants/colors/colors.dart';
// import '../../../../core/presentation/widgets/tile_wrapper.dart';
// import '../../domain/entities/image_memory.dart';

// class MemoryGridTile extends ConsumerWidget {
//   const MemoryGridTile({super.key, required this.memory, required this.onTap});

//   final ImageMemory memory;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final urlAsync = ref.watch(signedMemoryImageUrlProvider(memory.imagePath));

//     return TileWrapper(
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(20),
//                 ),
//                 child: urlAsync.when(
//                   data: (url) {
//                     return Hero(
//                       tag: 'memory-img-${memory.id}',
//                       child: Image.network(
//                         url,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             color: Colors.white.withOpacity(0.03),
//                             child: const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           );
//                         },
//                         errorBuilder: (context, error, _) {
//                           return Container(
//                             color: Colors.white.withOpacity(0.03),
//                             child: const Center(
//                               child: Icon(Icons.broken_image_outlined),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   loading: () {
//                     return Skeletonizer(
//                       child: Container(
//                         color: Colors.white.withOpacity(0.03),
//                         child: const Center(child: Icon(Icons.photo)),
//                       ),
//                     );
//                   },
//                   error: (_, __) {
//                     return Container(
//                       color: Colors.white.withOpacity(0.03),
//                       child: const Center(
//                         child: Icon(Icons.broken_image_outlined),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     (memory.title?.trim().isNotEmpty ?? false)
//                         ? memory.title!
//                         : 'بدون عنوان',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_month_rounded,
//                         size: 14,
//                         color: DarkColors.icon.withOpacity(0.8),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         _dateText(memory.memoryDate),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Theme.of(
//                             context,
//                           ).textTheme.bodySmall?.color?.withOpacity(0.75),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// String _dateText(DateTime d) {
//   final local = d.toLocal();
//   return '${local.year}/${local.month}/${local.day}';
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/extensions/extensions.dart';
// import '../../domain/entities/image_memory.dart';
// import '../controllers/image_memories_providers.dart';

// class ImageMemoryDetailsScreen extends ConsumerWidget {
//   const ImageMemoryDetailsScreen({super.key, required this.memory});

//   final ImageMemory memory;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final urlAsync = ref.watch(signedMemoryImageUrlProvider(memory.imagePath));

//     return Scaffold(
//       appBar: AppBar(
//         title: Text((memory.title?.trim().isNotEmpty ?? false) ? memory.title! : 'ذكرى'),
//         actions: [
//           IconButton(
//             tooltip: 'حذف',
//             icon: const Icon(Icons.delete_outline_rounded),
//             onPressed: () async {
//               final ok = await showDialog<bool>(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text('حذف الذكرى؟'),
//                     content: const Text('سيتم حذف الصورة والبيانات بشكل نهائي.'),
//                     actions: [
//                       TextButton(onPressed: () => context.pop(false), child: const Text('إلغاء')),
//                       ElevatedButton(
//                         onPressed: () => context.pop(true),
//                         child: const Text('حذف'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//               if (ok != true) return;

//               final res =
//                   await ref.read(imageMemoriesControllerProvider.notifier).deleteMemory(memory);
//               if (res.hasError) {
//                 if (!context.mounted) return;
//                 context.showSnakbar('فشل الحذف: ${res.errorMessage}');
//                 return;
//               }
//               if (!context.mounted) return;
//               context.pop();
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(22),
//               child: urlAsync.when(
//                 data: (url) {
//                   return Hero(
//                     tag: 'memory-img-${memory.id}',
//                     child: Image.network(
//                       url,
//                       fit: BoxFit.cover,
//                       height: 360,
//                       loadingBuilder: (context, child, progress) {
//                         if (progress == null) return child;
//                         return const SizedBox(
//                           height: 360,
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       },
//                       errorBuilder: (context, error, _) {
//                         return const SizedBox(
//                           height: 360,
//                           child: Center(child: Icon(Icons.broken_image_outlined)),
//                         );
//                       },
//                     ),
//                   );
//                 },
//                 loading: () => const SizedBox(
//                   height: 360,
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//                 error: (_, __) => const SizedBox(
//                   height: 360,
//                   child: Center(child: Icon(Icons.broken_image_outlined)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             _MetaRow(
//               icon: Icons.calendar_month_rounded,
//               title: 'التاريخ',
//               value: _dateText(memory.memoryDate),
//             ),
//             if ((memory.description?.trim().isNotEmpty ?? false)) ...[
//               const SizedBox(height: 12),
//               _MetaRow(
//                 icon: Icons.notes_rounded,
//                 title: 'الوصف',
//                 value: memory.description!,
//                 multiLine: true,
//               ),
//             ],
//             if (memory.tags.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               _MetaRow(
//                 icon: Icons.sell_outlined,
//                 title: 'الوسوم',
//                 value: memory.tags.join('، '),
//                 multiLine: true,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MetaRow extends StatelessWidget {
//   const _MetaRow({
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.multiLine = false,
//   });

//   final IconData icon;
//   final String title;
//   final String value;
//   final bool multiLine;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//       children: [
//         Icon(icon, size: 18),
//         const SizedBox(width: 10),
//         SizedBox(
//           width: 70,
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 14, height: 1.5),
//           ),
//         ),
//       ],
//     );
//   }
// }

// String _dateText(DateTime d) {
//   final local = d.toLocal();
//   return '${local.year}/${local.month}/${local.day}';
// }



import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors/colors.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/field_label.dart';
import '../../../../core/presentation/widgets/tile_wrapper.dart';
import '../../../upload_file/helpers/helpers.dart';
import '../controllers/image_memories_providers.dart';

class AddImageMemoryScreen extends ConsumerStatefulWidget {
  const AddImageMemoryScreen({super.key});

  @override
  ConsumerState<AddImageMemoryScreen> createState() =>
      _AddImageMemoryScreenState();
}

class _AddImageMemoryScreenState extends ConsumerState<AddImageMemoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _date = DateTime.now();
  XFile? _picked;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await uploadImage(source);
    if (file == null) return;
    setState(() => _picked = file);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: DarkColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(RegExp(r'[,،]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_picked == null) {
      context.showSnakbar('اختر صورة أولاً');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final controller = ref.read(imageMemoriesControllerProvider.notifier);
    final res = await controller.create(
      imageFilePath: _picked!.path,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      tags: _parseTags(_tagsController.text),
      memoryDate: _date,
    );
    setState(() => _saving = false);

    if (res.hasError) {
      context.showSnakbar('فشل الحفظ: ${res.errorMessage}');
      return;
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _picked == null ? null : File(_picked!.path);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة ذكرى')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              TileWrapper(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : () => _pick(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('المعرض'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : () => _pick(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('الكاميرا'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: preview == null
                            ? Container(
                                key: const ValueKey('empty-preview'),
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: DarkColors.primary.withOpacity(0.18),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'اختر صورة لعرضها هنا',
                                    style: TextStyle(height: 1.6),
                                  ),
                                ),
                              )
                            : ClipRRect(
                                key: const ValueKey('has-preview'),
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(
                                  preview,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const FieldLabel(text: 'العنوان (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                maxLength: 60,
                decoration: const InputDecoration(hintText: 'مثال: رحلة الشتاء'),
              ),
              const SizedBox(height: 12),
              const FieldLabel(text: 'الوصف (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.newline,
                minLines: 3,
                maxLines: 6,
                maxLength: 800,
                decoration: const InputDecoration(hintText: 'اكتب تفاصيل الذكرى...'),
              ),
              const SizedBox(height: 12),
              const FieldLabel(text: 'الوسوم (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'مثال: سفر, عائلة, 2026',
                  helperText: 'افصل الوسوم بفاصلة.',
                ),
              ),
              const SizedBox(height: 12),
              const FieldLabel(text: 'التاريخ'),
              const SizedBox(height: 8),
              TileWrapper(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: Text(_dateText(_date)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _saving ? null : _pickDate,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _saving
                    ? const Center(
                        key: ValueKey('saving'),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('save'),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('حفظ'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateText(DateTime d) {
  final local = d.toLocal();
  return '${local.year}/${local.month}/${local.day}';
}



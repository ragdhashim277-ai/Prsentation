import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/lesson.dart';
import '../services/ai_service.dart';
import '../services/lesson_service.dart';
import 'lesson_screen.dart';

const _gradesByLevel = <String, List<String>>{
  'الأساس': ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'],
  'المتوسط': ['الأول', 'الثاني', 'الثالث'],
  'الثانوي': ['الأول', 'الثاني', 'الثالث'],
};

const _subjects = <String>[
  'اللغة العربية',
  'اللغة الإنجليزية',
  'الرياضيات',
  'الفيزياء',
  'الكيمياء',
  'الأحياء',
  'العلوم',
  'الفرنسية',
  'التربية الإسلامية',
  'التاريخ',
  'الجغرافيا',
  'الحاسوب',
];

class PrepareScreen extends StatefulWidget {
  const PrepareScreen({super.key});

  @override
  State<PrepareScreen> createState() => _PrepareScreenState();
}

class _PrepareScreenState extends State<PrepareScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _level = 'الثانوي';
  String _grade = 'الأول';
  String _subject = 'الرياضيات';
  bool _loading = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _importNotes() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'md'],
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      if (bytes == null) return;

      var text = utf8.decode(bytes, allowMalformed: true).trim();
      if (text.length > 6000) {
        text = text.substring(0, 6000);
        _snack('تم اقتطاع الملف إلى أول 6000 حرف');
      }
      setState(() => _notesController.text = text);
    } catch (_) {
      _snack('تعذر قراءة الملف');
    }
  }

  Future<void> _prepare() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _snack('اكتب عنوان الدرس');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await AiService().generateLesson(
        title: title,
        subject: _subject,
        level: _level,
        grade: _grade,
        notes: _notesController.text.trim(),
      );

      final lesson = Lesson(
        id: const Uuid().v4(),
        title: title,
        subject: _subject,
        level: _level,
        grade: _grade,
        content: result.content,
      );

      await LessonService().saveLesson(lesson);

      if (!mounted) return;
      if (!result.usedAi) {
        _snack('خدمة الذكاء الاصطناعي غير متاحة، تم استخدام قالب جاهز');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
      );
    } catch (e) {
      _snack('تعذر حفظ الدرس: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grades = _gradesByLevel[_level]!;

    return Scaffold(
      appBar: AppBar(title: const Text('إعداد درس جديد')),
      body: AbsorbPointer(
        absorbing: _loading,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _level,
              decoration: const InputDecoration(labelText: 'المرحلة'),
              items: _gradesByLevel.keys
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() {
                _level = v!;
                _grade = _gradesByLevel[_level]!.first;
              }),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              key: ValueKey(_level),
              // ignore: deprecated_member_use
              value: grades.contains(_grade) ? _grade : grades.first,
              decoration: const InputDecoration(labelText: 'الصف'),
              items: grades
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _grade = v!),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _subject,
              decoration: const InputDecoration(labelText: 'المادة'),
              items: _subjects
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v!),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'عنوان الدرس'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _notesController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'ملاحظات أو محتوى تريد البناء عليه (اختياري)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _importNotes,
                icon: const Icon(Icons.attach_file),
                label: const Text('استيراد ملاحظات من ملف نصي'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _prepare,
              icon: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'جارٍ التحضير...' : 'حضّر الدرس'),
            ),
          ],
        ),
      ),
    );
  }
}

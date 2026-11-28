import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/lesson.dart';
import '../services/lesson_service.dart';
import '../services/voice_service.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _voice = VoiceService();
  final _service = LessonService();

  late Lesson _lesson;
  late final TextEditingController _editController;

  bool _playing = false;
  bool _editing = false;
  bool _saving = false;
  double _rate = 0.45;

  @override
  void initState() {
    super.initState();
    _lesson = widget.lesson;
    _editController = TextEditingController(text: _lesson.content);
    _voice.initialize();
  }

  String get _languageCode {
    switch (_lesson.subject) {
      case 'اللغة الإنجليزية':
        return 'en-US';
      case 'الفرنسية':
        return 'fr-FR';
      default:
        return 'ar';
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _play() async {
    if (_playing) return;
    setState(() => _playing = true);
    try {
      await _voice.speak(_lesson.content, languageCode: _languageCode);
    } catch (_) {
      _snack('تعذر تشغيل الصوت على هذا الجهاز');
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  Future<void> _stop() async {
    await _voice.stop();
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _lesson.content));
    _snack('تم نسخ الدرس');
  }

  Future<void> _saveEdit() async {
    final text = _editController.text.trim();
    if (text.isEmpty) {
      _snack('لا يمكن حفظ درس فارغ');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.updateContent(_lesson.id, text);
      if (!mounted) return;
      setState(() {
        _lesson = _lesson.copyWith(content: text);
        _editing = false;
      });
      _snack('تم حفظ التعديلات');
    } catch (e) {
      _snack('تعذر الحفظ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _voice.stop();
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'نسخ',
            icon: const Icon(Icons.copy),
            onPressed: _copy,
          ),
          IconButton(
            tooltip: _editing ? 'إلغاء التعديل' : 'تعديل',
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _editing = !_editing;
                _editController.text = _lesson.content;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _lesson.title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(_lesson.subject)),
              Chip(label: Text('${_lesson.level} - ${_lesson.grade}')),
            ],
          ),
          const SizedBox(height: 14),
          if (_editing) ...[
            TextField(
              controller: _editController,
              minLines: 12,
              maxLines: null,
              decoration: const InputDecoration(alignLabelWithHint: true),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _saveEdit,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ التعديلات'),
            ),
          ] else
            SelectableText(
              _lesson.content,
              style: const TextStyle(fontSize: 17, height: 1.8),
            ),
          const SizedBox(height: 30),
          const Icon(Icons.headphones, size: 65, color: Color(0xFF075B9A)),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: _playing ? null : _play,
            icon: const Icon(Icons.play_arrow),
            label: const Text('تشغيل الشرح الصوتي'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _playing ? _stop : null,
            icon: const Icon(Icons.stop),
            label: const Text('إيقاف الصوت'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('السرعة'),
              Expanded(
                child: Slider(
                  value: _rate,
                  min: 0.3,
                  max: 0.7,
                  divisions: 8,
                  onChanged: (v) => setState(() => _rate = v),
                  onChangeEnd: (v) => _voice.setRate(v),
                ),
              ),
            ],
          ),
          Text(
            _playing ? 'يتم تشغيل الصوت...' : 'الصوت متوقف',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

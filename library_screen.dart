import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/lesson_service.dart';
import 'lesson_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _service = LessonService();
  final _searchController = TextEditingController();

  List<Lesson> _lessons = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lessons = await _service.getLessons();
      if (!mounted) return;
      setState(() => _lessons = lessons);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'تعذر تحميل الدروس: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirmDelete(Lesson lesson) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الدرس'),
        content: Text('هل تريد حذف "${lesson.title}" نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    try {
      await _service.deleteLesson(lesson.id);
      if (mounted) setState(() => _lessons.removeWhere((l) => l.id == lesson.id));
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر الحذف: $e')));
      }
      return false;
    }
  }

  String _date(DateTime? d) {
    if (d == null) return '';
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _lessons.where((l) {
      if (_query.isEmpty) return true;
      return l.title.contains(_query) || l.subject.contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('مكتبتي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'ابحث بعنوان الدرس أو المادة',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _query = v.trim()),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: filtered.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 120),
                                  Center(
                                    child: Text(_lessons.isEmpty
                                        ? 'لا توجد دروس بعد'
                                        : 'لا نتائج مطابقة'),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final lesson = filtered[i];
                                  return Dismissible(
                                    key: ValueKey(lesson.id),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) => _confirmDelete(lesson),
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: Card(
                                      child: ListTile(
                                        leading: const Icon(Icons.menu_book,
                                            color: Color(0xFF075B9A)),
                                        title: Text(lesson.title),
                                        subtitle: Text(
                                          '${lesson.subject} • ${lesson.level} ${lesson.grade}'
                                          '${lesson.createdAt == null ? '' : ' • ${_date(lesson.createdAt)}'}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () => _confirmDelete(lesson),
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                LessonScreen(lesson: lesson),
                                          ),
                                        ).then((_) => _load()),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

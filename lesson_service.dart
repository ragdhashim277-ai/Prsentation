import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson.dart';

class LessonService {
  SupabaseClient get _client => Supabase.instance.client;

  String _userId() {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    return user.id;
  }

  Future<void> saveLesson(Lesson lesson) async {
    final uid = _userId();
    await _client.from('lessons').insert({
      ...lesson.toMap(),
      'teacher_id': uid,
    });
  }

  Future<List<Lesson>> getLessons() async {
    final uid = _userId();
    final response = await _client
        .from('lessons')
        .select()
        .eq('teacher_id', uid)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Lesson.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> updateContent(String id, String content) async {
    final uid = _userId();
    await _client
        .from('lessons')
        .update({'content': content})
        .eq('id', id)
        .eq('teacher_id', uid);
  }

  Future<void> deleteLesson(String id) async {
    final uid = _userId();
    await _client.from('lessons').delete().eq('id', id).eq('teacher_id', uid);
  }
}

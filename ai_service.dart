import 'package:supabase_flutter/supabase_flutter.dart';

class AiResult {
  final String content;
  final bool usedAi;
  const AiResult(this.content, this.usedAi);
}

/// يستدعي Supabase Edge Function باسم generate-lesson (التي تستدعي Claude).
/// إذا فشل الاستدعاء يُستخدم قالب جاهز حتى لا يتعطل التطبيق.
class AiService {
  Future<AiResult> generateLesson({
    required String title,
    required String subject,
    required String level,
    required String grade,
    String notes = '',
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'generate-lesson',
        body: {
          'title': title,
          'subject': subject,
          'level': level,
          'grade': grade,
          'notes': notes,
        },
      ).timeout(const Duration(seconds: 90));

      final data = res.data;
      if (data is Map && data['content'] is String) {
        final text = (data['content'] as String).trim();
        if (text.isNotEmpty) return AiResult(text, true);
      }
    } catch (_) {
      // نتجاهل الخطأ وننتقل إلى القالب الاحتياطي
    }
    return AiResult(_template(title, notes), false);
  }

  String _template(String title, String notes) {
    final explain = notes.trim().isEmpty
        ? 'شرح المفاهيم الأساسية للدرس مع أمثلة وتطبيقات متدرجة من السهل إلى الصعب.'
        : notes.trim();
    return '''
أهداف الدرس:
أن يتعرف الطالب على $title ويطبقه في أمثلة متنوعة.

التمهيد:
مراجعة معلومات الطلاب السابقة المرتبطة بالدرس وطرح سؤال مثير للتفكير.

الشرح:
$explain

النشاط:
حل تدريبات تطبيقية مرتبطة بالدرس بشكل فردي ثم في مجموعات.

التقويم:
طرح أسئلة قصيرة للتأكد من فهم الطلاب وتصحيح التصورات الخاطئة.

الواجب:
مراجعة الدرس وحل تدريبات إضافية.
''';
  }
}

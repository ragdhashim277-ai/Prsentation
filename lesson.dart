class Lesson {
  final String id;
  final String title;
  final String subject;
  final String level;
  final String grade;
  final String content;
  final String? audioUrl;
  final DateTime? createdAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.grade,
    required this.content,
    this.audioUrl,
    this.createdAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      title: (map['title'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      level: (map['level'] ?? '') as String,
      grade: (map['grade'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      audioUrl: map['audio_url'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString())?.toLocal(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subject': subject,
        'level': level,
        'grade': grade,
        'content': content,
        'audio_url': audioUrl,
      };

  Lesson copyWith({String? content}) => Lesson(
        id: id,
        title: title,
        subject: subject,
        level: level,
        grade: grade,
        content: content ?? this.content,
        audioUrl: audioUrl,
        createdAt: createdAt,
      );
}

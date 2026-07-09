import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../mock/models.dart';

abstract class AppStateStorage {
  Future<AppStateSnapshot?> read();
  Future<void> write(AppStateSnapshot snapshot);
  Future<void> clear();
}

class FileAppStateStorage implements AppStateStorage {
  final File file;

  const FileAppStateStorage(this.file);

  static Future<FileAppStateStorage> createDefault() async {
    final directory = await getApplicationSupportDirectory();
    return FileAppStateStorage(
      File('${directory.path}/tiku_client_state_v1.json'),
    );
  }

  @override
  Future<AppStateSnapshot?> read() async {
    try {
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) return null;
      return AppStateSnapshot.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(AppStateSnapshot snapshot) async {
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(snapshot.toJson()));
  }

  @override
  Future<void> clear() async {
    if (await file.exists()) await file.delete();
  }
}

class MemoryAppStateStorage implements AppStateStorage {
  AppStateSnapshot? snapshot;

  @override
  Future<AppStateSnapshot?> read() async => snapshot;

  @override
  Future<void> write(AppStateSnapshot snapshot) async {
    this.snapshot = snapshot;
  }

  @override
  Future<void> clear() async {
    snapshot = null;
  }
}

class AppStateSnapshot {
  static const currentVersion = 1;

  final int version;
  final DateTime savedAt;
  final String selectedSubjectId;
  final String selectedChapterId;
  final String selectedExamChapterId;
  final List<Chapter> practiceChapters;
  final List<Chapter> examChapters;
  final List<Paper> practicePapers;
  final List<Paper> examPapers;
  final List<StudyRecord> practiceRecords;
  final List<StudyRecord> examRecords;
  final List<Question> favoriteQuestions;
  final List<Question> wrongQuestions;

  const AppStateSnapshot({
    this.version = currentVersion,
    required this.savedAt,
    required this.selectedSubjectId,
    required this.selectedChapterId,
    required this.selectedExamChapterId,
    required this.practiceChapters,
    required this.examChapters,
    required this.practicePapers,
    required this.examPapers,
    required this.practiceRecords,
    required this.examRecords,
    required this.favoriteQuestions,
    required this.wrongQuestions,
  });

  factory AppStateSnapshot.fromJson(Map<String, dynamic> json) {
    return AppStateSnapshot(
      version: _int(json['version'], fallback: currentVersion),
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      selectedSubjectId: json['selectedSubjectId']?.toString() ?? '',
      selectedChapterId: json['selectedChapterId']?.toString() ?? '',
      selectedExamChapterId: json['selectedExamChapterId']?.toString() ?? '',
      practiceChapters: _mapList(json['practiceChapters'], _chapterFromJson),
      examChapters: _mapList(json['examChapters'], _chapterFromJson),
      practicePapers: _mapList(json['practicePapers'], _paperFromJson),
      examPapers: _mapList(json['examPapers'], _paperFromJson),
      practiceRecords: _mapList(json['practiceRecords'], _recordFromJson),
      examRecords: _mapList(json['examRecords'], _recordFromJson),
      favoriteQuestions: _mapList(json['favoriteQuestions'], _questionFromJson),
      wrongQuestions: _mapList(json['wrongQuestions'], _questionFromJson),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'savedAt': savedAt.toIso8601String(),
      'selectedSubjectId': selectedSubjectId,
      'selectedChapterId': selectedChapterId,
      'selectedExamChapterId': selectedExamChapterId,
      'practiceChapters': practiceChapters.map(_chapterToJson).toList(),
      'examChapters': examChapters.map(_chapterToJson).toList(),
      'practicePapers': practicePapers.map(_paperToJson).toList(),
      'examPapers': examPapers.map(_paperToJson).toList(),
      'practiceRecords': practiceRecords.map(_recordToJson).toList(),
      'examRecords': examRecords.map(_recordToJson).toList(),
      'favoriteQuestions': favoriteQuestions.map(_questionToJson).toList(),
      'wrongQuestions': wrongQuestions.map(_questionToJson).toList(),
    };
  }
}

List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) parser) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => parser(Map<String, dynamic>.from(item)))
      .toList();
}

Map<String, Object?> _chapterToJson(Chapter chapter) {
  return {
    'id': chapter.id,
    'title': chapter.title,
    'done': chapter.done,
    'total': chapter.total,
    'correct': chapter.correct,
    'wrong': chapter.wrong,
    'sections': chapter.sections.map(_sectionToJson).toList(),
  };
}

Chapter _chapterFromJson(Map<String, dynamic> json) {
  return Chapter(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    done: _int(json['done']),
    total: _int(json['total']),
    correct: _int(json['correct']),
    wrong: _int(json['wrong']),
    sections: _mapList(json['sections'], _sectionFromJson),
  );
}

Map<String, Object?> _sectionToJson(Section section) {
  return {
    'id': section.id,
    'chapterId': section.chapterId,
    'title': section.title,
    'done': section.done,
    'total': section.total,
    'correct': section.correct,
    'wrong': section.wrong,
    'children': section.children.map(_sectionToJson).toList(),
  };
}

Section _sectionFromJson(Map<String, dynamic> json) {
  return Section(
    id: json['id']?.toString() ?? '',
    chapterId: json['chapterId']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    done: _int(json['done']),
    total: _int(json['total']),
    correct: _int(json['correct']),
    wrong: _int(json['wrong']),
    children: _mapList(json['children'], _sectionFromJson),
  );
}

Map<String, Object?> _paperToJson(Paper paper) {
  return {
    'id': paper.id,
    'title': paper.title,
    'done': paper.done,
    'total': paper.total,
    'correct': paper.correct,
    'wrong': paper.wrong,
    'minutes': paper.minutes,
  };
}

Paper _paperFromJson(Map<String, dynamic> json) {
  return Paper(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    done: _int(json['done']),
    total: _int(json['total']),
    correct: _int(json['correct']),
    wrong: _int(json['wrong']),
    minutes: _int(json['minutes']),
  );
}

Map<String, Object?> _recordToJson(StudyRecord record) {
  return {
    'id': record.id,
    'title': record.title,
    'mode': record.mode,
    'metric': record.metric,
    'time': record.time,
  };
}

StudyRecord _recordFromJson(Map<String, dynamic> json) {
  return StudyRecord(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    mode: json['mode']?.toString() ?? '',
    metric: json['metric']?.toString() ?? '',
    time: json['time']?.toString() ?? '',
  );
}

Map<String, Object?> _questionToJson(Question question) {
  return {
    'id': question.id,
    'type': question.type.name,
    'stem': question.stem,
    'stemHtml': question.stemHtml,
    'options': question.options,
    'answerIndexes': question.answerIndexes.toList()..sort(),
    'answerText': question.answerText,
    'analysis': question.analysis,
    'analysisHtml': question.analysisHtml,
    'imageUrls': question.imageUrls,
    'wrongCount': question.wrongCount,
    'lastWrongAt': question.lastWrongAt?.toIso8601String(),
  };
}

Question _questionFromJson(Map<String, dynamic> json) {
  return Question(
    id: json['id']?.toString() ?? '',
    type: _questionType(json['type']),
    stem: json['stem']?.toString() ?? '',
    stemHtml: json['stemHtml']?.toString() ?? '',
    options: _stringList(json['options']),
    answerIndexes: _intSet(json['answerIndexes']),
    answerText: json['answerText']?.toString() ?? '',
    analysis: json['analysis']?.toString() ?? '',
    analysisHtml: json['analysisHtml']?.toString() ?? '',
    imageUrls: _stringList(json['imageUrls']),
    wrongCount: _int(json['wrongCount']),
    lastWrongAt: DateTime.tryParse(json['lastWrongAt']?.toString() ?? ''),
  );
}

QuestionType _questionType(Object? value) {
  final name = value?.toString();
  return QuestionType.values.firstWhere(
    (type) => type.name == name,
    orElse: () => QuestionType.single,
  );
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

Set<int> _intSet(Object? value) {
  if (value is! List) return const {};
  return value.map((item) => _int(item)).toSet();
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

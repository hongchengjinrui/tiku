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
  static const currentVersion = 7;

  final int version;
  final DateTime savedAt;
  final List<Subject> subjects;
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
  final Map<String, int> wrongCorrectCounts;
  final int removedWrongCount;
  final List<FeedbackSubmission> feedbackSubmissions;
  final List<ResourceClaim> resourceClaims;
  final PracticeSessionSnapshot? activePracticeSession;
  final ExamSessionSnapshot? activeExamSession;
  final Map<String, List<Question>> catalogQuestionCache;
  final Map<String, SubjectStateSnapshot> localSubjectStates;

  const AppStateSnapshot({
    this.version = currentVersion,
    required this.savedAt,
    this.subjects = const [],
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
    this.wrongCorrectCounts = const {},
    this.removedWrongCount = 0,
    this.feedbackSubmissions = const [],
    this.resourceClaims = const [],
    this.activePracticeSession,
    this.activeExamSession,
    this.catalogQuestionCache = const {},
    this.localSubjectStates = const {},
  });

  factory AppStateSnapshot.fromJson(Map<String, dynamic> json) {
    return AppStateSnapshot(
      version: _int(json['version'], fallback: currentVersion),
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      subjects: _mapList(json['subjects'], _subjectFromJson),
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
      wrongCorrectCounts: _intMap(json['wrongCorrectCounts']),
      removedWrongCount: _int(json['removedWrongCount']),
      feedbackSubmissions:
          _mapList(json['feedbackSubmissions'], _feedbackFromJson),
      resourceClaims: _mapList(json['resourceClaims'], _resourceClaimFromJson),
      activePracticeSession:
          _practiceSessionSnapshotFromJson(json['activePracticeSession']),
      activeExamSession: _examSessionSnapshotFromJson(
        json['activeExamSession'],
      ),
      catalogQuestionCache:
          _questionCacheFromJson(json['catalogQuestionCache']),
      localSubjectStates: _subjectStatesFromJson(json['localSubjectStates']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'savedAt': savedAt.toIso8601String(),
      'subjects': subjects.map(_subjectToJson).toList(),
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
      'wrongCorrectCounts': wrongCorrectCounts,
      'removedWrongCount': removedWrongCount,
      'feedbackSubmissions': feedbackSubmissions.map(_feedbackToJson).toList(),
      'resourceClaims': resourceClaims.map(_resourceClaimToJson).toList(),
      'activePracticeSession': activePracticeSession?.toJson(),
      'activeExamSession': activeExamSession?.toJson(),
      'catalogQuestionCache': catalogQuestionCache.map(
        (key, value) => MapEntry(key, value.map(_questionToJson).toList()),
      ),
      'localSubjectStates': localSubjectStates.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class PracticeSessionSnapshot {
  final String title;
  final String mode;
  final String? sectionId;
  final String? paperId;
  final List<Question> questions;
  final int currentIndex;
  final bool finished;
  final Map<String, Set<int>> answers;
  final Map<String, String> textAnswers;
  final Set<String> resultQuestionIds;
  final Map<String, PracticeAnswerResult> answerResults;
  final int wrongRemovalThreshold;
  final bool reviewOnly;

  const PracticeSessionSnapshot({
    required this.title,
    required this.mode,
    this.sectionId,
    this.paperId,
    required this.questions,
    required this.currentIndex,
    required this.finished,
    this.answers = const {},
    this.textAnswers = const {},
    this.resultQuestionIds = const {},
    this.answerResults = const {},
    this.wrongRemovalThreshold = 0,
    this.reviewOnly = false,
  });

  factory PracticeSessionSnapshot.fromJson(Map<String, dynamic> json) {
    return PracticeSessionSnapshot(
      title: json['title']?.toString() ?? '',
      mode: json['mode']?.toString() ?? '',
      sectionId: json['sectionId']?.toString(),
      paperId: json['paperId']?.toString(),
      questions: _mapList(json['questions'], _questionFromJson),
      currentIndex: _int(json['currentIndex']),
      finished: json['finished'] == true,
      answers: _answerMap(json['answers']),
      textAnswers: _stringMap(json['textAnswers']),
      resultQuestionIds: _stringSet(json['resultQuestionIds']),
      answerResults: _answerResultMap(json['answerResults']),
      wrongRemovalThreshold: _int(json['wrongRemovalThreshold']),
      reviewOnly: json['reviewOnly'] == true,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'mode': mode,
      'sectionId': sectionId,
      'paperId': paperId,
      'questions': questions.map(_questionToJson).toList(),
      'currentIndex': currentIndex,
      'finished': finished,
      'answers': _answerMapToJson(answers),
      'textAnswers': textAnswers,
      'resultQuestionIds': resultQuestionIds.toList()..sort(),
      'answerResults': _answerResultMapToJson(answerResults),
      'wrongRemovalThreshold': wrongRemovalThreshold,
      'reviewOnly': reviewOnly,
    };
  }
}

class ExamSessionSnapshot {
  final String title;
  final String mode;
  final String? sectionId;
  final String? paperId;
  final List<Question> questions;
  final int durationMinutes;
  final int currentIndex;
  final bool submitted;
  final int remainingSeconds;
  final Map<String, Set<int>> answers;
  final Map<String, String> textAnswers;
  final Map<String, PracticeAnswerResult> answerResults;

  const ExamSessionSnapshot({
    required this.title,
    required this.mode,
    this.sectionId,
    this.paperId,
    required this.questions,
    required this.durationMinutes,
    required this.currentIndex,
    required this.submitted,
    required this.remainingSeconds,
    this.answers = const {},
    this.textAnswers = const {},
    this.answerResults = const {},
  });

  factory ExamSessionSnapshot.fromJson(Map<String, dynamic> json) {
    final durationMinutes = _int(json['durationMinutes'], fallback: 1);
    return ExamSessionSnapshot(
      title: json['title']?.toString() ?? '',
      mode: json['mode']?.toString() ?? '',
      sectionId: json['sectionId']?.toString(),
      paperId: json['paperId']?.toString(),
      questions: _mapList(json['questions'], _questionFromJson),
      durationMinutes: durationMinutes,
      currentIndex: _int(json['currentIndex']),
      submitted: json['submitted'] == true,
      remainingSeconds: _int(
        json['remainingSeconds'],
        fallback: durationMinutes * 60,
      ),
      answers: _answerMap(json['answers']),
      textAnswers: _stringMap(json['textAnswers']),
      answerResults: _answerResultMap(json['answerResults']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'mode': mode,
      'sectionId': sectionId,
      'paperId': paperId,
      'questions': questions.map(_questionToJson).toList(),
      'durationMinutes': durationMinutes,
      'currentIndex': currentIndex,
      'submitted': submitted,
      'remainingSeconds': remainingSeconds,
      'answers': _answerMapToJson(answers),
      'textAnswers': textAnswers,
      'answerResults': _answerResultMapToJson(answerResults),
    };
  }
}

class SubjectStateSnapshot {
  final List<Chapter> practiceChapters;
  final List<Chapter> examChapters;
  final List<Paper> practicePapers;
  final List<Paper> examPapers;
  final List<StudyRecord> practiceRecords;
  final List<StudyRecord> examRecords;
  final List<Question> favoriteQuestions;
  final List<Question> wrongQuestions;
  final Map<String, int> wrongCorrectCounts;
  final int removedWrongCount;
  final String selectedChapterId;
  final String selectedExamChapterId;

  const SubjectStateSnapshot({
    required this.practiceChapters,
    required this.examChapters,
    required this.practicePapers,
    required this.examPapers,
    required this.practiceRecords,
    required this.examRecords,
    required this.favoriteQuestions,
    required this.wrongQuestions,
    this.wrongCorrectCounts = const {},
    this.removedWrongCount = 0,
    required this.selectedChapterId,
    required this.selectedExamChapterId,
  });

  factory SubjectStateSnapshot.fromJson(Map<String, dynamic> json) {
    return SubjectStateSnapshot(
      practiceChapters: _mapList(json['practiceChapters'], _chapterFromJson),
      examChapters: _mapList(json['examChapters'], _chapterFromJson),
      practicePapers: _mapList(json['practicePapers'], _paperFromJson),
      examPapers: _mapList(json['examPapers'], _paperFromJson),
      practiceRecords: _mapList(json['practiceRecords'], _recordFromJson),
      examRecords: _mapList(json['examRecords'], _recordFromJson),
      favoriteQuestions: _mapList(json['favoriteQuestions'], _questionFromJson),
      wrongQuestions: _mapList(json['wrongQuestions'], _questionFromJson),
      wrongCorrectCounts: _intMap(json['wrongCorrectCounts']),
      removedWrongCount: _int(json['removedWrongCount']),
      selectedChapterId: json['selectedChapterId']?.toString() ?? '',
      selectedExamChapterId: json['selectedExamChapterId']?.toString() ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'practiceChapters': practiceChapters.map(_chapterToJson).toList(),
      'examChapters': examChapters.map(_chapterToJson).toList(),
      'practicePapers': practicePapers.map(_paperToJson).toList(),
      'examPapers': examPapers.map(_paperToJson).toList(),
      'practiceRecords': practiceRecords.map(_recordToJson).toList(),
      'examRecords': examRecords.map(_recordToJson).toList(),
      'favoriteQuestions': favoriteQuestions.map(_questionToJson).toList(),
      'wrongQuestions': wrongQuestions.map(_questionToJson).toList(),
      'wrongCorrectCounts': wrongCorrectCounts,
      'removedWrongCount': removedWrongCount,
      'selectedChapterId': selectedChapterId,
      'selectedExamChapterId': selectedExamChapterId,
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

Map<String, List<Question>> _questionCacheFromJson(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, rawQuestions) {
    return MapEntry(
      key.toString(),
      _mapList(rawQuestions, _questionFromJson),
    );
  })
    ..removeWhere((_, questions) => questions.isEmpty);
}

Map<String, SubjectStateSnapshot> _subjectStatesFromJson(Object? value) {
  if (value is! Map) return const {};
  final states = <String, SubjectStateSnapshot>{};
  for (final entry in value.entries) {
    final subjectId = entry.key.toString();
    final rawState = entry.value;
    if (subjectId.isEmpty || rawState is! Map) continue;
    states[subjectId] = SubjectStateSnapshot.fromJson(
      Map<String, dynamic>.from(rawState),
    );
  }
  return states;
}

PracticeSessionSnapshot? _practiceSessionSnapshotFromJson(Object? value) {
  if (value is! Map) return null;
  final snapshot = PracticeSessionSnapshot.fromJson(
    Map<String, dynamic>.from(value),
  );
  return snapshot.questions.isEmpty ? null : snapshot;
}

ExamSessionSnapshot? _examSessionSnapshotFromJson(Object? value) {
  if (value is! Map) return null;
  final snapshot = ExamSessionSnapshot.fromJson(
    Map<String, dynamic>.from(value),
  );
  return snapshot.questions.isEmpty ? null : snapshot;
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const {};
  return value.map(
    (key, rawValue) => MapEntry(key.toString(), _int(rawValue)),
  )..removeWhere((key, count) => key.isEmpty || count <= 0);
}

Map<String, Set<int>> _answerMap(Object? value) {
  if (value is! Map) return const {};
  final answers = <String, Set<int>>{};
  for (final entry in value.entries) {
    final questionId = entry.key.toString();
    final selected = _intSet(entry.value);
    if (questionId.isEmpty || selected.isEmpty) continue;
    answers[questionId] = selected;
  }
  return answers;
}

Map<String, List<int>> _answerMapToJson(Map<String, Set<int>> answers) {
  return answers.map((questionId, selected) {
    return MapEntry(questionId, selected.toList()..sort());
  })
    ..removeWhere((questionId, selected) {
      return questionId.isEmpty || selected.isEmpty;
    });
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const {};
  final strings = <String, String>{};
  for (final entry in value.entries) {
    final key = entry.key.toString();
    final text = entry.value?.toString() ?? '';
    if (key.isEmpty || text.trim().isEmpty) continue;
    strings[key] = text;
  }
  return strings;
}

Set<String> _stringSet(Object? value) {
  if (value is! List) return const {};
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toSet();
}

Map<String, Object?> _subjectToJson(Subject subject) {
  return {
    'id': subject.id,
    'name': subject.name,
    'isDefault': subject.isDefault,
  };
}

Subject _subjectFromJson(Map<String, dynamic> json) {
  return Subject(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    isDefault: json['isDefault'] == true,
  );
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
    'minutes': section.minutes,
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
    minutes: _int(json['minutes']),
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
    'practiceDetail': _practiceRecordDetailToJson(record.practiceDetail),
    'examDetail': _examRecordDetailToJson(record.examDetail),
  };
}

Map<String, Object?>? _practiceRecordDetailToJson(
  PracticeRecordDetail? detail,
) {
  if (detail == null) return null;
  return {
    'subjectId': detail.subjectId,
    'sectionId': detail.sectionId,
    'paperId': detail.paperId,
    'questions': detail.questions.map(_questionToJson).toList(),
    'currentIndex': detail.currentIndex,
    'answers': _answerMapToJson(detail.answers),
    'textAnswers': detail.textAnswers,
    'answerResults': _answerResultMapToJson(detail.answerResults),
  };
}

PracticeRecordDetail? _practiceRecordDetailFromJson(Object? value) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final questions = _mapList(json['questions'], _questionFromJson);
  if (questions.isEmpty) return null;
  return PracticeRecordDetail(
    subjectId: json['subjectId']?.toString(),
    sectionId: json['sectionId']?.toString(),
    paperId: json['paperId']?.toString(),
    questions: questions,
    currentIndex: _int(json['currentIndex']),
    answers: _answerMap(json['answers']),
    textAnswers: _stringMap(json['textAnswers']),
    answerResults: _answerResultMap(json['answerResults']),
  );
}

Map<String, Object?>? _examRecordDetailToJson(ExamRecordDetail? detail) {
  if (detail == null) return null;
  return {
    'subjectId': detail.subjectId,
    'sectionId': detail.sectionId,
    'paperId': detail.paperId,
    'questions': detail.questions.map(_questionToJson).toList(),
    'durationMinutes': detail.durationMinutes,
    'remainingSeconds': detail.remainingSeconds,
    'answers': _answerMapToJson(detail.answers),
    'textAnswers': detail.textAnswers,
    'answerResults': _answerResultMapToJson(detail.answerResults),
  };
}

ExamRecordDetail? _examRecordDetailFromJson(Object? value) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final questions = _mapList(json['questions'], _questionFromJson);
  if (questions.isEmpty) return null;
  final durationMinutes =
      _int(json['durationMinutes'], fallback: 1).clamp(1, 1440).toInt();
  return ExamRecordDetail(
    subjectId: _optionalString(json['subjectId']),
    sectionId: _optionalString(json['sectionId']),
    paperId: _optionalString(json['paperId']),
    questions: questions,
    durationMinutes: durationMinutes,
    remainingSeconds:
        _int(json['remainingSeconds']).clamp(0, durationMinutes * 60).toInt(),
    answers: _answerMap(json['answers']),
    textAnswers: _stringMap(json['textAnswers']),
    answerResults: _answerResultMap(json['answerResults']),
  );
}

Map<String, Object?> _feedbackToJson(FeedbackSubmission feedback) {
  return {
    'id': feedback.id,
    'type': feedback.type,
    'content': feedback.content,
    'payload': feedback.payload,
    'createdAt': feedback.createdAt.toIso8601String(),
  };
}

FeedbackSubmission _feedbackFromJson(Map<String, dynamic> json) {
  final payload = json['payload'];
  return FeedbackSubmission(
    id: json['id']?.toString() ?? '',
    type: json['type']?.toString() ?? 'general_feedback',
    content: json['content']?.toString() ?? '',
    payload: payload is Map ? Map<String, Object?>.from(payload) : const {},
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

Map<String, Object?> _resourceClaimToJson(ResourceClaim claim) {
  return {
    'resourceId': claim.resourceId,
    'title': claim.title,
    'link': claim.link,
    'subjectName': claim.subjectName,
    'isFree': claim.isFree,
    'count': claim.count,
    'lastClaimedAt': claim.lastClaimedAt.toIso8601String(),
  };
}

ResourceClaim _resourceClaimFromJson(Map<String, dynamic> json) {
  return ResourceClaim(
    resourceId: json['resourceId']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    link: json['link']?.toString() ?? '',
    subjectName: json['subjectName']?.toString(),
    isFree: json['isFree'] == true,
    count: _int(json['count'], fallback: 1).clamp(1, 9999).toInt(),
    lastClaimedAt: DateTime.tryParse(json['lastClaimedAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

StudyRecord _recordFromJson(Map<String, dynamic> json) {
  return StudyRecord(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    mode: json['mode']?.toString() ?? '',
    metric: json['metric']?.toString() ?? '',
    time: json['time']?.toString() ?? '',
    practiceDetail: _practiceRecordDetailFromJson(json['practiceDetail']),
    examDetail: _examRecordDetailFromJson(json['examDetail']),
  );
}

Map<String, Object?> _answerResultToJson(PracticeAnswerResult result) {
  return {
    'isCorrect': result.isCorrect,
    'score': result.score,
    'correctAnswerText': result.correctAnswerText,
    'myAnswerText': result.myAnswerText,
    'analysisText': result.analysisText,
    'scoreText': result.scoreText,
    'matchedPoints': result.matchedPoints,
    'reviewReason': result.reviewReason,
  };
}

PracticeAnswerResult _answerResultFromJson(Map<String, dynamic> json) {
  return PracticeAnswerResult(
    isCorrect: json['isCorrect'] is bool ? json['isCorrect'] as bool : null,
    score: json['score'] is num ? json['score'] as num : null,
    correctAnswerText: json['correctAnswerText']?.toString() ?? '',
    myAnswerText: json['myAnswerText']?.toString() ?? '',
    analysisText: json['analysisText']?.toString() ?? '',
    scoreText: _optionalString(json['scoreText']),
    matchedPoints: _stringList(json['matchedPoints']),
    reviewReason: _optionalString(json['reviewReason']),
  );
}

Map<String, PracticeAnswerResult> _answerResultMap(Object? value) {
  if (value is! Map) return const {};
  final results = <String, PracticeAnswerResult>{};
  for (final entry in value.entries) {
    final questionId = entry.key.toString();
    if (questionId.isEmpty || entry.value is! Map) continue;
    results[questionId] = _answerResultFromJson(
      Map<String, dynamic>.from(entry.value as Map),
    );
  }
  return results;
}

Map<String, Object?> _answerResultMapToJson(
  Map<String, PracticeAnswerResult> results,
) {
  return results.map(
    (questionId, result) => MapEntry(questionId, _answerResultToJson(result)),
  )..removeWhere((questionId, _) => questionId.isEmpty);
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
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
    'analysisImageUrls': question.analysisImageUrls,
    'materialGroupId': question.materialGroupId,
    'materialStem': question.materialStem,
    'materialStemHtml': question.materialStemHtml,
    'materialImageUrls': question.materialImageUrls,
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
    analysisImageUrls: _stringList(json['analysisImageUrls']),
    materialGroupId: _optionalString(json['materialGroupId']),
    materialStem: json['materialStem']?.toString() ?? '',
    materialStemHtml: json['materialStemHtml']?.toString() ?? '',
    materialImageUrls: _stringList(json['materialImageUrls']),
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

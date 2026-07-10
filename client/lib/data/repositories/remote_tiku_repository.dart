import 'package:dio/dio.dart';

import '../mock/models.dart';
import 'mock_tiku_repository.dart';

const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:3000/api',
);

const String defaultAppKey = String.fromEnvironment(
  'APP_KEY',
  defaultValue: 'grid-exam-android',
);

const String defaultDevUserId = String.fromEnvironment(
  'DEV_USER_ID',
  defaultValue: 'dev-user-001',
);

class RemoteTikuRepository extends MockTikuRepository {
  RemoteTikuRepository({
    String baseUrl = defaultApiBaseUrl,
    this.appKey = defaultAppKey,
    this.userId = defaultDevUserId,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

  final Dio _dio;
  final String appKey;
  final String userId;

  bool remoteReady = false;
  String? selectedSubjectId;

  List<Subject>? _subjects;
  List<Chapter>? _practiceChapters;
  List<Chapter>? _examChapters;
  List<Paper>? _practicePapers;
  List<Paper>? _examPapers;
  List<StudyRecord>? _practiceRecords;
  List<StudyRecord>? _examRecords;
  List<Question>? _favoriteQuestions;
  List<Question>? _wrongQuestions;
  final Map<String, List<Question>> _questionCache = {};

  Future<bool> warmUp() async {
    try {
      final bootstrap = await _dio.get<Map<String, dynamic>>(
        '/client/bootstrap',
        queryParameters: {'appKey': appKey, 'userId': userId},
      );
      final data = bootstrap.data ?? {};
      selectedSubjectId = data['defaultSubjectId']?.toString();
      _subjects = _parseSubjects(data['subjects'] as List<dynamic>? ?? []);
      final subjectId = selectedSubjectId ??
          (_subjects?.isNotEmpty == true ? _subjects!.first.id : null);
      if (subjectId == null) return false;

      final loaded = await loadSubject(subjectId);
      if (!loaded) return false;
      remoteReady = true;
      return true;
    } catch (_) {
      remoteReady = false;
      return false;
    }
  }

  Future<bool> loadSubject(String subjectId) async {
    try {
      final practiceTree = await _loadCatalog(subjectId, 'practice');
      final examTree = await _loadCatalog(subjectId, 'exam');
      final switchingSubject = selectedSubjectId != subjectId;
      final practiceChapters =
          _parseChapters(practiceTree, categoryName: '章节练习');
      final examChapters = _parseChapters(examTree, categoryName: '章节练习');
      final practicePapers = _parsePapers(practiceTree);
      final examPapers = _parsePapers(examTree);
      final practiceRecords = await _loadRecords(
        'practice',
        subjectId: subjectId,
        fallback: switchingSubject ? const [] : _practiceRecords ?? const [],
      );
      final examRecords = await _loadRecords(
        'exam',
        subjectId: subjectId,
        fallback: switchingSubject ? const [] : _examRecords ?? const [],
      );
      final favoriteQuestions =
          await fetchFavoriteQuestions(subjectId: subjectId);
      final wrongQuestions = await fetchWrongQuestions(subjectId: subjectId);

      _practiceChapters = practiceChapters;
      _examChapters = examChapters;
      _practicePapers = practicePapers;
      _examPapers = examPapers;
      _practiceRecords = practiceRecords;
      _examRecords = examRecords;
      _favoriteQuestions = favoriteQuestions;
      _wrongQuestions = wrongQuestions;
      _questionCache.clear();
      selectedSubjectId = subjectId;
      remoteReady = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Question>> fetchCatalogQuestions(String catalogId,
      {int limit = 20}) async {
    if (_questionCache.containsKey(catalogId)) {
      return _questionCache[catalogId]!;
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/client/catalogs/$catalogId/questions',
        queryParameters: {'limit': limit},
      );
      final questions = (response.data?['questions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_parseQuestion)
          .toList();
      if (questions.isNotEmpty) {
        _questionCache[catalogId] = questions;
      }
      return questions;
    } catch (_) {
      return const [];
    }
  }

  Future<List<Question>> fetchRandomPracticeQuestions({
    required String subjectId,
    List<String>? catalogIds,
    int count = 20,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/client/practice/random',
        data: {
          'subjectId': subjectId,
          if (catalogIds != null && catalogIds.isNotEmpty)
            'catalogIds': catalogIds,
          'count': count,
        },
      );
      return (response.data?['questions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_parseQuestion)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<Question>> fetchFavoriteQuestions({
    int limit = 50,
    String? subjectId,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/client/favorites',
        queryParameters: {
          'userId': userId,
          'limit': limit,
          if (subjectId != null) 'subjectId': subjectId,
        },
      );
      final questions = (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_parseQuestion)
          .toList();
      _favoriteQuestions = questions;
      return questions;
    } catch (_) {
      if (subjectId != null && subjectId != selectedSubjectId) {
        return const [];
      }
      return _favoriteQuestions ?? const [];
    }
  }

  Future<List<Question>> fetchWrongQuestions({
    int limit = 50,
    String? subjectId,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/client/wrong-questions',
        queryParameters: {
          'userId': userId,
          'limit': limit,
          if (subjectId != null) 'subjectId': subjectId,
        },
      );
      final questions = (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_parseWrongQuestion)
          .toList();
      _wrongQuestions = questions;
      return questions;
    } catch (_) {
      if (subjectId != null && subjectId != selectedSubjectId) {
        return const [];
      }
      return _wrongQuestions ?? const [];
    }
  }

  Future<bool?> toggleFavorite(Question question) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/client/favorites/${question.id}/toggle',
        data: {'userId': userId},
      );
      final favorited = response.data?['favorited'] == true;
      final next = [...?_favoriteQuestions];
      next.removeWhere((item) => item.id == question.id);
      if (favorited) next.insert(0, question);
      _favoriteQuestions = next;
      return favorited;
    } catch (_) {
      return null;
    }
  }

  bool isFavorite(String questionId) =>
      (_favoriteQuestions ?? const []).any((item) => item.id == questionId);

  List<Question> loadCachedFavoriteQuestions() =>
      _favoriteQuestions ?? const [];

  List<Question> loadCachedWrongQuestions() => _wrongQuestions ?? const [];

  Map<String, List<Question>> exportQuestionCache() {
    return _questionCache.map(
      (catalogId, questions) =>
          MapEntry(catalogId, List<Question>.of(questions)),
    );
  }

  void restoreQuestionCache(Map<String, List<Question>> cache) {
    if (cache.isEmpty) return;
    _questionCache
      ..clear()
      ..addAll(cache.map(
        (catalogId, questions) =>
            MapEntry(catalogId, List<Question>.of(questions)),
      ));
  }

  Future<bool> removeWrongQuestion(String questionId) async {
    try {
      await _dio.delete(
        '/client/wrong-questions/$questionId',
        queryParameters: {'userId': userId},
      );
      _wrongQuestions =
          [...?_wrongQuestions].where((item) => item.id != questionId).toList();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearWrongQuestions({
    List<String> questionIds = const [],
    String? subjectId,
  }) async {
    try {
      await _dio.post('/client/wrong-questions/clear', data: {
        'userId': userId,
        if (questionIds.isNotEmpty) 'questionIds': questionIds,
        if (subjectId != null) 'subjectId': subjectId,
      });
      final ids = questionIds.toSet();
      _wrongQuestions = ids.isEmpty
          ? const []
          : [...?_wrongQuestions]
              .where((item) => !ids.contains(item.id))
              .toList();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshRecords() async {
    _practiceRecords = await _loadRecords(
      'practice',
      subjectId: selectedSubjectId,
      fallback: _practiceRecords ?? const [],
    );
    _examRecords = await _loadRecords(
      'exam',
      subjectId: selectedSubjectId,
      fallback: _examRecords ?? const [],
    );
  }

  Future<bool> deleteRecords(String mode, {String? subjectId}) async {
    try {
      await _dio.delete(
        '/client/records',
        queryParameters: {
          'userId': userId,
          'appKey': appKey,
          'mode': mode,
          if (subjectId != null) 'subjectId': subjectId,
        },
      );
      if (mode == 'practice') {
        _practiceRecords = const [];
      } else {
        _examRecords = const [];
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRecord(String mode, String recordId) async {
    try {
      await _dio.delete(
        '/client/records',
        queryParameters: {
          'userId': userId,
          'appKey': appKey,
          'mode': mode,
          'recordId': recordId,
        },
      );
      if (mode == 'practice') {
        _practiceRecords = [...?_practiceRecords]
            .where((item) => item.id != recordId)
            .toList();
      } else {
        _examRecords =
            [...?_examRecords].where((item) => item.id != recordId).toList();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetProgress({
    required String mode,
    required List<String> catalogIds,
  }) async {
    if (catalogIds.isEmpty) return false;
    try {
      await _dio.post('/client/progress/reset', data: {
        'userId': userId,
        'appKey': appKey,
        'mode': mode,
        'catalogIds': catalogIds,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitQuestionFeedback({
    required Question question,
    required String content,
    String type = 'question_error',
  }) async {
    try {
      await _dio.post('/client/feedback', data: {
        'userId': userId,
        'appKey': appKey,
        'questionId': question.id,
        'type': type,
        'content': content,
        'payload': {
          'stem': question.stem,
          'questionType': question.type.label,
        },
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitGeneralFeedback({
    required String content,
    String type = 'general_feedback',
    Map<String, Object?> payload = const {},
    String? questionId,
  }) async {
    try {
      await _dio.post('/client/feedback', data: {
        'userId': userId,
        'appKey': appKey,
        if (questionId != null && questionId.isNotEmpty)
          'questionId': questionId,
        'type': type,
        'content': content,
        'payload': payload,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<PracticeAnswerResult?> submitPracticeAnswer({
    required Question question,
    Set<int> selected = const {},
    String? text,
    int wrongRemovalThreshold = 0,
  }) async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>('/client/answers', data: {
        'userId': userId,
        'appKey': appKey,
        'questionId': question.id,
        'mode': 'practice',
        if (selected.isNotEmpty)
          'values': selected
              .where((index) => index >= 0 && index < question.options.length)
              .map((index) => _optionKey(index))
              .toList(),
        if (text != null) 'text': text,
        if (wrongRemovalThreshold > 0)
          'wrongRemovalThreshold': wrongRemovalThreshold,
      });
      return _parseAnswerResult(
        response.data ?? {},
        fallbackQuestion: question,
        selected: selected,
        submittedText: text,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitExamResult(
    ExamSession session, {
    String? subjectId,
  }) async {
    try {
      final answerPayloads = <Map<String, dynamic>>[
        ...session.answers.entries.map((entry) {
          final question = session.questions.firstWhere(
            (item) => item.id == entry.key,
            orElse: () => session.questions.first,
          );
          return {
            'questionId': entry.key,
            'values': entry.value
                .where((index) => index >= 0 && index < question.options.length)
                .map((index) => _optionKey(index))
                .toList(),
          };
        }),
        ...session.textAnswers.entries
            .where((entry) => !session.answers.containsKey(entry.key))
            .map((entry) => {
                  'questionId': entry.key,
                  'text': entry.value,
                }),
      ];
      await _dio.post('/client/exams/submit', data: {
        'userId': userId,
        'appKey': appKey,
        'title': session.title,
        'mode': session.mode,
        'durationMinutes': session.durationMinutes,
        'remainingSeconds': session.remainingSeconds,
        if (subjectId != null) 'subjectId': subjectId,
        if (session.sectionId != null) 'sectionId': session.sectionId,
        if (session.paperId != null) 'paperId': session.paperId,
        'questionIds':
            session.questions.map((question) => question.id).toList(),
        'answers': answerPayloads,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  List<Subject> loadSubjects() => _subjects ?? super.loadSubjects();

  @override
  List<Chapter> loadPracticeChapters() =>
      _practiceChapters ?? super.loadPracticeChapters();

  @override
  List<Chapter> loadExamChapters() => _examChapters ?? super.loadExamChapters();

  @override
  List<Paper> loadPracticePapers() =>
      _practicePapers ?? super.loadPracticePapers();

  @override
  List<Paper> loadExamPapers() => _examPapers ?? super.loadExamPapers();

  @override
  List<StudyRecord> loadPracticeRecords() =>
      _practiceRecords ?? super.loadPracticeRecords();

  @override
  List<StudyRecord> loadExamRecords() =>
      _examRecords ?? super.loadExamRecords();

  @override
  List<Question> buildPracticeSectionQuestions(Section section) =>
      _questionCache[section.id] ??
      super.buildPracticeSectionQuestions(section);

  @override
  List<Question> buildPracticePaperQuestions(Paper paper) =>
      _questionCache[paper.id] ?? super.buildPracticePaperQuestions(paper);

  @override
  List<Question> buildExamSectionQuestions(Section section) =>
      _questionCache[section.id] ?? super.buildExamSectionQuestions(section);

  @override
  List<Question> buildExamPaperQuestions(Paper paper) =>
      _questionCache[paper.id] ?? super.buildExamPaperQuestions(paper);

  Future<List<Map<String, dynamic>>> _loadCatalog(
    String subjectId,
    String mode,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/client/subjects/$subjectId/catalog',
      queryParameters: {'userId': userId, 'mode': mode},
    );
    return (response.data?['nodes'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<List<StudyRecord>> _loadRecords(
    String mode, {
    String? subjectId,
    List<StudyRecord> fallback = const [],
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/client/records',
        queryParameters: {
          'userId': userId,
          'appKey': appKey,
          'mode': mode,
          if (subjectId != null) 'subjectId': subjectId,
        },
      );
      return (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) {
        final payload = item['payload'] is Map<String, dynamic>
            ? item['payload'] as Map<String, dynamic>
            : <String, dynamic>{};
        final correct = payload['isCorrect'] == true || item['correct'] == true;
        final score = item['score'];
        final accuracy = item['accuracy'] ?? score;
        final createdAt = item['createdAt']?.toString();
        final examDetail =
            mode == 'exam' ? _parseExamRecordDetail(payload) : null;
        return StudyRecord(
          id: item['id']?.toString() ?? '',
          title: mode == 'practice'
              ? (item['mode'] ?? item['questionTitle'] ?? '练习记录').toString()
              : (item['title'] ?? '考试记录').toString(),
          mode: mode == 'practice' ? '章节练习' : (item['mode'] ?? '考试').toString(),
          metric: score != null
              ? '${_formatNumber(score)}分 · 正确率 ${_formatNumber(accuracy)}%'
              : (correct ? '回答正确' : '回答错误'),
          time: _formatRecordTime(createdAt),
          examDetail: examDetail,
        );
      }).toList();
    } catch (_) {
      return fallback;
    }
  }

  List<Subject> _parseSubjects(List<dynamic> raw) {
    return raw.whereType<Map<String, dynamic>>().map((item) {
      return Subject(
        id: item['id'].toString(),
        name: item['name'].toString(),
        isDefault: item['isDefault'] == true,
      );
    }).toList();
  }

  List<Chapter> _parseChapters(
    List<Map<String, dynamic>> roots, {
    required String categoryName,
  }) {
    final category = roots.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['name'] == categoryName,
          orElse: () => null,
        );
    final chapterNodes = (category?['children'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    return chapterNodes.map((chapter) {
      final sections = (chapter['children'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>();
      final chapterId = chapter['id'].toString();
      final parsedSections =
          sections.map((section) => _parseSection(section, chapterId)).toList();
      final progress = _progress(chapter);
      return Chapter(
        id: chapter['id'].toString(),
        title: chapter['name'].toString(),
        done: progress.done,
        total: progress.total,
        correct: progress.correct,
        wrong: progress.wrong,
        sections: parsedSections,
      );
    }).toList();
  }

  List<Paper> _parsePapers(List<Map<String, dynamic>> roots) {
    final category = roots.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?['name'] == '模拟真题',
          orElse: () => null,
        );
    final groups = (category?['children'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    return groups.expand((group) {
      final papers = (group['children'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>();
      return papers.map((paper) {
        final progress = _progress(paper);
        return Paper(
          id: paper['id'].toString(),
          title: paper['name'].toString(),
          done: progress.done,
          total: progress.total,
          correct: progress.correct,
          wrong: progress.wrong,
          minutes: 0,
        );
      });
    }).toList();
  }

  Section _parseSection(Map<String, dynamic> item, String chapterId) {
    final progress = _progress(item);
    final children = (item['children'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((child) => _parseSection(child, chapterId))
        .toList();
    return Section(
      id: item['id'].toString(),
      chapterId: chapterId,
      title: item['name'].toString(),
      done: progress.done,
      total: progress.total,
      correct: progress.correct,
      wrong: progress.wrong,
      children: children,
    );
  }

  Question _parseQuestion(Map<String, dynamic> item) {
    final options = (item['options'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((option) => option['text'].toString())
        .toList();
    final stemHtml = (item['stemHtml'] ?? '').toString();
    final analysisHtml = (item['analysisHtml'] ?? '').toString();
    return Question(
      id: item['id'].toString(),
      type: _questionType(item['type'].toString()),
      stem: (item['stemText'] ?? item['stemHtml'] ?? '').toString(),
      stemHtml: stemHtml,
      options: options,
      answerIndexes: _answerIndexes(item['answer'], options.length),
      answerText: _answerDisplay(item['answer'], options.length),
      analysis: (item['analysisText'] ?? item['analysisHtml'] ?? '').toString(),
      analysisHtml: analysisHtml,
      imageUrls: _imageUrls(stemHtml),
    );
  }

  Question _parseWrongQuestion(Map<String, dynamic> item) {
    final question = item['question'];
    final parsed = _parseQuestion(
      question is Map<String, dynamic> ? question : item,
    );
    return parsed.copyWith(
      wrongCount: _int(item['wrongCount']),
      lastWrongAt: DateTime.tryParse(item['lastWrongAt']?.toString() ?? ''),
    );
  }

  PracticeAnswerResult _parseAnswerResult(
    Map<String, dynamic> data, {
    required Question fallbackQuestion,
    required Set<int> selected,
    String? submittedText,
  }) {
    final question = data['question'] is Map<String, dynamic>
        ? data['question'] as Map<String, dynamic>
        : <String, dynamic>{};
    final shortAnswer = data['shortAnswer'] is Map<String, dynamic>
        ? data['shortAnswer'] as Map<String, dynamic>
        : <String, dynamic>{};
    final actualScore = shortAnswer['actualScore'];
    final totalScore = shortAnswer['questionActualScore'];
    final matchedPoints = (shortAnswer['matchedPoints'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((point) => point['hit'] == true)
        .map((point) => (point['title'] ?? point['evidence'] ?? '').toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
    return PracticeAnswerResult(
      isCorrect: data['isCorrect'] is bool ? data['isCorrect'] as bool : null,
      score: data['score'] is num ? data['score'] as num : null,
      correctAnswerText: _answerDisplay(
        question['answer'] ?? fallbackQuestion.answerText,
        fallbackQuestion.options.length,
      ),
      myAnswerText: submittedText?.trim().isNotEmpty == true
          ? submittedText!.trim()
          : _answerTextFromIndexes(selected),
      analysisText: (question['analysisText'] ??
              question['analysisHtml'] ??
              fallbackQuestion.analysis)
          .toString(),
      scoreText: actualScore != null && totalScore != null
          ? '${_formatNumber(actualScore)}/${_formatNumber(totalScore)}'
          : null,
      matchedPoints: matchedPoints,
      reviewReason: shortAnswer['reviewReason']?.toString(),
    );
  }

  ExamRecordDetail? _parseExamRecordDetail(Map<String, dynamic> payload) {
    final rawResults = (payload['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final rawQuestions = (payload['questions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final questionMaps = rawQuestions.isNotEmpty
        ? rawQuestions
        : rawResults
            .map((result) => result['question'])
            .whereType<Map<String, dynamic>>()
            .toList();
    final questions = <Question>[];
    final questionIds = <String>{};
    for (final item in questionMaps) {
      final question = _parseQuestion(item);
      if (question.id.isEmpty || !questionIds.add(question.id)) continue;
      questions.add(question);
    }
    if (questions.isEmpty) return null;

    final questionsById = {
      for (final question in questions) question.id: question,
    };
    final answers = <String, Set<int>>{};
    final textAnswers = <String, String>{};
    for (final item in (payload['answers'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()) {
      final questionId = item['questionId']?.toString() ?? '';
      final question = questionsById[questionId];
      if (question == null) continue;
      final text = item['text']?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        textAnswers[questionId] = text;
        continue;
      }
      final selected = _submittedAnswerIndexes(
        item['values'],
        question.options.length,
      );
      if (selected.isNotEmpty) answers[questionId] = selected;
    }

    final answerResults = <String, PracticeAnswerResult>{};
    for (final result in rawResults) {
      final questionData = result['question'];
      final questionId = questionData is Map<String, dynamic>
          ? questionData['id']?.toString() ?? ''
          : result['questionId']?.toString() ?? '';
      final question = questionsById[questionId];
      if (question == null) continue;
      answerResults[questionId] = _parseAnswerResult(
        result,
        fallbackQuestion: question,
        selected: answers[questionId] ?? const {},
        submittedText: textAnswers[questionId],
      );
    }

    final durationMinutes = _int(payload['durationMinutes']).clamp(1, 1440);
    return ExamRecordDetail(
      subjectId: _nullableString(payload['subjectId']),
      sectionId: _nullableString(payload['sectionId']),
      paperId: _nullableString(payload['paperId']),
      questions: questions,
      durationMinutes: durationMinutes,
      remainingSeconds: _int(payload['remainingSeconds'])
          .clamp(0, durationMinutes * 60)
          .toInt(),
      answers: answers,
      textAnswers: textAnswers,
      answerResults: answerResults,
    );
  }

  Set<int> _submittedAnswerIndexes(dynamic values, int optionCount) {
    if (values is! List || optionCount <= 0) return const {};
    return values
        .map((item) => item.toString().trim().toUpperCase())
        .where((key) => key.isNotEmpty)
        .map((key) => key.codeUnitAt(0) - 65)
        .where((index) => index >= 0 && index < optionCount)
        .toSet();
  }

  String? _nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  _Progress _progress(Map<String, dynamic> item) {
    final progress = item['progress'] is Map<String, dynamic>
        ? item['progress'] as Map<String, dynamic>
        : <String, dynamic>{};
    return _Progress(
      done: _int(progress['done']),
      total: _int(progress['total'] ?? item['questionCount']),
      correct: _int(progress['correct']),
      wrong: _int(progress['wrong']),
    );
  }

  QuestionType _questionType(String type) {
    return switch (type) {
      'multiple_choice' => QuestionType.multiple,
      'true_false' => QuestionType.trueFalse,
      'fill_blank' => QuestionType.fillBlank,
      'short_answer' => QuestionType.shortAnswer,
      'material' => QuestionType.material,
      _ => QuestionType.single,
    };
  }

  Set<int> _answerIndexes(dynamic answer, int optionCount) {
    if (optionCount == 0) return {};
    if (answer is! Map<String, dynamic>) return {0};
    final values = (answer['values'] as List<dynamic>? ?? []).map((item) {
      final key = item.toString().trim().toUpperCase();
      final code = key.isEmpty ? 65 : key.codeUnitAt(0);
      return code - 65;
    }).where((index) => index >= 0 && index < optionCount);
    final set = values.toSet();
    return set.isEmpty ? {0} : set;
  }

  String _answerDisplay(dynamic answer, int optionCount) {
    if (answer is String) return _cleanAnswerText(answer);
    if (answer is! Map<String, dynamic>) return '';
    final values = answer['values'];
    if (values is List && values.isNotEmpty) {
      return values.map((item) => _cleanAnswerText(item.toString())).join('、');
    }
    final blanks = answer['blanks'];
    if (blanks is List && blanks.isNotEmpty) {
      return blanks.map((item) {
        if (item is Map<String, dynamic>) {
          final accepted = item['accepted'];
          if (accepted is List && accepted.isNotEmpty) {
            return _cleanAnswerText(accepted.first.toString());
          }
        }
        return _cleanAnswerText(item.toString());
      }).join('；');
    }
    final expected = answer['expected'] ?? answer['raw'];
    return _cleanAnswerText(expected?.toString() ?? '');
  }

  String _cleanAnswerText(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final inner = trimmed
          .substring(1, trimmed.length - 1)
          .split(',')
          .map((item) => _stripWrappingQuotes(item.trim()))
          .where((item) => item.isNotEmpty)
          .join('；');
      if (inner.isNotEmpty) return inner;
    }
    return trimmed;
  }

  String _stripWrappingQuotes(String value) {
    if (value.length < 2) return value;
    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  String _answerTextFromIndexes(Set<int> indexes) {
    if (indexes.isEmpty) return '未作答';
    final sorted = indexes.toList()..sort();
    return sorted.map(_optionKey).join('、');
  }

  List<String> _imageUrls(String html) {
    if (html.isEmpty) return const [];
    final pattern =
        RegExp("<img[^>]+src=[\"']([^\"']+)[\"']", caseSensitive: false);
    return pattern
        .allMatches(html)
        .map((match) => match.group(1)?.trim() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String _optionKey(int index) => String.fromCharCode(65 + index);

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatNumber(dynamic value) {
    final number = value is num ? value : num.tryParse(value?.toString() ?? '');
    if (number == null) return value?.toString() ?? '0';
    if (number % 1 == 0) return number.round().toString();
    return number.toStringAsFixed(1);
  }

  String _formatRecordTime(String? raw) {
    if (raw == null || raw.isEmpty) return '刚刚';
    final time = DateTime.tryParse(raw)?.toLocal();
    if (time == null) return '刚刚';
    final now = DateTime.now();
    final delta = now.difference(time);
    if (delta.inMinutes < 1) return '刚刚';
    if (delta.inHours < 1) return '${delta.inMinutes}分钟前';
    if (delta.inDays < 1) return '${delta.inHours}小时前';
    return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _Progress {
  final int done;
  final int total;
  final int correct;
  final int wrong;

  const _Progress({
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
  });
}

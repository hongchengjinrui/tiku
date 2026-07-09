import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/remote_tiku_repository.dart';
import '../repositories/tiku_repository.dart';
import 'models.dart';

final _remoteRepository = RemoteTikuRepository();
final appStore = AppStore(repository: _remoteRepository);

// Backward-compatible alias while screens are migrated to provider injection.
final mockStore = appStore;

typedef MockAppStore = AppStore;

class AppStore extends ChangeNotifier {
  TikuRepository repository;
  bool remoteReady = false;

  AppStore({required this.repository}) {
    _loadInitialState();
  }

  late List<Subject> subjects;
  late List<Chapter> chapters;
  late List<Chapter> examChapters;
  late List<Paper> practicePapers;
  late List<Paper> examPapers;
  late List<StudyRecord> practiceRecords;
  late List<StudyRecord> examRecords;
  List<Question> favoriteQuestions = const [];
  List<Question> wrongQuestions = const [];

  String selectedSubjectId = 'primary_teacher';
  String selectedChapterId = 'chapter_1';
  String selectedExamChapterId = 'chapter_1';

  PracticeSession? practiceSession;
  ExamSession? examSession;

  void _loadInitialState() {
    subjects = repository.loadSubjects();
    chapters = repository.loadPracticeChapters();
    examChapters = repository.loadExamChapters();
    practicePapers = repository.loadPracticePapers();
    examPapers = repository.loadExamPapers();
    practiceRecords = repository.loadPracticeRecords();
    examRecords = repository.loadExamRecords();
    final current = repository;
    if (current is RemoteTikuRepository) {
      favoriteQuestions = current.loadCachedFavoriteQuestions();
      wrongQuestions = current.loadCachedWrongQuestions();
    }
  }

  Future<void> hydrateRemote() async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final loaded = await current.warmUp();
    if (!loaded) return;
    remoteReady = true;
    _loadInitialState();
    selectedSubjectId = current.selectedSubjectId ?? subjects.first.id;
    selectedChapterId =
        chapters.isNotEmpty ? chapters.first.id : selectedChapterId;
    selectedExamChapterId =
        examChapters.isNotEmpty ? examChapters.first.id : selectedExamChapterId;
    notifyListeners();
  }

  Subject get selectedSubject => subjects.firstWhere(
        (subject) => subject.id == selectedSubjectId,
        orElse: () => subjects.first,
      );

  Chapter get selectedChapter =>
      chapters.firstWhere((chapter) => chapter.id == selectedChapterId);

  Chapter get selectedExamChapter =>
      examChapters.firstWhere((chapter) => chapter.id == selectedExamChapterId);

  PracticeStat get practiceStat => _combinedStat(chapters, practicePapers);

  PracticeStat get examStat => _combinedStat(examChapters, examPapers);

  PracticeStat get practiceChapterStat => _chapterStat(chapters);

  PracticeStat get practicePaperStat => _paperStat(practicePapers);

  PracticeStat get examChapterStat => _chapterStat(examChapters);

  PracticeStat get examPaperStat => _paperStat(examPapers);

  int get wrongPracticeCount =>
      remoteReady ? wrongQuestions.length : practiceStat.wrong;

  int get favoritePracticeCount => remoteReady
      ? favoriteQuestions.length
      : (favoriteQuestions.isNotEmpty ? favoriteQuestions.length : 16);

  Future<void> selectSubject(String subjectId) async {
    selectedSubjectId = subjectId;
    practiceSession = null;
    examSession = null;
    notifyListeners();
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final loaded = await current.loadSubject(subjectId);
    if (!loaded || selectedSubjectId != subjectId) return;
    _loadInitialState();
    selectedSubjectId = subjectId;
    _resetSelectedCatalogs();
    notifyListeners();
  }

  void selectChapter(String chapterId) {
    selectedChapterId = chapterId;
    notifyListeners();
  }

  void selectExamChapter(String chapterId) {
    selectedExamChapterId = chapterId;
    notifyListeners();
  }

  void startPracticeFromSection(String sectionId, {bool notify = true}) {
    final section =
        _allSections(chapters).firstWhere((item) => item.id == sectionId);
    practiceSession = PracticeSession(
      title: section.title,
      mode: '章节练习',
      sectionId: section.id,
      questions: repository.buildPracticeSectionQuestions(section),
    );
    if (notify) notifyListeners();
    _hydratePracticeQuestionsFromRemote(section);
  }

  void startPracticeFromPaper(String paperId, {bool notify = true}) {
    final paper = practicePapers.firstWhere((item) => item.id == paperId);
    practiceSession = PracticeSession(
      title: paper.title,
      mode: '真题练习',
      paperId: paper.id,
      questions: repository.buildPracticePaperQuestions(paper),
    );
    if (notify) notifyListeners();
    _hydratePracticeQuestionsFromRemote(paper);
  }

  void startPracticeFromRecord(StudyRecord record, {required bool restart}) {
    if (record.mode.contains('随机')) {
      startRandomPractice();
      if (!restart) _movePracticeIndexToProgress(record.metric);
      return;
    }
    if (record.mode.contains('收藏')) {
      startFavoritePractice();
      if (!restart) _movePracticeIndexToProgress(record.metric);
      return;
    }
    if (record.mode.contains('错题')) {
      startWrongPractice();
      if (!restart) _movePracticeIndexToProgress(record.metric);
      return;
    }
    if (record.mode.contains('真题')) {
      final paper = _findPracticePaper(record.title);
      startPracticeFromPaper((paper ?? practicePapers.first).id);
      if (!restart) _movePracticeIndexToProgress(record.metric);
      return;
    }
    final section =
        _findPracticeSection(record.title) ?? _allSections(chapters).first;
    startPracticeFromSection(section.id);
    if (!restart) _movePracticeIndexToProgress(record.metric);
  }

  void startRandomPractice({
    int count = 10,
    List<String> catalogIds = const [],
    bool notify = true,
  }) {
    practiceSession = PracticeSession(
      title: catalogIds.isEmpty ? '随机练习' : '自选章节随机练习',
      mode: '随机练习',
      questions: repository.buildRandomPracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
    _hydrateRandomPracticeQuestions(count, catalogIds: catalogIds);
  }

  void startFavoritePractice({
    int count = 6,
    List<Question> questions = const [],
    bool notify = true,
  }) {
    final sourceQuestions = questions.isNotEmpty
        ? questions
        : favoriteQuestions.take(count).toList();
    if (remoteReady && sourceQuestions.isEmpty) {
      practiceSession = null;
      if (notify) notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: '收藏练习',
      mode: '收藏练习',
      questions: sourceQuestions.isNotEmpty
          ? sourceQuestions
          : repository.buildFavoritePracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
    if (questions.isEmpty) {
      _hydrateFavoritePracticeQuestions(count);
    }
  }

  void startWrongPractice({
    int count = 8,
    List<Question> questions = const [],
    bool notify = true,
  }) {
    final sourceQuestions =
        questions.isNotEmpty ? questions : wrongQuestions.take(count).toList();
    if (remoteReady && sourceQuestions.isEmpty) {
      practiceSession = null;
      if (notify) notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: '错题练习',
      mode: '错题练习',
      questions: sourceQuestions.isNotEmpty
          ? sourceQuestions
          : repository.buildWrongPracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
    _hydrateWrongPracticeQuestions(count);
  }

  void answerPractice(Set<int> answer) {
    final session = practiceSession;
    if (session == null) return;
    final question = session.currentQuestion;
    if (answer.isEmpty) {
      session.answers.remove(question.id);
      session.answerResults.remove(question.id);
    } else {
      session.answers[question.id] = answer;
      session.textAnswers.remove(question.id);
      session.answerResults[question.id] = _localChoiceResult(question, answer);
    }
    final current = repository;
    if (current is RemoteTikuRepository && answer.isNotEmpty) {
      unawaited(_submitPracticeAnswer(question: question, selected: answer));
    }
    notifyListeners();
  }

  void answerPracticeText(String text) {
    final session = practiceSession;
    if (session == null) return;
    final question = session.currentQuestion;
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      session.textAnswers.remove(question.id);
      session.answerResults.remove(question.id);
      notifyListeners();
      return;
    }
    session.textAnswers[question.id] = trimmed;
    session.answers.remove(question.id);
    session.answerResults[question.id] = _localTextResult(question, trimmed);
    final current = repository;
    if (current is RemoteTikuRepository) {
      unawaited(_submitPracticeAnswer(question: question, text: trimmed));
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Question question) async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      await current.toggleFavorite(question);
      favoriteQuestions = current.loadCachedFavoriteQuestions();
      notifyListeners();
      return;
    }
    final exists = favoriteQuestions.any((item) => item.id == question.id);
    favoriteQuestions = exists
        ? favoriteQuestions.where((item) => item.id != question.id).toList()
        : [question, ...favoriteQuestions];
    notifyListeners();
  }

  Future<bool> removeWrongQuestion(Question question) async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.removeWrongQuestion(question.id);
      if (!ok) return false;
    }
    _dropWrongQuestions({question.id});
    notifyListeners();
    return true;
  }

  Future<bool> clearWrongQuestions(
      {List<Question> questions = const []}) async {
    final ids = questions.isEmpty
        ? wrongQuestions.map((question) => question.id).toSet()
        : questions.map((question) => question.id).toSet();
    if (ids.isEmpty) return true;

    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.clearWrongQuestions(
        questionIds: ids.toList(),
        subjectId: selectedSubjectId,
      );
      if (!ok) return false;
    }
    _dropWrongQuestions(ids);
    notifyListeners();
    return true;
  }

  Future<bool> resetPracticeProgress(
      {List<String> catalogIds = const []}) async {
    final ids = catalogIds.isEmpty ? _allPracticeCatalogIds() : catalogIds;
    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.resetProgress(mode: 'practice', catalogIds: ids);
      if (!ok) return false;
      _loadInitialState();
      selectedChapterId =
          chapters.isNotEmpty ? chapters.first.id : selectedChapterId;
      notifyListeners();
      return true;
    }
    _resetPracticeCatalogs(ids.toSet());
    notifyListeners();
    return true;
  }

  Future<bool> resetExamProgress({List<String> catalogIds = const []}) async {
    final ids = catalogIds.isEmpty ? _allExamCatalogIds() : catalogIds;
    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.resetProgress(mode: 'exam', catalogIds: ids);
      if (!ok) return false;
      _loadInitialState();
      selectedExamChapterId = examChapters.isNotEmpty
          ? examChapters.first.id
          : selectedExamChapterId;
      notifyListeners();
      return true;
    }
    _resetExamCatalogs(ids.toSet());
    notifyListeners();
    return true;
  }

  Future<bool> deletePracticeRecords() async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.deleteRecords('practice');
      if (!ok) return false;
    }
    practiceRecords = const [];
    notifyListeners();
    return true;
  }

  Future<bool> deletePracticeRecord(StudyRecord record) async {
    final current = repository;
    if (current is RemoteTikuRepository && record.id.isNotEmpty) {
      final ok = await current.deleteRecord('practice', record.id);
      if (!ok) return false;
    }
    practiceRecords =
        practiceRecords.where((item) => !_sameRecord(item, record)).toList();
    notifyListeners();
    return true;
  }

  Future<bool> deleteExamRecords() async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      final ok = await current.deleteRecords('exam');
      if (!ok) return false;
    }
    examRecords = const [];
    notifyListeners();
    return true;
  }

  Future<bool> deleteExamRecord(StudyRecord record) async {
    final current = repository;
    if (current is RemoteTikuRepository && record.id.isNotEmpty) {
      final ok = await current.deleteRecord('exam', record.id);
      if (!ok) return false;
    }
    examRecords =
        examRecords.where((item) => !_sameRecord(item, record)).toList();
    notifyListeners();
    return true;
  }

  Future<bool> submitQuestionFeedback(
    Question question, {
    required String content,
    String type = 'question_error',
  }) async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      return current.submitQuestionFeedback(
        question: question,
        content: content,
        type: type,
      );
    }
    return true;
  }

  Future<bool> submitFeedback({
    required String content,
    String type = 'general_feedback',
    Map<String, Object?> payload = const {},
  }) async {
    final current = repository;
    if (current is RemoteTikuRepository) {
      return current.submitGeneralFeedback(
        content: content,
        type: type,
        payload: payload,
      );
    }
    return true;
  }

  bool isQuestionFavorite(String questionId) =>
      favoriteQuestions.any((item) => item.id == questionId);

  void _dropWrongQuestions(Set<String> questionIds) {
    wrongQuestions = wrongQuestions
        .where((question) => !questionIds.contains(question.id))
        .toList();
    final session = practiceSession;
    if (session == null || session.mode != '错题练习') return;
    final nextQuestions = session.questions
        .where((question) => !questionIds.contains(question.id))
        .toList();
    if (nextQuestions.isEmpty) {
      practiceSession = null;
      return;
    }
    practiceSession = PracticeSession(
      title: session.title,
      mode: session.mode,
      sectionId: session.sectionId,
      paperId: session.paperId,
      questions: nextQuestions,
      currentIndex:
          session.currentIndex.clamp(0, nextQuestions.length - 1).toInt(),
      finished: session.finished,
      answers: session.answers,
      textAnswers: session.textAnswers,
      answerResults: session.answerResults,
      submittingQuestionIds: session.submittingQuestionIds,
    );
  }

  Future<void> _submitPracticeAnswer({
    required Question question,
    Set<int> selected = const {},
    String? text,
  }) async {
    final current = repository;
    final session = practiceSession;
    if (current is! RemoteTikuRepository || session == null) return;
    session.submittingQuestionIds.add(question.id);
    notifyListeners();
    final result = await current.submitPracticeAnswer(
      question: question,
      selected: selected,
      text: text,
    );
    final latest = practiceSession;
    if (latest == null ||
        !latest.questions.any((item) => item.id == question.id)) {
      return;
    }
    latest.submittingQuestionIds.remove(question.id);
    if (result != null) {
      latest.answerResults[question.id] = result;
      if (result.isCorrect == false) {
        wrongQuestions = [
          question,
          ...wrongQuestions.where((item) => item.id != question.id),
        ];
      }
      unawaited(_refreshRemoteRecords());
    }
    notifyListeners();
  }

  void nextPracticeQuestion() {
    final session = practiceSession;
    if (session == null) return;
    if (session.currentIndex < session.questions.length - 1) {
      session.currentIndex += 1;
    }
    notifyListeners();
  }

  void previousPracticeQuestion() {
    final session = practiceSession;
    if (session == null || session.currentIndex == 0) return;
    session.currentIndex -= 1;
    notifyListeners();
  }

  void jumpPracticeQuestion(int index) {
    final session = practiceSession;
    if (session == null || index < 0 || index >= session.questions.length) {
      return;
    }
    session.currentIndex = index;
    notifyListeners();
  }

  void finishPracticeSession() {
    final session = practiceSession;
    if (session == null || session.finished) return;

    final correct = session.correctCount;
    final wrong = session.wrongCount;

    if (session.sectionId != null) {
      _updateSectionProgress(
        session.sectionId!,
        session.answeredCount,
        correct,
        wrong,
      );
    } else if (session.paperId != null) {
      _updatePaperProgress(
        session.paperId!,
        session.answeredCount,
        correct,
        wrong,
      );
    }

    practiceRecords = [
      StudyRecord(
        id: 'practice-${DateTime.now().microsecondsSinceEpoch}',
        title: _displayRecordTitle(session.title),
        mode: session.mode,
        metric:
            '${session.answeredCount}/${session.questions.length}题 · 正确率 ${_rate(correct, session.answeredCount)}%',
        time: '刚刚',
      ),
      ...practiceRecords.take(7),
    ];
    session.finished = true;
    unawaited(_refreshRemoteRecords());
    notifyListeners();
  }

  void startExamFromSection(String sectionId, {bool notify = true}) {
    final section =
        _allSections(examChapters).firstWhere((item) => item.id == sectionId);
    examSession = ExamSession(
      title: section.title,
      mode: '章节考试',
      sectionId: section.id,
      questions: repository.buildExamSectionQuestions(section),
      durationMinutes: 45,
    );
    if (notify) notifyListeners();
    _hydrateExamQuestionsFromRemote(section);
  }

  void startExamFromPaper(String paperId, {bool notify = true}) {
    final paper = examPapers.firstWhere((item) => item.id == paperId);
    examSession = ExamSession(
      title: paper.title,
      mode: '真题考试',
      paperId: paper.id,
      questions: repository.buildExamPaperQuestions(paper),
      durationMinutes: 100,
    );
    if (notify) notifyListeners();
    _hydrateExamQuestionsFromRemote(paper);
  }

  void openExamRecordAnalysis(StudyRecord record) {
    if (record.mode.contains('真题')) {
      final paper = _findExamPaper(record.title);
      startExamFromPaper((paper ?? examPapers.first).id);
      _applyRecordResultToExamSession(record);
      return;
    }
    if (record.mode.contains('组卷') || record.mode.contains('模拟')) {
      startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
      _applyRecordResultToExamSession(record);
      return;
    }
    final section =
        _findExamSection(record.title) ?? _allSections(examChapters).first;
    startExamFromSection(section.id);
    _applyRecordResultToExamSession(record);
  }

  void startAssemblyExam({
    required String scope,
    required int questionCount,
    required int duration,
    List<String> catalogIds = const [],
    bool notify = true,
  }) {
    examSession = ExamSession(
      title: scope == 'all' ? '全部章节组卷' : '自选章节组卷',
      mode: '组卷考试',
      questions: repository.buildAssemblyExamQuestions(count: questionCount),
      durationMinutes: duration,
    );
    if (notify) notifyListeners();
    _hydrateAssemblyExamQuestions(questionCount, catalogIds: catalogIds);
  }

  void answerExam(Set<int> answer) {
    final session = examSession;
    if (session == null || session.submitted) return;
    final question = session.currentQuestion;
    if (answer.isEmpty) {
      session.answers.remove(question.id);
    } else {
      session.answers[question.id] = answer;
      session.textAnswers.remove(question.id);
    }
    notifyListeners();
  }

  void answerExamText(String text) {
    final session = examSession;
    if (session == null || session.submitted) return;
    final question = session.currentQuestion;
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      session.textAnswers.remove(question.id);
    } else {
      session.textAnswers[question.id] = trimmed;
      session.answers.remove(question.id);
    }
    notifyListeners();
  }

  void nextExamQuestion() {
    final session = examSession;
    if (session == null) return;
    if (session.currentIndex < session.questions.length - 1) {
      session.currentIndex += 1;
      notifyListeners();
    }
  }

  void previousExamQuestion() {
    final session = examSession;
    if (session == null || session.currentIndex == 0) return;
    session.currentIndex -= 1;
    notifyListeners();
  }

  void jumpExamQuestion(int index) {
    final session = examSession;
    if (session == null || index < 0 || index >= session.questions.length) {
      return;
    }
    session.currentIndex = index;
    notifyListeners();
  }

  void submitExam() {
    final session = examSession;
    if (session == null || session.submitted) return;
    session.submitted = true;
    if (session.sectionId != null) {
      _updateExamSectionProgress(
        session.sectionId!,
        session.answeredCount,
        session.correctCount,
        session.wrongCount,
      );
    } else if (session.paperId != null) {
      _updateExamPaperProgress(
        session.paperId!,
        session.answeredCount,
        session.correctCount,
        session.wrongCount,
        session.durationMinutes,
      );
    }
    examRecords = [
      StudyRecord(
        id: 'exam-${DateTime.now().microsecondsSinceEpoch}',
        title: _displayRecordTitle(session.title),
        mode: session.mode,
        metric: '${session.score}分 · 正确率 ${session.accuracy}%',
        time: '刚刚',
      ),
      ...examRecords.take(7),
    ];
    final current = repository;
    if (current is RemoteTikuRepository) {
      current.submitExamResult(session);
      unawaited(_refreshRemoteRecords());
    }
    notifyListeners();
  }

  Future<void> _hydratePracticeQuestionsFromRemote(Object source) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final catalogId = switch (source) {
      Section section => section.id,
      Paper paper => paper.id,
      _ => '',
    };
    if (catalogId.isEmpty) return;
    final limit = switch (source) {
      Section section => section.total,
      Paper paper => paper.total,
      _ => 100,
    };
    final questions = await current.fetchCatalogQuestions(
      catalogId,
      limit: limit.clamp(20, 500).toInt(),
    );
    final session = practiceSession;
    if (session == null || questions.isEmpty) return;
    final sourceMatches =
        session.sectionId == catalogId || session.paperId == catalogId;
    if (!sourceMatches) return;
    practiceSession = PracticeSession(
      title: session.title,
      mode: session.mode,
      sectionId: session.sectionId,
      paperId: session.paperId,
      questions: questions,
      currentIndex: session.currentIndex.clamp(0, questions.length - 1).toInt(),
      finished: false,
      answers: session.answers,
      textAnswers: session.textAnswers,
      answerResults: session.answerResults,
    );
    notifyListeners();
  }

  Future<void> _hydrateRandomPracticeQuestions(
    int count, {
    List<String> catalogIds = const [],
  }) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final questions = await current.fetchRandomPracticeQuestions(
      subjectId: selectedSubjectId,
      catalogIds: catalogIds,
      count: count,
    );
    final session = practiceSession;
    if (session == null || session.mode != '随机练习' || questions.isEmpty) return;
    practiceSession = PracticeSession(
      title: session.title,
      mode: session.mode,
      questions: questions,
      currentIndex: 0,
      finished: false,
    );
    notifyListeners();
  }

  Future<void> _hydrateAssemblyExamQuestions(
    int count, {
    List<String> catalogIds = const [],
  }) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final questions = await current.fetchRandomPracticeQuestions(
      subjectId: selectedSubjectId,
      catalogIds: catalogIds,
      count: count,
    );
    final session = examSession;
    if (session == null || session.mode != '组卷考试' || questions.isEmpty) return;
    examSession = ExamSession(
      title: session.title,
      mode: session.mode,
      questions: questions,
      durationMinutes: session.durationMinutes,
      currentIndex: 0,
      submitted: false,
      answers: session.answers,
      textAnswers: session.textAnswers,
    );
    notifyListeners();
  }

  Future<void> _hydrateFavoritePracticeQuestions(int count) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final questions = await current.fetchFavoriteQuestions(
      limit: count,
      subjectId: selectedSubjectId,
    );
    favoriteQuestions = current.loadCachedFavoriteQuestions();
    final session = practiceSession;
    if (session == null || session.mode != '收藏练习') {
      notifyListeners();
      return;
    }
    if (questions.isEmpty) {
      practiceSession = null;
      notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: session.title,
      mode: session.mode,
      questions: questions,
      currentIndex: 0,
      finished: false,
    );
    notifyListeners();
  }

  Future<void> _hydrateWrongPracticeQuestions(int count) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final questions = await current.fetchWrongQuestions(
      limit: count,
      subjectId: selectedSubjectId,
    );
    wrongQuestions = current.loadCachedWrongQuestions();
    final session = practiceSession;
    if (session == null || session.mode != '错题练习') {
      notifyListeners();
      return;
    }
    if (questions.isEmpty) {
      practiceSession = null;
      notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: session.title,
      mode: session.mode,
      questions: questions,
      currentIndex: 0,
      finished: false,
    );
    notifyListeners();
  }

  Future<void> _hydrateExamQuestionsFromRemote(Object source) async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    final catalogId = switch (source) {
      Section section => section.id,
      Paper paper => paper.id,
      _ => '',
    };
    if (catalogId.isEmpty) return;
    final limit = switch (source) {
      Section section => section.total,
      Paper paper => paper.total,
      _ => 100,
    };
    final questions = await current.fetchCatalogQuestions(
      catalogId,
      limit: limit.clamp(20, 500).toInt(),
    );
    final session = examSession;
    if (session == null || questions.isEmpty) return;
    final sourceMatches =
        session.sectionId == catalogId || session.paperId == catalogId;
    if (!sourceMatches) return;
    examSession = ExamSession(
      title: session.title,
      mode: session.mode,
      sectionId: session.sectionId,
      paperId: session.paperId,
      questions: questions,
      durationMinutes: session.durationMinutes,
      currentIndex: session.currentIndex.clamp(0, questions.length - 1).toInt(),
      submitted: session.submitted,
      answers: session.answers,
      textAnswers: session.textAnswers,
    );
    notifyListeners();
  }

  Future<void> _refreshRemoteRecords() async {
    final current = repository;
    if (current is! RemoteTikuRepository) return;
    await current.refreshRecords();
    await current.loadSubject(selectedSubjectId);
    chapters = current.loadPracticeChapters();
    examChapters = current.loadExamChapters();
    practicePapers = current.loadPracticePapers();
    examPapers = current.loadExamPapers();
    practiceRecords = current.loadPracticeRecords();
    examRecords = current.loadExamRecords();
    favoriteQuestions = current.loadCachedFavoriteQuestions();
    wrongQuestions = current.loadCachedWrongQuestions();
    notifyListeners();
  }

  List<bool> examAnsweredStatus() {
    final session = examSession;
    if (session == null) return const [];
    return session.questions
        .map((question) => session.hasAnswered(question.id))
        .toList();
  }

  PracticeStat _combinedStat(List<Chapter> chapterSource, List<Paper> papers) {
    final chapterStat = _chapterStat(chapterSource);
    final paperStat = _paperStat(papers);
    return PracticeStat(
      done: chapterStat.done + paperStat.done,
      total: chapterStat.total + paperStat.total,
      correct: chapterStat.correct + paperStat.correct,
      wrong: chapterStat.wrong + paperStat.wrong,
    );
  }

  PracticeStat _chapterStat(List<Chapter> source) {
    return PracticeStat(
      done: source.fold<int>(0, (sum, chapter) => sum + chapter.done),
      total: source.fold<int>(0, (sum, chapter) => sum + chapter.total),
      correct: source.fold<int>(0, (sum, chapter) => sum + chapter.correct),
      wrong: source.fold<int>(0, (sum, chapter) => sum + chapter.wrong),
    );
  }

  PracticeStat _paperStat(List<Paper> source) {
    return PracticeStat(
      done: source.fold<int>(0, (sum, paper) => sum + paper.done),
      total: source.fold<int>(0, (sum, paper) => sum + paper.total),
      correct: source.fold<int>(0, (sum, paper) => sum + paper.correct),
      wrong: source.fold<int>(0, (sum, paper) => sum + paper.wrong),
    );
  }

  List<Section> _allSections(List<Chapter> source) {
    return source
        .expand((chapter) => _flattenSections(chapter.sections))
        .toList();
  }

  Iterable<Section> _flattenSections(List<Section> sections) sync* {
    for (final section in sections) {
      yield section;
      yield* _flattenSections(section.children);
    }
  }

  Section _updateSectionProgressNode(
    Section section,
    String sectionId,
    int answered,
    int correct,
    int wrong,
  ) {
    if (section.id == sectionId) {
      return section.copyWith(
        done: (section.done + answered).clamp(0, section.total).toInt(),
        correct: section.correct + correct,
        wrong: section.wrong + wrong,
      );
    }
    if (section.children.isEmpty) return section;
    final nextChildren = section.children
        .map((child) => _updateSectionProgressNode(
            child, sectionId, answered, correct, wrong))
        .toList();
    return _rollupSectionChildren(section, nextChildren);
  }

  Section _resetSectionProgressNode(
    Section section,
    Set<String> ids,
    bool inheritedReset,
  ) {
    final shouldReset = inheritedReset || ids.contains(section.id);
    final nextChildren = section.children
        .map((child) => _resetSectionProgressNode(child, ids, shouldReset))
        .toList();
    final next = section.copyWith(
      done: shouldReset ? 0 : section.done,
      correct: shouldReset ? 0 : section.correct,
      wrong: shouldReset ? 0 : section.wrong,
      children: nextChildren,
    );
    return nextChildren.isEmpty
        ? next
        : _rollupSectionChildren(next, nextChildren);
  }

  Section _rollupSectionChildren(Section section, List<Section> children) {
    if (children.isEmpty) return section.copyWith(children: children);
    return section.copyWith(
      done: children.fold<int>(0, (sum, item) => sum + item.done),
      correct: children.fold<int>(0, (sum, item) => sum + item.correct),
      wrong: children.fold<int>(0, (sum, item) => sum + item.wrong),
      children: children,
    );
  }

  void _updateSectionProgress(
    String sectionId,
    int answered,
    int correct,
    int wrong,
  ) {
    chapters = chapters.map((chapter) {
      final nextSections = chapter.sections
          .map((section) => _updateSectionProgressNode(
                section,
                sectionId,
                answered,
                correct,
                wrong,
              ))
          .toList();
      return chapter.copyWith(
        done: nextSections.fold<int>(0, (sum, item) => sum + item.done),
        correct: nextSections.fold<int>(0, (sum, item) => sum + item.correct),
        wrong: nextSections.fold<int>(0, (sum, item) => sum + item.wrong),
        sections: nextSections,
      );
    }).toList();
  }

  void _updatePaperProgress(
    String paperId,
    int answered,
    int correct,
    int wrong,
  ) {
    practicePapers = practicePapers.map((paper) {
      if (paper.id != paperId) return paper;
      return paper.copyWith(
        done: (paper.done + answered).clamp(0, paper.total).toInt(),
        correct: paper.correct + correct,
        wrong: paper.wrong + wrong,
      );
    }).toList();
  }

  void _updateExamSectionProgress(
    String sectionId,
    int answered,
    int correct,
    int wrong,
  ) {
    examChapters = examChapters.map((chapter) {
      final nextSections = chapter.sections
          .map((section) => _updateSectionProgressNode(
                section,
                sectionId,
                answered,
                correct,
                wrong,
              ))
          .toList();
      return chapter.copyWith(
        done: nextSections.fold<int>(0, (sum, item) => sum + item.done),
        correct: nextSections.fold<int>(0, (sum, item) => sum + item.correct),
        wrong: nextSections.fold<int>(0, (sum, item) => sum + item.wrong),
        sections: nextSections,
      );
    }).toList();
  }

  void _updateExamPaperProgress(
    String paperId,
    int answered,
    int correct,
    int wrong,
    int minutes,
  ) {
    examPapers = examPapers.map((paper) {
      if (paper.id != paperId) return paper;
      return paper.copyWith(
        done: (paper.done + answered).clamp(0, paper.total).toInt(),
        correct: paper.correct + correct,
        wrong: paper.wrong + wrong,
        minutes: minutes,
      );
    }).toList();
  }

  int _rate(int correct, int total) =>
      total == 0 ? 0 : (correct * 100 / total).round();

  PracticeAnswerResult _localChoiceResult(
      Question question, Set<int> selected) {
    final correct = sameAnswer(selected, question.answerIndexes);
    return PracticeAnswerResult(
      isCorrect: correct,
      score: correct ? 100 : 0,
      correctAnswerText: question.answerText.isNotEmpty
          ? question.answerText
          : _answerText(question.answerIndexes),
      myAnswerText: _answerText(selected),
      analysisText: question.analysis,
    );
  }

  PracticeAnswerResult _localTextResult(Question question, String text) {
    final expected = _cleanAnswerText(question.answerText);
    final canCompare =
        question.type == QuestionType.fillBlank && expected.isNotEmpty;
    final correct =
        canCompare ? _normalize(text) == _normalize(expected) : null;
    return PracticeAnswerResult(
      isCorrect: correct,
      score: correct == null ? null : (correct ? 100 : 0),
      correctAnswerText: expected,
      myAnswerText: text,
      analysisText: question.analysis.isNotEmpty
          ? question.analysis
          : question.type == QuestionType.material
              ? '材料题答案已记录，后续可在中台补充规则或人工核查。'
              : question.analysis,
      reviewReason: correct == null && question.type == QuestionType.material
          ? '当前阶段材料题不自动判定对错。'
          : null,
    );
  }

  String _answerText(Set<int> answers) {
    if (answers.isEmpty) return '未作答';
    final sorted = answers.toList()..sort();
    return sorted.map((index) => String.fromCharCode(65 + index)).join('、');
  }

  String _normalize(String value) =>
      _cleanAnswerText(value).replaceAll(RegExp(r'\s+'), '').toLowerCase();

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

  String _displayRecordTitle(String title) {
    return title.replaceAll(RegExp(r'^(第一章：|第二章：|第三章：|第四章：)'), '');
  }

  Section? _findPracticeSection(String title) {
    final normalizedTitle = _normalizeCatalogTitle(title);
    for (final section in _allSections(chapters)) {
      final normalizedSection = _normalizeCatalogTitle(section.title);
      if (normalizedSection == normalizedTitle ||
          normalizedSection.contains(normalizedTitle) ||
          normalizedTitle.contains(normalizedSection)) {
        return section;
      }
    }
    return null;
  }

  Paper? _findPracticePaper(String title) {
    final normalizedTitle = _normalizeCatalogTitle(title);
    for (final paper in practicePapers) {
      final normalizedPaper = _normalizeCatalogTitle(paper.title);
      if (normalizedPaper == normalizedTitle ||
          normalizedPaper.contains(normalizedTitle) ||
          normalizedTitle.contains(normalizedPaper)) {
        return paper;
      }
    }
    return null;
  }

  Section? _findExamSection(String title) {
    final normalizedTitle = _normalizeCatalogTitle(title);
    for (final section in _allSections(examChapters)) {
      final normalizedSection = _normalizeCatalogTitle(section.title);
      if (normalizedSection == normalizedTitle ||
          normalizedSection.contains(normalizedTitle) ||
          normalizedTitle.contains(normalizedSection)) {
        return section;
      }
    }
    return null;
  }

  Paper? _findExamPaper(String title) {
    final normalizedTitle = _normalizeCatalogTitle(title);
    for (final paper in examPapers) {
      final normalizedPaper = _normalizeCatalogTitle(paper.title);
      if (normalizedPaper == normalizedTitle ||
          normalizedPaper.contains(normalizedTitle) ||
          normalizedTitle.contains(normalizedPaper)) {
        return paper;
      }
    }
    return null;
  }

  String _normalizeCatalogTitle(String value) {
    return _displayRecordTitle(value)
        .replaceAll(RegExp(r'[\s:：·（）()]'), '')
        .toLowerCase();
  }

  bool _sameRecord(StudyRecord left, StudyRecord right) {
    if (left.id.isNotEmpty && right.id.isNotEmpty) return left.id == right.id;
    return left.title == right.title &&
        left.mode == right.mode &&
        left.metric == right.metric &&
        left.time == right.time;
  }

  void _movePracticeIndexToProgress(String metric) {
    final session = practiceSession;
    if (session == null || session.questions.isEmpty) return;
    final match = RegExp(r'(\d+)/(\d+)题').firstMatch(metric);
    final answered = int.tryParse(match?.group(1) ?? '') ?? 0;
    session.currentIndex =
        answered.clamp(0, session.questions.length - 1).toInt();
    notifyListeners();
  }

  void _applyRecordResultToExamSession(StudyRecord record) {
    final session = examSession;
    if (session == null) return;
    final accuracyMatch = RegExp(r'正确率\s*(\d+)%').firstMatch(record.metric);
    final scoreMatch = RegExp(r'(\d+)分').firstMatch(record.metric);
    final accuracy = int.tryParse(
          accuracyMatch?.group(1) ?? scoreMatch?.group(1) ?? '',
        ) ??
        0;
    final correctTarget = (session.questions.length * accuracy / 100).round();
    session.answers.clear();
    session.textAnswers.clear();
    for (var i = 0; i < session.questions.length; i++) {
      final question = session.questions[i];
      if (question.type == QuestionType.fillBlank ||
          question.type == QuestionType.shortAnswer ||
          question.type == QuestionType.material) {
        final correctText = _cleanAnswerText(question.answerText);
        session.textAnswers[question.id] =
            i < correctTarget && correctText.isNotEmpty ? correctText : '未命中答案';
      } else if (i < correctTarget) {
        session.answers[question.id] = question.answerIndexes;
      } else if (question.options.isNotEmpty) {
        session.answers[question.id] = {
          _firstWrongOptionIndex(question),
        };
      }
    }
    session.submitted = true;
    session.currentIndex = 0;
    notifyListeners();
  }

  int _firstWrongOptionIndex(Question question) {
    for (var i = 0; i < question.options.length; i++) {
      if (!question.answerIndexes.contains(i)) return i;
    }
    return 0;
  }

  void _resetSelectedCatalogs() {
    selectedChapterId =
        chapters.isNotEmpty ? chapters.first.id : selectedChapterId;
    selectedExamChapterId =
        examChapters.isNotEmpty ? examChapters.first.id : selectedExamChapterId;
  }

  List<String> _allPracticeCatalogIds() => [
        ...chapters.map((item) => item.id),
        ..._allSections(chapters).map((item) => item.id),
        ...practicePapers.map((item) => item.id),
      ];

  List<String> _allExamCatalogIds() => [
        ...examChapters.map((item) => item.id),
        ..._allSections(examChapters).map((item) => item.id),
        ...examPapers.map((item) => item.id),
      ];

  void _resetPracticeCatalogs(Set<String> ids) {
    chapters = chapters.map((chapter) {
      final resetWholeChapter = ids.contains(chapter.id);
      final nextSections = chapter.sections
          .map((section) =>
              _resetSectionProgressNode(section, ids, resetWholeChapter))
          .toList();
      return chapter.copyWith(
        done: nextSections.fold<int>(0, (sum, item) => sum + item.done),
        correct: nextSections.fold<int>(0, (sum, item) => sum + item.correct),
        wrong: nextSections.fold<int>(0, (sum, item) => sum + item.wrong),
        sections: nextSections,
      );
    }).toList();
    practicePapers = practicePapers
        .map((paper) => ids.contains(paper.id)
            ? paper.copyWith(done: 0, correct: 0, wrong: 0, minutes: 0)
            : paper)
        .toList();
  }

  void _resetExamCatalogs(Set<String> ids) {
    examChapters = examChapters.map((chapter) {
      final resetWholeChapter = ids.contains(chapter.id);
      final nextSections = chapter.sections
          .map((section) =>
              _resetSectionProgressNode(section, ids, resetWholeChapter))
          .toList();
      return chapter.copyWith(
        done: nextSections.fold<int>(0, (sum, item) => sum + item.done),
        correct: nextSections.fold<int>(0, (sum, item) => sum + item.correct),
        wrong: nextSections.fold<int>(0, (sum, item) => sum + item.wrong),
        sections: nextSections,
      );
    }).toList();
    examPapers = examPapers
        .map((paper) => ids.contains(paper.id)
            ? paper.copyWith(done: 0, correct: 0, wrong: 0, minutes: 0)
            : paper)
        .toList();
  }
}

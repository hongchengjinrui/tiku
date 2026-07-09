import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/app_state_storage.dart';
import '../repositories/remote_tiku_repository.dart';
import '../repositories/tiku_repository.dart';
import 'models.dart';

final _remoteRepository = RemoteTikuRepository();
final appStore = AppStore(repository: _remoteRepository);

// Backward-compatible alias while screens are migrated to provider injection.
final mockStore = appStore;

typedef MockAppStore = AppStore;

class _LocalSubjectState {
  final List<Chapter> chapters;
  final List<Chapter> examChapters;
  final List<Paper> practicePapers;
  final List<Paper> examPapers;
  final List<StudyRecord> practiceRecords;
  final List<StudyRecord> examRecords;
  final List<Question> favoriteQuestions;
  final List<Question> wrongQuestions;
  final Map<String, int> wrongCorrectCounts;
  final String selectedChapterId;
  final String selectedExamChapterId;

  const _LocalSubjectState({
    required this.chapters,
    required this.examChapters,
    required this.practicePapers,
    required this.examPapers,
    required this.practiceRecords,
    required this.examRecords,
    required this.favoriteQuestions,
    required this.wrongQuestions,
    required this.wrongCorrectCounts,
    required this.selectedChapterId,
    required this.selectedExamChapterId,
  });
}

class AppStore extends ChangeNotifier {
  TikuRepository repository;
  AppStateStorage? stateStorage;
  bool remoteReady = false;
  bool _restoringLocalState = false;
  bool _localStateDirty = false;
  Timer? _localPersistTimer;
  final Map<String, _LocalSubjectState> _localSubjectStates = {};

  AppStore({required this.repository, this.stateStorage}) {
    _loadInitialState();
  }

  @override
  void dispose() {
    _localPersistTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_localStateDirty && !_restoringLocalState) {
      _localStateDirty = false;
      _scheduleLocalStatePersist();
    }
    super.notifyListeners();
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
  Map<String, int> wrongCorrectCounts = {};
  List<FeedbackSubmission> feedbackSubmissions = const [];

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
      if (!current.remoteReady) {
        _seedLocalQuestionBuckets();
      }
    } else {
      _seedLocalQuestionBuckets();
    }
  }

  Future<void> attachStateStorage(AppStateStorage storage) async {
    stateStorage = storage;
    await restoreLocalState();
  }

  Future<void> restoreLocalState() async {
    final storage = stateStorage;
    if (storage == null) return;
    final snapshot = await storage.read();
    if (snapshot == null) return;
    _restoringLocalState = true;
    try {
      _applySnapshot(snapshot);
    } finally {
      _restoringLocalState = false;
    }
    super.notifyListeners();
  }

  Future<void> flushLocalState() async {
    _localPersistTimer?.cancel();
    _localPersistTimer = null;
    await _syncPendingFeedbackSubmissions();
    final storage = stateStorage;
    if (storage == null) return;
    await storage.write(_snapshot());
  }

  Future<void> clearLocalState() async {
    _localPersistTimer?.cancel();
    _localPersistTimer = null;
    _localStateDirty = false;
    final storage = stateStorage;
    if (storage == null) return;
    await storage.clear();
  }

  void _applySnapshot(AppStateSnapshot snapshot) {
    _localSubjectStates
      ..clear()
      ..addAll(
        snapshot.localSubjectStates.map(
          (subjectId, state) => MapEntry(
            subjectId,
            _localSubjectStateFromSnapshot(state),
          ),
        ),
      );
    if (snapshot.selectedSubjectId.isNotEmpty) {
      selectedSubjectId = snapshot.selectedSubjectId;
    }
    if (snapshot.selectedChapterId.isNotEmpty) {
      selectedChapterId = snapshot.selectedChapterId;
    }
    if (snapshot.selectedExamChapterId.isNotEmpty) {
      selectedExamChapterId = snapshot.selectedExamChapterId;
    }
    if (snapshot.practiceChapters.isNotEmpty) {
      chapters = snapshot.practiceChapters;
    }
    if (snapshot.examChapters.isNotEmpty) {
      examChapters = snapshot.examChapters;
    }
    if (snapshot.practicePapers.isNotEmpty) {
      practicePapers = snapshot.practicePapers;
    }
    if (snapshot.examPapers.isNotEmpty) {
      examPapers = snapshot.examPapers;
    }
    practiceRecords = snapshot.practiceRecords;
    examRecords = snapshot.examRecords;
    favoriteQuestions = snapshot.favoriteQuestions;
    wrongQuestions = snapshot.wrongQuestions;
    wrongCorrectCounts = Map<String, int>.from(snapshot.wrongCorrectCounts);
    feedbackSubmissions = snapshot.feedbackSubmissions;
    final current = repository;
    if (current is RemoteTikuRepository) {
      current.restoreQuestionCache(snapshot.catalogQuestionCache);
    }
    if (_readyRemoteRepository == null) {
      _saveLocalSubjectState(selectedSubjectId);
    }
  }

  AppStateSnapshot _snapshot() {
    final current = repository;
    final localSubjectStates = <String, _LocalSubjectState>{
      if (_readyRemoteRepository == null) ..._localSubjectStates,
      if (_readyRemoteRepository == null)
        selectedSubjectId: _captureLocalSubjectState(),
    };
    return AppStateSnapshot(
      savedAt: DateTime.now(),
      selectedSubjectId: selectedSubjectId,
      selectedChapterId: selectedChapterId,
      selectedExamChapterId: selectedExamChapterId,
      practiceChapters: chapters,
      examChapters: examChapters,
      practicePapers: practicePapers,
      examPapers: examPapers,
      practiceRecords: practiceRecords,
      examRecords: examRecords,
      favoriteQuestions: favoriteQuestions,
      wrongQuestions: wrongQuestions,
      wrongCorrectCounts: wrongCorrectCounts,
      feedbackSubmissions: feedbackSubmissions,
      catalogQuestionCache: current is RemoteTikuRepository
          ? current.exportQuestionCache()
          : const {},
      localSubjectStates: localSubjectStates.map(
        (subjectId, state) => MapEntry(
          subjectId,
          _localSubjectStateToSnapshot(state),
        ),
      ),
    );
  }

  void _markLocalStateDirty() {
    _localStateDirty = true;
  }

  RemoteTikuRepository? get _readyRemoteRepository {
    final current = repository;
    if (remoteReady && current is RemoteTikuRepository) return current;
    return null;
  }

  void _seedLocalQuestionBuckets() {
    if (wrongQuestions.isEmpty) {
      wrongQuestions = _seedWrongQuestionsForStat(practiceStat);
    }
  }

  void _saveLocalSubjectState(String subjectId) {
    if (subjectId.isEmpty) return;
    _localSubjectStates[subjectId] = _captureLocalSubjectState();
  }

  _LocalSubjectState _captureLocalSubjectState() {
    return _LocalSubjectState(
      chapters: List<Chapter>.of(chapters),
      examChapters: List<Chapter>.of(examChapters),
      practicePapers: List<Paper>.of(practicePapers),
      examPapers: List<Paper>.of(examPapers),
      practiceRecords: List<StudyRecord>.of(practiceRecords),
      examRecords: List<StudyRecord>.of(examRecords),
      favoriteQuestions: List<Question>.of(favoriteQuestions),
      wrongQuestions: List<Question>.of(wrongQuestions),
      wrongCorrectCounts: Map<String, int>.from(wrongCorrectCounts),
      selectedChapterId: selectedChapterId,
      selectedExamChapterId: selectedExamChapterId,
    );
  }

  _LocalSubjectState _localSubjectStateFromSnapshot(
    SubjectStateSnapshot snapshot,
  ) {
    return _LocalSubjectState(
      chapters: snapshot.practiceChapters,
      examChapters: snapshot.examChapters,
      practicePapers: snapshot.practicePapers,
      examPapers: snapshot.examPapers,
      practiceRecords: snapshot.practiceRecords,
      examRecords: snapshot.examRecords,
      favoriteQuestions: snapshot.favoriteQuestions,
      wrongQuestions: snapshot.wrongQuestions,
      wrongCorrectCounts: snapshot.wrongCorrectCounts,
      selectedChapterId: snapshot.selectedChapterId,
      selectedExamChapterId: snapshot.selectedExamChapterId,
    );
  }

  SubjectStateSnapshot _localSubjectStateToSnapshot(
    _LocalSubjectState state,
  ) {
    return SubjectStateSnapshot(
      practiceChapters: state.chapters,
      examChapters: state.examChapters,
      practicePapers: state.practicePapers,
      examPapers: state.examPapers,
      practiceRecords: state.practiceRecords,
      examRecords: state.examRecords,
      favoriteQuestions: state.favoriteQuestions,
      wrongQuestions: state.wrongQuestions,
      wrongCorrectCounts: state.wrongCorrectCounts,
      selectedChapterId: state.selectedChapterId,
      selectedExamChapterId: state.selectedExamChapterId,
    );
  }

  void _applyLocalSubjectState(String subjectId) {
    final state = _localSubjectStates.putIfAbsent(
      subjectId,
      () => _createLocalSubjectState(subjectId),
    );
    chapters = List<Chapter>.of(state.chapters);
    examChapters = List<Chapter>.of(state.examChapters);
    practicePapers = List<Paper>.of(state.practicePapers);
    examPapers = List<Paper>.of(state.examPapers);
    practiceRecords = List<StudyRecord>.of(state.practiceRecords);
    examRecords = List<StudyRecord>.of(state.examRecords);
    favoriteQuestions = List<Question>.of(state.favoriteQuestions);
    wrongQuestions = List<Question>.of(state.wrongQuestions);
    wrongCorrectCounts = Map<String, int>.from(state.wrongCorrectCounts);
    selectedChapterId = _validChapterId(
      state.selectedChapterId,
      chapters,
      fallback: chapters.isNotEmpty ? chapters.first.id : selectedChapterId,
    );
    selectedExamChapterId = _validChapterId(
      state.selectedExamChapterId,
      examChapters,
      fallback: examChapters.isNotEmpty
          ? examChapters.first.id
          : selectedExamChapterId,
    );
  }

  _LocalSubjectState _createLocalSubjectState(String subjectId) {
    final ratio = _localSubjectProgressRatio(subjectId);
    final nextChapters = _varyChapters(
      repository.loadPracticeChapters(),
      ratio,
    );
    final nextExamChapters = _varyChapters(
      repository.loadExamChapters(),
      (ratio + 0.08).clamp(0.2, 1.0),
    );
    final nextPracticePapers = _varyPapers(
      repository.loadPracticePapers(),
      ratio,
    );
    final nextExamPapers = _varyPapers(
      repository.loadExamPapers(),
      (ratio + 0.08).clamp(0.2, 1.0),
    );
    final stat = _combinedStat(nextChapters, nextPracticePapers);
    return _LocalSubjectState(
      chapters: nextChapters,
      examChapters: nextExamChapters,
      practicePapers: nextPracticePapers,
      examPapers: nextExamPapers,
      practiceRecords: _subjectPracticeRecords(ratio),
      examRecords: _subjectExamRecords(ratio),
      favoriteQuestions: const [],
      wrongQuestions: _seedWrongQuestionsForStat(stat),
      wrongCorrectCounts: const {},
      selectedChapterId:
          nextChapters.isNotEmpty ? nextChapters.first.id : selectedChapterId,
      selectedExamChapterId: nextExamChapters.isNotEmpty
          ? nextExamChapters.first.id
          : selectedExamChapterId,
    );
  }

  String _validChapterId(
    String candidate,
    List<Chapter> source, {
    required String fallback,
  }) {
    final ids = {
      ...source.map((chapter) => chapter.id),
      ...source.expand((chapter) => _flattenSections(chapter.sections)).map(
            (section) => section.id,
          ),
    };
    return ids.contains(candidate) ? candidate : fallback;
  }

  double _localSubjectProgressRatio(String subjectId) {
    final index = subjects.indexWhere((subject) => subject.id == subjectId);
    return switch (index) {
      0 => 1.0,
      1 => 0.68,
      2 => 0.84,
      3 => 0.52,
      _ => 0.76,
    };
  }

  List<Chapter> _varyChapters(List<Chapter> source, double ratio) {
    return source.map((chapter) {
      final nextSections = chapter.sections
          .map((section) => _varySection(section, ratio))
          .toList();
      if (nextSections.isNotEmpty) {
        return chapter.copyWith(
          done: nextSections.fold<int>(0, (sum, item) => sum + item.done),
          correct: nextSections.fold<int>(0, (sum, item) => sum + item.correct),
          wrong: nextSections.fold<int>(0, (sum, item) => sum + item.wrong),
          sections: nextSections,
        );
      }
      final done = _scaledProgressValue(chapter.done, chapter.total, ratio);
      return chapter.copyWith(
        done: done,
        correct: _scaledBoundedValue(chapter.correct, done, ratio),
        wrong: _scaledBoundedValue(chapter.wrong, done, ratio),
      );
    }).toList();
  }

  Section _varySection(Section section, double ratio) {
    final nextChildren =
        section.children.map((child) => _varySection(child, ratio)).toList();
    if (nextChildren.isNotEmpty) {
      return _rollupSectionChildren(section, nextChildren);
    }
    final done = _scaledProgressValue(section.done, section.total, ratio);
    return section.copyWith(
      done: done,
      correct: _scaledBoundedValue(section.correct, done, ratio),
      wrong: _scaledBoundedValue(section.wrong, done, ratio),
    );
  }

  List<Paper> _varyPapers(List<Paper> source, double ratio) {
    return source.map((paper) {
      final done = _scaledProgressValue(paper.done, paper.total, ratio);
      return paper.copyWith(
        done: done,
        correct: _scaledBoundedValue(paper.correct, done, ratio),
        wrong: _scaledBoundedValue(paper.wrong, done, ratio),
        minutes: (paper.minutes * ratio).round(),
      );
    }).toList();
  }

  int _scaledProgressValue(int value, int total, double ratio) {
    if (value <= 0 || total <= 0) return 0;
    return (value * ratio).round().clamp(0, total).toInt();
  }

  int _scaledBoundedValue(int value, int max, double ratio) {
    if (value <= 0 || max <= 0) return 0;
    return (value * ratio).round().clamp(0, max).toInt();
  }

  List<Question> _seedWrongQuestionsForStat(PracticeStat stat) {
    if (stat.wrong <= 0) return const [];
    final now = DateTime.now();
    final seeded = repository.buildWrongPracticeQuestions(
      count: stat.wrong.clamp(1, 80).toInt(),
    );
    return List.generate(seeded.length, (index) {
      return seeded[index].copyWith(
        wrongCount: index % 3 + 1,
        lastWrongAt: now.subtract(Duration(days: index % 9)),
      );
    });
  }

  List<StudyRecord> _subjectPracticeRecords(double ratio) {
    final records = repository.loadPracticeRecords();
    if (records.isEmpty || ratio < 0.6) return const [];
    return [
      for (final record in records.take(ratio < 0.8 ? 1 : 2))
        StudyRecord(
          id: record.id,
          title: record.title,
          mode: record.mode,
          metric: record.metric,
          time: record.time,
        ),
    ];
  }

  List<StudyRecord> _subjectExamRecords(double ratio) {
    final records = repository.loadExamRecords();
    if (records.isEmpty || ratio < 0.6) return const [];
    return [
      for (final record in records.take(ratio < 0.8 ? 1 : 2))
        StudyRecord(
          id: record.id,
          title: record.title,
          mode: record.mode,
          metric: record.metric,
          time: record.time,
        ),
    ];
  }

  void _scheduleLocalStatePersist() {
    final storage = stateStorage;
    if (storage == null) return;
    _localPersistTimer?.cancel();
    _localPersistTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(storage.write(_snapshot()));
    });
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
    _markLocalStateDirty();
    notifyListeners();
  }

  Subject get selectedSubject => subjects.firstWhere(
        (subject) => subject.id == selectedSubjectId,
        orElse: () => subjects.first,
      );

  Chapter get selectedChapter => chapters.firstWhere(
        (chapter) => chapter.id == selectedChapterId,
        orElse: () => chapters.isNotEmpty
            ? chapters.first
            : const Chapter(
                id: 'empty_practice_chapter',
                title: '暂无章节',
                done: 0,
                total: 0,
                correct: 0,
                wrong: 0,
                sections: [],
              ),
      );

  Chapter get selectedExamChapter => examChapters.firstWhere(
        (chapter) => chapter.id == selectedExamChapterId,
        orElse: () => examChapters.isNotEmpty
            ? examChapters.first
            : const Chapter(
                id: 'empty_exam_chapter',
                title: '暂无章节',
                done: 0,
                total: 0,
                correct: 0,
                wrong: 0,
                sections: [],
              ),
      );

  PracticeStat get practiceStat => _combinedStat(chapters, practicePapers);

  PracticeStat get examStat => _combinedStat(examChapters, examPapers);

  PracticeStat get practiceChapterStat => _chapterStat(chapters);

  PracticeStat get practicePaperStat => _paperStat(practicePapers);

  PracticeStat get examChapterStat => _chapterStat(examChapters);

  PracticeStat get examPaperStat => _paperStat(examPapers);

  List<String> practiceCatalogIdsForRange(String range) {
    final sections = _allSections(chapters).where(
      (section) => section.children.isEmpty,
    );
    return switch (range) {
      '已练习章节' =>
        sections.where((section) => section.done > 0).map((e) => e.id).toList(),
      '未练习章节' => sections
          .where((section) => section.done == 0)
          .map((e) => e.id)
          .toList(),
      _ => const [],
    };
  }

  int get wrongPracticeCount => wrongQuestions.length;

  int get favoritePracticeCount => favoriteQuestions.length;

  Future<void> selectSubject(String subjectId) async {
    if (subjectId == selectedSubjectId) return;
    final previousSubjectId = selectedSubjectId;
    final current = _readyRemoteRepository;
    if (current == null) {
      _saveLocalSubjectState(previousSubjectId);
      selectedSubjectId = subjectId;
      practiceSession = null;
      examSession = null;
      _applyLocalSubjectState(subjectId);
      _markLocalStateDirty();
      notifyListeners();
      return;
    }

    selectedSubjectId = subjectId;
    practiceSession = null;
    examSession = null;
    _markLocalStateDirty();
    notifyListeners();
    final loaded = await current.loadSubject(subjectId);
    if (!loaded || selectedSubjectId != subjectId) return;
    _loadInitialState();
    selectedSubjectId = subjectId;
    _resetSelectedCatalogs();
    _markLocalStateDirty();
    notifyListeners();
  }

  void selectChapter(String chapterId) {
    selectedChapterId = chapterId;
    _markLocalStateDirty();
    notifyListeners();
  }

  void selectExamChapter(String chapterId) {
    selectedExamChapterId = chapterId;
    _markLocalStateDirty();
    notifyListeners();
  }

  void startPracticeFromSection(String sectionId, {bool notify = true}) {
    final sections = _allSections(chapters).toList();
    final section = _firstWhereOrNull(sections, (item) => item.id == sectionId);
    if (section == null) {
      startRandomPractice(notify: notify);
      return;
    }
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
    final paper =
        _firstWhereOrNull(practicePapers, (item) => item.id == paperId);
    if (paper == null) {
      startRandomPractice(notify: notify);
      return;
    }
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
      if (paper == null && practicePapers.isEmpty) {
        startRandomPractice();
      } else {
        startPracticeFromPaper((paper ?? practicePapers.first).id);
      }
      if (!restart) _movePracticeIndexToProgress(record.metric);
      return;
    }
    final sections = _allSections(chapters).toList();
    final section = _findPracticeSection(record.title) ??
        (sections.isEmpty ? null : sections.first);
    if (section == null) {
      startRandomPractice();
    } else {
      startPracticeFromSection(section.id);
    }
    if (!restart) _movePracticeIndexToProgress(record.metric);
  }

  void startRandomPractice({
    int count = 10,
    List<String> catalogIds = const [],
    String? title,
    bool notify = true,
  }) {
    practiceSession = PracticeSession(
      title: title ?? (catalogIds.isEmpty ? '随机练习' : '自选章节随机练习'),
      mode: '随机练习',
      questions: repository.buildRandomPracticeQuestions(
        count: count,
        catalogIds: catalogIds,
      ),
    );
    if (notify) notifyListeners();
    _hydrateRandomPracticeQuestions(count, catalogIds: catalogIds);
  }

  void startFavoritePractice({
    int count = 6,
    List<Question> questions = const [],
    bool notify = true,
  }) {
    final current = _readyRemoteRepository;
    final sourceQuestions = questions.isNotEmpty
        ? questions
        : favoriteQuestions.take(count).toList();
    if (sourceQuestions.isEmpty) {
      practiceSession = null;
      if (notify) notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: '收藏练习',
      mode: '收藏练习',
      questions: sourceQuestions,
    );
    if (notify) notifyListeners();
    if (questions.isEmpty && current != null) {
      _hydrateFavoritePracticeQuestions(count);
    }
  }

  void startWrongPractice({
    int count = 8,
    List<Question> questions = const [],
    int removeAfterCorrect = 2,
    bool notify = true,
  }) {
    final current = _readyRemoteRepository;
    final sourceQuestions =
        questions.isNotEmpty ? questions : wrongQuestions.take(count).toList();
    if (sourceQuestions.isEmpty) {
      practiceSession = null;
      if (notify) notifyListeners();
      return;
    }
    practiceSession = PracticeSession(
      title: '错题练习',
      mode: '错题练习',
      questions: sourceQuestions,
      wrongRemovalThreshold: removeAfterCorrect.clamp(1, 99).toInt(),
    );
    if (notify) notifyListeners();
    if (questions.isEmpty && current != null) {
      _hydrateWrongPracticeQuestions(count);
    }
  }

  void answerPractice(Set<int> answer, {bool reveal = true}) {
    final session = practiceSession;
    if (session == null) return;
    final question = session.currentQuestion;
    if (answer.isEmpty) {
      session.answers.remove(question.id);
      session.answerResults.remove(question.id);
    } else {
      session.answers[question.id] = answer;
      session.textAnswers.remove(question.id);
      if (reveal) {
        final result = _localChoiceResult(question, answer);
        session.answerResults[question.id] = result;
        _applyWrongPracticeRemoval(question, result.isCorrect);
      } else {
        session.answerResults.remove(question.id);
      }
    }
    final current = _readyRemoteRepository;
    if (current != null && answer.isNotEmpty && reveal) {
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
    final result = _localTextResult(question, trimmed);
    session.answerResults[question.id] = result;
    _applyWrongPracticeRemoval(question, result.isCorrect);
    final current = _readyRemoteRepository;
    if (current != null) {
      unawaited(_submitPracticeAnswer(question: question, text: trimmed));
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Question question) async {
    final current = _readyRemoteRepository;
    if (current != null) {
      final favorited = await current.toggleFavorite(question);
      favoriteQuestions = current.loadCachedFavoriteQuestions();
      if (!favorited) {
        _dropFavoriteQuestionsFromActiveSession({question.id});
      }
      _markLocalStateDirty();
      notifyListeners();
      return;
    }
    final exists = favoriteQuestions.any((item) => item.id == question.id);
    if (exists) {
      _dropFavoriteQuestions({question.id});
    } else {
      favoriteQuestions = [question, ...favoriteQuestions];
    }
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<bool> removeWrongQuestion(Question question) async {
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.removeWrongQuestion(question.id);
      if (!ok) return false;
    }
    _dropWrongQuestions({question.id});
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> clearWrongQuestions(
      {List<Question> questions = const []}) async {
    final ids = questions.isEmpty
        ? wrongQuestions.map((question) => question.id).toSet()
        : questions.map((question) => question.id).toSet();
    if (ids.isEmpty) return true;

    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.clearWrongQuestions(
        questionIds: ids.toList(),
        subjectId: selectedSubjectId,
      );
      if (!ok) return false;
    }
    _dropWrongQuestions(ids);
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> resetPracticeProgress(
      {List<String> catalogIds = const []}) async {
    final ids = catalogIds.isEmpty ? _allPracticeCatalogIds() : catalogIds;
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.resetProgress(mode: 'practice', catalogIds: ids);
      if (!ok) return false;
      _loadInitialState();
      selectedChapterId =
          chapters.isNotEmpty ? chapters.first.id : selectedChapterId;
      _markLocalStateDirty();
      notifyListeners();
      return true;
    }
    _resetPracticeCatalogs(ids.toSet());
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> resetExamProgress({List<String> catalogIds = const []}) async {
    final ids = catalogIds.isEmpty ? _allExamCatalogIds() : catalogIds;
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.resetProgress(mode: 'exam', catalogIds: ids);
      if (!ok) return false;
      _loadInitialState();
      selectedExamChapterId = examChapters.isNotEmpty
          ? examChapters.first.id
          : selectedExamChapterId;
      _markLocalStateDirty();
      notifyListeners();
      return true;
    }
    _resetExamCatalogs(ids.toSet());
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> deletePracticeRecords() async {
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.deleteRecords('practice');
      if (!ok) return false;
    }
    practiceRecords = const [];
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> deletePracticeRecord(StudyRecord record) async {
    final current = _readyRemoteRepository;
    if (current != null && record.id.isNotEmpty) {
      final ok = await current.deleteRecord('practice', record.id);
      if (!ok) return false;
    }
    practiceRecords =
        practiceRecords.where((item) => !_sameRecord(item, record)).toList();
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> deleteExamRecords() async {
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.deleteRecords('exam');
      if (!ok) return false;
    }
    examRecords = const [];
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> deleteExamRecord(StudyRecord record) async {
    final current = _readyRemoteRepository;
    if (current != null && record.id.isNotEmpty) {
      final ok = await current.deleteRecord('exam', record.id);
      if (!ok) return false;
    }
    examRecords =
        examRecords.where((item) => !_sameRecord(item, record)).toList();
    _markLocalStateDirty();
    notifyListeners();
    return true;
  }

  Future<bool> submitQuestionFeedback(
    Question question, {
    required String content,
    String type = 'question_error',
  }) async {
    final payload = {
      'source': 'question_feedback',
      'questionId': question.id,
      'stem': question.stem,
      'questionType': question.type.label,
    };
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.submitQuestionFeedback(
        question: question,
        content: content,
        type: type,
      );
      if (ok) return true;
    }
    _enqueueFeedbackSubmission(
      content: content,
      type: type,
      payload: payload,
    );
    return true;
  }

  Future<bool> submitFeedback({
    required String content,
    String type = 'general_feedback',
    Map<String, Object?> payload = const {},
  }) async {
    final current = _readyRemoteRepository;
    if (current != null) {
      final ok = await current.submitGeneralFeedback(
        content: content,
        type: type,
        payload: payload,
      );
      if (ok) return true;
    }
    _enqueueFeedbackSubmission(
      content: content,
      type: type,
      payload: payload,
    );
    return true;
  }

  void _enqueueFeedbackSubmission({
    required String content,
    required String type,
    required Map<String, Object?> payload,
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    feedbackSubmissions = [
      FeedbackSubmission(
        id: 'feedback-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        content: trimmed,
        payload: payload,
        createdAt: DateTime.now(),
      ),
      ...feedbackSubmissions,
    ];
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _syncPendingFeedbackSubmissions() async {
    final current = _readyRemoteRepository;
    if (current == null || feedbackSubmissions.isEmpty) return;
    final remaining = <FeedbackSubmission>[];
    for (final feedback in feedbackSubmissions.reversed) {
      final ok = await current.submitGeneralFeedback(
        content: feedback.content,
        type: feedback.type,
        payload: feedback.payload,
      );
      if (!ok) remaining.insert(0, feedback);
    }
    if (remaining.length == feedbackSubmissions.length) return;
    feedbackSubmissions = remaining;
    _markLocalStateDirty();
    notifyListeners();
  }

  bool isQuestionFavorite(String questionId) =>
      favoriteQuestions.any((item) => item.id == questionId);

  void _dropFavoriteQuestions(Set<String> questionIds) {
    favoriteQuestions = favoriteQuestions
        .where((question) => !questionIds.contains(question.id))
        .toList();
    _dropFavoriteQuestionsFromActiveSession(questionIds);
  }

  void _dropFavoriteQuestionsFromActiveSession(Set<String> questionIds) {
    final session = practiceSession;
    if (session == null || session.mode != '收藏练习') return;
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
  }

  void _dropWrongQuestions(Set<String> questionIds) {
    _dropWrongQuestionsFromState(questionIds);
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
  }

  void _dropWrongQuestionsFromState(Set<String> questionIds) {
    wrongQuestions = wrongQuestions
        .where((question) => !questionIds.contains(question.id))
        .toList();
    wrongCorrectCounts = Map<String, int>.from(wrongCorrectCounts)
      ..removeWhere((id, _) => questionIds.contains(id));
  }

  void _applyWrongPracticeRemoval(Question question, bool? isCorrect) {
    final session = practiceSession;
    if (session == null || session.mode != '错题练习' || isCorrect == null) {
      return;
    }
    if (!isCorrect) {
      _setWrongCorrectCount(question.id, 0);
      _markLocalStateDirty();
      return;
    }

    final nextCount = (wrongCorrectCounts[question.id] ?? 0) + 1;
    final threshold =
        session.wrongRemovalThreshold <= 0 ? 2 : session.wrongRemovalThreshold;
    if (nextCount >= threshold) {
      _dropWrongQuestionsFromState({question.id});
    } else {
      _setWrongCorrectCount(question.id, nextCount);
    }
    _markLocalStateDirty();
  }

  void _setWrongCorrectCount(String questionId, int count) {
    wrongCorrectCounts = {
      ...wrongCorrectCounts,
      questionId: count,
    };
  }

  Future<void> _submitPracticeAnswer({
    required Question question,
    Set<int> selected = const {},
    String? text,
  }) async {
    final current = _readyRemoteRepository;
    final session = practiceSession;
    if (current == null || session == null) return;
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
      final previous = latest.answerResults[question.id];
      latest.answerResults[question.id] = result;
      if (previous?.isCorrect == null) {
        _applyWrongPracticeRemoval(question, result.isCorrect);
      }
      if (result.isCorrect == false) {
        wrongQuestions = [
          question,
          ...wrongQuestions.where((item) => item.id != question.id),
        ];
        _setWrongCorrectCount(question.id, 0);
        _markLocalStateDirty();
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
    _markLocalStateDirty();
    unawaited(_refreshRemoteRecords());
    notifyListeners();
  }

  void startExamFromSection(String sectionId, {bool notify = true}) {
    final sections = _allSections(examChapters).toList();
    final section = _firstWhereOrNull(sections, (item) => item.id == sectionId);
    if (section == null) {
      startAssemblyExam(
        scope: 'all',
        questionCount: 20,
        duration: 100,
        notify: notify,
      );
      return;
    }
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
    final paper = _firstWhereOrNull(examPapers, (item) => item.id == paperId);
    if (paper == null) {
      startAssemblyExam(
        scope: 'all',
        questionCount: 20,
        duration: 100,
        notify: notify,
      );
      return;
    }
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
      if (paper == null && examPapers.isEmpty) {
        startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
      } else {
        startExamFromPaper((paper ?? examPapers.first).id);
      }
      _applyRecordResultToExamSession(record);
      return;
    }
    if (record.mode.contains('组卷') || record.mode.contains('模拟')) {
      startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
      _applyRecordResultToExamSession(record);
      return;
    }
    final sections = _allSections(examChapters).toList();
    final section = _findExamSection(record.title) ??
        (sections.isEmpty ? null : sections.first);
    if (section == null) {
      startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
    } else {
      startExamFromSection(section.id);
    }
    _applyRecordResultToExamSession(record);
  }

  void startExamFromRecord(StudyRecord record, {required bool restart}) {
    if (record.mode.contains('真题')) {
      final paper = _findExamPaper(record.title);
      if (paper == null && examPapers.isEmpty) {
        startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
      } else {
        startExamFromPaper((paper ?? examPapers.first).id);
      }
      if (!restart) _moveExamIndexToProgress(record.metric);
      return;
    }
    if (record.mode.contains('组卷') || record.mode.contains('模拟')) {
      startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
      if (!restart) _moveExamIndexToProgress(record.metric);
      return;
    }
    final sections = _allSections(examChapters).toList();
    final section = _findExamSection(record.title) ??
        (sections.isEmpty ? null : sections.first);
    if (section == null) {
      startAssemblyExam(scope: 'all', questionCount: 20, duration: 100);
    } else {
      startExamFromSection(section.id);
    }
    if (!restart) _moveExamIndexToProgress(record.metric);
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
      questions: repository.buildAssemblyExamQuestions(
        count: questionCount,
        catalogIds: catalogIds,
      ),
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

  void tickExamSecond({int seconds = 1}) {
    final session = examSession;
    if (session == null || session.submitted || seconds <= 0) return;
    session.remainingSeconds = (session.remainingSeconds - seconds)
        .clamp(0, session.durationMinutes * 60)
        .toInt();
    if (session.remainingSeconds == 0) {
      submitExam();
      return;
    }
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
    final current = _readyRemoteRepository;
    if (current != null) {
      current.submitExamResult(session);
      unawaited(_refreshRemoteRecords());
    }
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydratePracticeQuestionsFromRemote(Object source) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydrateRandomPracticeQuestions(
    int count, {
    List<String> catalogIds = const [],
  }) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydrateAssemblyExamQuestions(
    int count, {
    List<String> catalogIds = const [],
  }) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
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
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydrateFavoritePracticeQuestions(int count) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
    final questions = await current.fetchFavoriteQuestions(
      limit: count,
      subjectId: selectedSubjectId,
    );
    favoriteQuestions = current.loadCachedFavoriteQuestions();
    _markLocalStateDirty();
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydrateWrongPracticeQuestions(int count) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
    final questions = await current.fetchWrongQuestions(
      limit: count,
      subjectId: selectedSubjectId,
    );
    wrongQuestions = current.loadCachedWrongQuestions();
    _markLocalStateDirty();
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
      wrongRemovalThreshold: session.wrongRemovalThreshold,
    );
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _hydrateExamQuestionsFromRemote(Object source) async {
    final current = _readyRemoteRepository;
    if (current == null) return;
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
    _markLocalStateDirty();
    notifyListeners();
  }

  Future<void> _refreshRemoteRecords() async {
    final current = _readyRemoteRepository;
    if (current == null) return;
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
    _markLocalStateDirty();
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
    final evaluation = evaluateTextAnswer(question, text);
    return PracticeAnswerResult(
      isCorrect: evaluation.isCorrect,
      score: evaluation.score,
      correctAnswerText: evaluation.correctAnswerText,
      myAnswerText: text,
      analysisText: question.analysis.isNotEmpty
          ? question.analysis
          : question.type == QuestionType.material
              ? '材料题答案已记录，后续可在中台补充规则或人工核查。'
              : question.analysis,
      scoreText: evaluation.scoreText,
      matchedPoints: evaluation.matchedPoints,
      reviewReason: evaluation.reviewReason,
    );
  }

  String _answerText(Set<int> answers) {
    if (answers.isEmpty) return '未作答';
    final sorted = answers.toList()..sort();
    return sorted.map((index) => String.fromCharCode(65 + index)).join('、');
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

  void _moveExamIndexToProgress(String metric) {
    final session = examSession;
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

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

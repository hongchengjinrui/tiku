import 'package:flutter/foundation.dart';

import '../repositories/mock_tiku_repository.dart';
import '../repositories/tiku_repository.dart';
import 'models.dart';

final appStore = AppStore(repository: MockTikuRepository());

// Backward-compatible alias while screens are migrated to provider injection.
final mockStore = appStore;

typedef MockAppStore = AppStore;

class AppStore extends ChangeNotifier {
  final TikuRepository repository;

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
  }

  Subject get selectedSubject =>
      subjects.firstWhere((subject) => subject.id == selectedSubjectId);

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

  int get wrongPracticeCount => practiceStat.wrong;

  int get favoritePracticeCount => 16;

  void selectSubject(String subjectId) {
    selectedSubjectId = subjectId;
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
    final section = chapters
        .expand((chapter) => chapter.sections)
        .firstWhere((item) => item.id == sectionId);
    practiceSession = PracticeSession(
      title: section.title,
      mode: '章节练习',
      sectionId: section.id,
      questions: repository.buildPracticeSectionQuestions(section),
    );
    if (notify) notifyListeners();
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
  }

  void startRandomPractice({int count = 10, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '随机练习',
      mode: '随机练习',
      questions: repository.buildRandomPracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
  }

  void startFavoritePractice({int count = 6, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '收藏练习',
      mode: '收藏练习',
      questions: repository.buildFavoritePracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
  }

  void startWrongPractice({int count = 8, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '错题练习',
      mode: '错题练习',
      questions: repository.buildWrongPracticeQuestions(count: count),
    );
    if (notify) notifyListeners();
  }

  void answerPractice(Set<int> answer) {
    final session = practiceSession;
    if (session == null) return;
    if (answer.isEmpty) {
      session.answers.remove(session.currentQuestion.id);
    } else {
      session.answers[session.currentQuestion.id] = answer;
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
        title: _displayRecordTitle(session.title),
        mode: session.mode,
        metric:
            '${session.answeredCount}/${session.questions.length}题 · 正确率 ${_rate(correct, session.answeredCount)}%',
        time: '刚刚',
      ),
      ...practiceRecords.take(7),
    ];
    session.finished = true;
    notifyListeners();
  }

  void startExamFromSection(String sectionId, {bool notify = true}) {
    final section = examChapters
        .expand((chapter) => chapter.sections)
        .firstWhere((item) => item.id == sectionId);
    examSession = ExamSession(
      title: section.title,
      mode: '章节考试',
      sectionId: section.id,
      questions: repository.buildExamSectionQuestions(section),
      durationMinutes: 45,
    );
    if (notify) notifyListeners();
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
  }

  void startAssemblyExam({
    required String scope,
    required int questionCount,
    required int duration,
    bool notify = true,
  }) {
    examSession = ExamSession(
      title: scope == 'all' ? '全部章节组卷' : '自选章节组卷',
      mode: '组卷考试',
      questions: repository.buildAssemblyExamQuestions(count: questionCount),
      durationMinutes: duration,
    );
    if (notify) notifyListeners();
  }

  void answerExam(Set<int> answer) {
    final session = examSession;
    if (session == null || session.submitted) return;
    if (answer.isEmpty) {
      session.answers.remove(session.currentQuestion.id);
    } else {
      session.answers[session.currentQuestion.id] = answer;
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
        title: _displayRecordTitle(session.title),
        mode: session.mode,
        metric: '${session.score}分 · 正确率 ${session.accuracy}%',
        time: '刚刚',
      ),
      ...examRecords.take(7),
    ];
    notifyListeners();
  }

  List<bool> examAnsweredStatus() {
    final session = examSession;
    if (session == null) return const [];
    return session.questions
        .map((question) => session.answers.containsKey(question.id))
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

  void _updateSectionProgress(
    String sectionId,
    int answered,
    int correct,
    int wrong,
  ) {
    chapters = chapters.map((chapter) {
      final nextSections = chapter.sections.map((section) {
        if (section.id != sectionId) return section;
        return section.copyWith(
          done: (section.done + answered).clamp(0, section.total).toInt(),
          correct: section.correct + correct,
          wrong: section.wrong + wrong,
        );
      }).toList();
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
      final nextSections = chapter.sections.map((section) {
        if (section.id != sectionId) return section;
        return section.copyWith(
          done: (section.done + answered).clamp(0, section.total).toInt(),
          correct: section.correct + correct,
          wrong: section.wrong + wrong,
        );
      }).toList();
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

  String _displayRecordTitle(String title) {
    return title.replaceAll(RegExp(r'^(第一章：|第二章：|第三章：|第四章：)'), '');
  }
}

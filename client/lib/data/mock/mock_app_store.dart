import 'package:flutter/foundation.dart';

import 'models.dart';

final mockStore = MockAppStore();

class MockAppStore extends ChangeNotifier {
  final subjects = const [
    Subject(id: 'primary_teacher', name: '小学教师', isDefault: true),
    Subject(id: 'kindergarten_teacher', name: '幼儿教师'),
    Subject(id: 'middle_teacher', name: '中学教师'),
    Subject(id: 'teacher_recruit', name: '教师招聘'),
  ];

  String selectedSubjectId = 'primary_teacher';
  String selectedChapterId = 'chapter_1';
  String selectedExamChapterId = 'chapter_1';

  late List<Chapter> chapters = _initialChapters();
  late List<Chapter> examChapters = _initialExamChapters();
  late List<Paper> practicePapers = _initialPracticePapers();
  late List<Paper> examPapers = _initialExamPapers();
  late List<StudyRecord> practiceRecords = _initialPracticeRecords();
  late List<StudyRecord> examRecords = _initialExamRecords();

  PracticeSession? practiceSession;
  ExamSession? examSession;

  Subject get selectedSubject =>
      subjects.firstWhere((subject) => subject.id == selectedSubjectId);

  Chapter get selectedChapter =>
      chapters.firstWhere((chapter) => chapter.id == selectedChapterId);

  Chapter get selectedExamChapter =>
      examChapters.firstWhere((chapter) => chapter.id == selectedExamChapterId);

  PracticeStat get practiceStat {
    return _combinedStat(chapters, practicePapers);
  }

  PracticeStat get examStat {
    return _combinedStat(examChapters, examPapers);
  }

  PracticeStat get practiceChapterStat => _chapterStat(chapters);
  PracticeStat get practicePaperStat => _paperStat(practicePapers);
  PracticeStat get examChapterStat => _chapterStat(examChapters);
  PracticeStat get examPaperStat => _paperStat(examPapers);

  int get wrongPracticeCount => practiceStat.wrong;
  int get favoritePracticeCount => 16;

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
        .firstWhere((s) => s.id == sectionId);
    practiceSession = PracticeSession(
      title: section.title,
      mode: '章节练习',
      sectionId: section.id,
      questions: _sampleQuestions(prefix: section.id, count: 8),
    );
    if (notify) notifyListeners();
  }

  void startPracticeFromPaper(String paperId, {bool notify = true}) {
    final paper = practicePapers.firstWhere((item) => item.id == paperId);
    practiceSession = PracticeSession(
      title: paper.title,
      mode: '真题练习',
      paperId: paper.id,
      questions: _sampleQuestions(prefix: paper.id, count: 10),
    );
    if (notify) notifyListeners();
  }

  void startRandomPractice({int count = 10, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '随机练习',
      mode: '随机练习',
      questions:
          _sampleQuestions(prefix: 'random', count: count.clamp(5, 50).toInt()),
    );
    if (notify) notifyListeners();
  }

  void startFavoritePractice({int count = 6, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '收藏练习',
      mode: '收藏练习',
      questions: _sampleQuestions(
          prefix: 'favorite', count: count.clamp(1, 20).toInt()),
    );
    if (notify) notifyListeners();
  }

  void startWrongPractice({int count = 8, bool notify = true}) {
    practiceSession = PracticeSession(
      title: '错题练习',
      mode: '错题练习',
      questions:
          _sampleQuestions(prefix: 'wrong', count: count.clamp(1, 80).toInt()),
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
          session.sectionId!, session.answeredCount, correct, wrong);
    } else if (session.paperId != null) {
      _updatePaperProgress(
          session.paperId!, session.answeredCount, correct, wrong);
    }

    practiceRecords = [
      StudyRecord(
        title: session.title.replaceAll(RegExp(r'^(第一章：|第二章：|第三章：|第四章：)'), ''),
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
        .firstWhere((s) => s.id == sectionId);
    examSession = ExamSession(
      title: section.title,
      mode: '章节考试',
      sectionId: section.id,
      questions: _sampleQuestions(prefix: 'exam_$sectionId', count: 12),
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
      questions: _sampleQuestions(prefix: 'exam_$paperId', count: 12),
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
      questions: _sampleQuestions(
        prefix: 'assembly',
        count: questionCount.clamp(8, 20).toInt(),
      ),
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
        title: session.title.replaceAll(RegExp(r'^(第一章：|第二章：|第三章：|第四章：)'), ''),
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
        .map((q) => session.answers.containsKey(q.id))
        .toList();
  }

  void _updateSectionProgress(
      String sectionId, int answered, int correct, int wrong) {
    chapters = chapters.map((chapter) {
      final nextSections = chapter.sections.map((section) {
        if (section.id != sectionId) return section;
        return section.copyWith(
          done: (section.done + answered).clamp(0, section.total).toInt(),
          correct: section.correct + correct,
          wrong: section.wrong + wrong,
        );
      }).toList();
      final chapterDone =
          nextSections.fold<int>(0, (sum, item) => sum + item.done);
      final chapterCorrect =
          nextSections.fold<int>(0, (sum, item) => sum + item.correct);
      final chapterWrong =
          nextSections.fold<int>(0, (sum, item) => sum + item.wrong);
      return chapter.copyWith(
        done: chapterDone,
        correct: chapterCorrect,
        wrong: chapterWrong,
        sections: nextSections,
      );
    }).toList();
  }

  void _updatePaperProgress(
      String paperId, int answered, int correct, int wrong) {
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
      final chapterDone =
          nextSections.fold<int>(0, (sum, item) => sum + item.done);
      final chapterCorrect =
          nextSections.fold<int>(0, (sum, item) => sum + item.correct);
      final chapterWrong =
          nextSections.fold<int>(0, (sum, item) => sum + item.wrong);
      return chapter.copyWith(
        done: chapterDone,
        correct: chapterCorrect,
        wrong: chapterWrong,
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

  List<Chapter> _initialChapters() {
    return const [
      Chapter(
        id: 'chapter_1',
        title: '第一章：教育基础',
        done: 42,
        total: 84,
        correct: 34,
        wrong: 5,
        sections: [
          Section(
            id: 'section_1_1',
            chapterId: 'chapter_1',
            title: '第一节：教育理论',
            done: 18,
            total: 28,
            correct: 15,
            wrong: 2,
          ),
          Section(
            id: 'section_1_2',
            chapterId: 'chapter_1',
            title: '第二节：教育心理',
            done: 12,
            total: 32,
            correct: 9,
            wrong: 3,
          ),
          Section(
            id: 'section_1_3',
            chapterId: 'chapter_1',
            title: '第三节：教学设计',
            done: 12,
            total: 24,
            correct: 10,
            wrong: 0,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_2',
        title: '第二章：班级管理',
        done: 24,
        total: 72,
        correct: 18,
        wrong: 4,
        sections: [
          Section(
            id: 'section_2_1',
            chapterId: 'chapter_2',
            title: '第一节：班级组织',
            done: 10,
            total: 26,
            correct: 8,
            wrong: 1,
          ),
          Section(
            id: 'section_2_2',
            chapterId: 'chapter_2',
            title: '第二节：班主任工作',
            done: 14,
            total: 46,
            correct: 10,
            wrong: 3,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_3',
        title: '第三章：学生发展',
        done: 60,
        total: 96,
        correct: 50,
        wrong: 6,
        sections: [
          Section(
            id: 'section_3_1',
            chapterId: 'chapter_3',
            title: '第一节：身心发展规律',
            done: 30,
            total: 48,
            correct: 26,
            wrong: 3,
          ),
          Section(
            id: 'section_3_2',
            chapterId: 'chapter_3',
            title: '第二节：学习心理',
            done: 30,
            total: 48,
            correct: 24,
            wrong: 3,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_4',
        title: '第四章：打分考评',
        done: 80,
        total: 80,
        correct: 72,
        wrong: 3,
        sections: [
          Section(
            id: 'section_4_1',
            chapterId: 'chapter_4',
            title: '第一节：评价原则',
            done: 40,
            total: 40,
            correct: 36,
            wrong: 2,
          ),
          Section(
            id: 'section_4_2',
            chapterId: 'chapter_4',
            title: '第二节：评分方法',
            done: 40,
            total: 40,
            correct: 36,
            wrong: 1,
          ),
        ],
      ),
    ];
  }

  List<Chapter> _initialExamChapters() {
    return const [
      Chapter(
        id: 'chapter_1',
        title: '第一章：教育基础',
        done: 42,
        total: 84,
        correct: 32,
        wrong: 10,
        sections: [
          Section(
            id: 'exam_section_1_1',
            chapterId: 'chapter_1',
            title: '第一节：教育理论',
            done: 18,
            total: 28,
            correct: 14,
            wrong: 4,
          ),
          Section(
            id: 'exam_section_1_2',
            chapterId: 'chapter_1',
            title: '第二节：教育心理',
            done: 12,
            total: 32,
            correct: 9,
            wrong: 3,
          ),
          Section(
            id: 'exam_section_1_3',
            chapterId: 'chapter_1',
            title: '第三节：教学设计',
            done: 12,
            total: 24,
            correct: 9,
            wrong: 3,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_2',
        title: '第二章：班级管理',
        done: 24,
        total: 72,
        correct: 17,
        wrong: 7,
        sections: [
          Section(
            id: 'exam_section_2_1',
            chapterId: 'chapter_2',
            title: '第一节：班级组织',
            done: 10,
            total: 26,
            correct: 7,
            wrong: 3,
          ),
          Section(
            id: 'exam_section_2_2',
            chapterId: 'chapter_2',
            title: '第二节：班主任工作',
            done: 14,
            total: 46,
            correct: 10,
            wrong: 4,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_3',
        title: '第三章：学生发展',
        done: 60,
        total: 96,
        correct: 45,
        wrong: 15,
        sections: [
          Section(
            id: 'exam_section_3_1',
            chapterId: 'chapter_3',
            title: '第一节：身心发展规律',
            done: 30,
            total: 48,
            correct: 24,
            wrong: 6,
          ),
          Section(
            id: 'exam_section_3_2',
            chapterId: 'chapter_3',
            title: '第二节：学习心理',
            done: 30,
            total: 48,
            correct: 21,
            wrong: 9,
          ),
        ],
      ),
      Chapter(
        id: 'chapter_4',
        title: '第四章：打分考评',
        done: 52,
        total: 80,
        correct: 38,
        wrong: 14,
        sections: [
          Section(
            id: 'exam_section_4_1',
            chapterId: 'chapter_4',
            title: '第一节：评价原则',
            done: 28,
            total: 40,
            correct: 21,
            wrong: 7,
          ),
          Section(
            id: 'exam_section_4_2',
            chapterId: 'chapter_4',
            title: '第二节：评分方法',
            done: 24,
            total: 40,
            correct: 17,
            wrong: 7,
          ),
        ],
      ),
    ];
  }

  List<Paper> _initialPracticePapers() {
    return const [
      Paper(
          id: 'practice_paper_2025',
          title: '2025真题卷',
          done: 68,
          total: 100,
          correct: 54,
          wrong: 8,
          minutes: 72),
      Paper(
          id: 'practice_paper_2024',
          title: '2024真题卷',
          done: 0,
          total: 100,
          correct: 0,
          wrong: 0,
          minutes: 0),
      Paper(
          id: 'practice_paper_2023',
          title: '2023真题卷',
          done: 32,
          total: 100,
          correct: 24,
          wrong: 12,
          minutes: 58),
    ];
  }

  List<Paper> _initialExamPapers() {
    return const [
      Paper(
          id: 'exam_paper_2025',
          title: '2025真题卷',
          done: 88,
          total: 100,
          correct: 70,
          wrong: 18,
          minutes: 72),
      Paper(
          id: 'exam_paper_2024',
          title: '2024真题卷',
          done: 0,
          total: 100,
          correct: 0,
          wrong: 0,
          minutes: 0),
      Paper(
          id: 'exam_paper_2023',
          title: '2023真题卷',
          done: 62,
          total: 100,
          correct: 47,
          wrong: 15,
          minutes: 58),
    ];
  }

  List<StudyRecord> _initialPracticeRecords() {
    return const [
      StudyRecord(
          title: '教育目的概述',
          mode: '章节练习',
          metric: '20/30题 · 正确率 78%',
          time: '今天 09:30'),
      StudyRecord(
          title: '班级管理原则',
          mode: '真题练习',
          metric: '36/50题 · 正确率 74%',
          time: '昨天 21:10'),
    ];
  }

  List<StudyRecord> _initialExamRecords() {
    return const [
      StudyRecord(
          title: '教育基础综合卷',
          mode: '章节考试',
          metric: '72分 · 正确率 72%',
          time: '今天 10:20'),
      StudyRecord(
          title: '学生指导模拟卷',
          mode: '模拟考试',
          metric: '68分 · 正确率 68%',
          time: '昨天 18:40'),
    ];
  }

  List<Question> _sampleQuestions(
      {required String prefix, required int count}) {
    final base = <Question>[
      Question(
        id: '${prefix}_q1',
        type: QuestionType.single,
        stem: '在教师资格证考试中，教育观的核心内容是什么？',
        options: ['以人为本', '以分数为本', '以教材为本', '以考试为本'],
        answerIndexes: {0},
        analysis: '教育观强调以学生发展为中心，尊重学生主体地位，促进学生全面发展。',
      ),
      Question(
        id: '${prefix}_q2',
        type: QuestionType.single,
        stem: '电气设备发生火灾时，应首先采取的措施是什么？',
        options: ['立即用水灭火', '切断电源', '用湿布覆盖', '等待自动断电'],
        answerIndexes: {1},
        analysis: '电气设备火灾应首先切断电源，避免触电和火势扩大，再使用合适灭火器材。',
      ),
      Question(
        id: '${prefix}_q3',
        type: QuestionType.multiple,
        stem: '以下哪些属于新课程改革的具体目标？',
        options: ['实现课程功能转变', '密切课程内容与生活联系', '实行三级课程管理', '取消所有考试评价'],
        answerIndexes: {0, 1, 2},
        analysis: '新课程改革强调课程功能、课程内容和课程管理机制的调整，不是取消全部评价。',
      ),
      Question(
        id: '${prefix}_q4',
        type: QuestionType.trueFalse,
        stem: '教育目的的社会本位论认为，教育目的应根据个人发展需要来确定。',
        options: ['正确', '错误'],
        answerIndexes: {1},
        analysis: '社会本位论强调教育目的由社会需要决定，个人本位论才强调个人发展。',
      ),
      Question(
        id: '${prefix}_q5',
        type: QuestionType.single,
        stem: '班主任工作的中心环节通常是？',
        options: ['了解和研究学生', '组织和培养班集体', '建立学生档案', '安排值日工作'],
        answerIndexes: {1},
        analysis: '组织和培养班集体是班主任工作的中心环节，也是开展教育活动的重要基础。',
      ),
      Question(
        id: '${prefix}_q6',
        type: QuestionType.single,
        stem: '以下哪一项最能体现启发性教学原则？',
        options: ['教师直接给出标准答案', '引导学生主动思考', '要求学生机械背诵', '只关注考试分数'],
        answerIndexes: {1},
        analysis: '启发性原则要求教师调动学生学习主动性，引导学生独立思考和探究。',
      ),
      Question(
        id: '${prefix}_q7',
        type: QuestionType.single,
        stem: '学生身心发展的顺序性要求教育工作应当？',
        options: ['循序渐进', '拔苗助长', '整齐划一', '只重结果'],
        answerIndexes: {0},
        analysis: '顺序性要求教育遵循学生发展阶段，循序渐进地安排内容和方法。',
      ),
      Question(
        id: '${prefix}_q8',
        type: QuestionType.multiple,
        stem: '教学评价的功能包括哪些？',
        options: ['诊断功能', '激励功能', '调控功能', '惩罚功能'],
        answerIndexes: {0, 1, 2},
        analysis: '教学评价具有诊断、激励、调控等功能，不应以惩罚作为主要目的。',
      ),
    ];

    return List.generate(count, (index) {
      final source = base[index % base.length];
      return Question(
        id: '${prefix}_q${index + 1}',
        type: source.type,
        stem: source.stem,
        options: source.options,
        answerIndexes: source.answerIndexes,
        analysis: source.analysis,
      );
    });
  }
}

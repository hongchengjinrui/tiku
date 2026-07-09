import '../mock/models.dart';
import 'tiku_repository.dart';

class MockTikuRepository implements TikuRepository {
  @override
  List<Subject> loadSubjects() {
    return const [
      Subject(id: 'primary_teacher', name: '小学教师', isDefault: true),
      Subject(id: 'kindergarten_teacher', name: '幼儿教师'),
      Subject(id: 'middle_teacher', name: '中学教师'),
      Subject(id: 'teacher_recruit', name: '教师招聘'),
    ];
  }

  @override
  List<Chapter> loadPracticeChapters() {
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

  @override
  List<Chapter> loadExamChapters() {
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

  @override
  List<Paper> loadPracticePapers() {
    return const [
      Paper(
        id: 'practice_paper_2025',
        title: '2025真题卷',
        done: 68,
        total: 100,
        correct: 54,
        wrong: 8,
        minutes: 72,
      ),
      Paper(
        id: 'practice_paper_2024',
        title: '2024真题卷',
        done: 0,
        total: 100,
        correct: 0,
        wrong: 0,
        minutes: 0,
      ),
      Paper(
        id: 'practice_paper_2023',
        title: '2023真题卷',
        done: 32,
        total: 100,
        correct: 24,
        wrong: 12,
        minutes: 58,
      ),
    ];
  }

  @override
  List<Paper> loadExamPapers() {
    return const [
      Paper(
        id: 'exam_paper_2025',
        title: '2025真题卷',
        done: 88,
        total: 100,
        correct: 70,
        wrong: 18,
        minutes: 72,
      ),
      Paper(
        id: 'exam_paper_2024',
        title: '2024真题卷',
        done: 0,
        total: 100,
        correct: 0,
        wrong: 0,
        minutes: 0,
      ),
      Paper(
        id: 'exam_paper_2023',
        title: '2023真题卷',
        done: 62,
        total: 100,
        correct: 47,
        wrong: 15,
        minutes: 58,
      ),
    ];
  }

  @override
  List<StudyRecord> loadPracticeRecords() {
    return const [
      StudyRecord(
        title: '教育目的概述',
        mode: '章节练习',
        metric: '20/30题 · 正确率 78%',
        time: '今天 09:30',
      ),
      StudyRecord(
        title: '班级管理原则',
        mode: '真题练习',
        metric: '36/50题 · 正确率 74%',
        time: '昨天 21:10',
      ),
    ];
  }

  @override
  List<StudyRecord> loadExamRecords() {
    return const [
      StudyRecord(
        title: '教育基础综合卷',
        mode: '章节考试',
        metric: '72分 · 正确率 72%',
        time: '今天 10:20',
      ),
      StudyRecord(
        title: '学生指导模拟卷',
        mode: '模拟考试',
        metric: '68分 · 正确率 68%',
        time: '昨天 18:40',
      ),
    ];
  }

  @override
  List<Question> buildPracticeSectionQuestions(Section section) {
    return _sampleQuestions(prefix: section.id, count: 8);
  }

  @override
  List<Question> buildPracticePaperQuestions(Paper paper) {
    return _sampleQuestions(prefix: paper.id, count: 10);
  }

  @override
  List<Question> buildRandomPracticeQuestions({
    required int count,
    List<String> catalogIds = const [],
  }) {
    return _catalogSampleQuestions(
      fallbackPrefix: 'random',
      count: count.clamp(5, 50).toInt(),
      catalogIds: catalogIds,
    );
  }

  @override
  List<Question> buildFavoritePracticeQuestions({required int count}) {
    return _sampleQuestions(
      prefix: 'favorite',
      count: count.clamp(1, 20).toInt(),
    );
  }

  @override
  List<Question> buildWrongPracticeQuestions({required int count}) {
    return _sampleQuestions(prefix: 'wrong', count: count.clamp(1, 80).toInt());
  }

  @override
  List<Question> buildExamSectionQuestions(Section section) {
    return _sampleQuestions(prefix: 'exam_${section.id}', count: 12);
  }

  @override
  List<Question> buildExamPaperQuestions(Paper paper) {
    return _sampleQuestions(prefix: 'exam_${paper.id}', count: 12);
  }

  @override
  List<Question> buildAssemblyExamQuestions({
    required int count,
    List<String> catalogIds = const [],
  }) {
    return _catalogSampleQuestions(
      fallbackPrefix: 'assembly',
      count: count.clamp(8, 20).toInt(),
      catalogIds: catalogIds,
    );
  }

  List<Question> _catalogSampleQuestions({
    required String fallbackPrefix,
    required int count,
    required List<String> catalogIds,
  }) {
    final ids = catalogIds.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) {
      return _sampleQuestions(prefix: fallbackPrefix, count: count);
    }
    final questions = <Question>[];
    for (final id in ids) {
      questions.addAll(_sampleQuestions(prefix: id, count: count));
      if (questions.length >= count) {
        break;
      }
    }
    return questions.take(count).toList();
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

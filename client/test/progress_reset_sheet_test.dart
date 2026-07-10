import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/features/common/progress_reset_sheet.dart';

void main() {
  testWidgets('progress reset sheet supports group and custom selection',
      (tester) async {
    var confirmedIds = <String>[];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: _ResetSheetHarness(
          onConfirm: (ids) async {
            confirmedIds = ids;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('打开重置'));
    await tester.pumpAndSettle();

    expect(find.text('全部目录'), findsOneWidget);
    expect(find.text('章节练习（共2章）'), findsOneWidget);
    expect(find.text('第一章：教育基础'), findsOneWidget);

    await tester.tap(find.text('第二章：安全规范'));
    await tester.pump();
    await tester.tap(find.text('章节练习（共2章）'));
    await tester.pump();
    await tester.tap(find.text('章节练习（共2章）'));
    await tester.pump();

    await tester.tap(find.text('确认重置'));
    await tester.pumpAndSettle();

    expect(find.text('确认重置进度？'), findsOneWidget);
    await tester.tap(find.text('确认重置').last);
    await tester.pumpAndSettle();

    expect(confirmedIds, ['paper_1']);
    expect(find.text('全部目录'), findsNothing);
    expect(find.text('进度已重置'), findsOneWidget);
  });

  testWidgets('progress reset sheet disables confirm when nothing selected',
      (tester) async {
    var confirmCount = 0;

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: _ResetSheetHarness(
          onConfirm: (_) async {
            confirmCount += 1;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('打开重置'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('全部目录'));
    await tester.pump();
    await tester.tap(find.text('确认重置'));
    await tester.pump();

    expect(find.text('确认重置进度？'), findsNothing);
    expect(confirmCount, 0);

    await tester.tap(find.text('全部目录'));
    await tester.pump();
    await tester.tap(find.text('确认重置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认重置').last);
    await tester.pumpAndSettle();

    expect(confirmCount, 1);
  });
}

class _ResetSheetHarness extends StatelessWidget {
  final Future<bool> Function(List<String> ids) onConfirm;

  const _ResetSheetHarness({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ProgressResetSheet(
                title: '重置进度',
                description: '选择需要重置的目录，重置后将清空对应目录的练习记录。',
                allDescription: '章节练习与模拟真题全部重置',
                confirmMessage: '将清空已选目录的练习记录、正确率与错题统计，此操作不可撤销。',
                groups: const [
                  ResetCatalogGroup(
                    title: '章节练习（共2章）',
                    subtitle: '30/160',
                    entries: [
                      ResetCatalogEntry(
                        id: 'chapter_1',
                        title: '第一章：教育基础',
                        progress: '20/80',
                      ),
                      ResetCatalogEntry(
                        id: 'chapter_2',
                        title: '第二章：安全规范',
                        progress: '10/80',
                      ),
                    ],
                  ),
                  ResetCatalogGroup(
                    title: '模拟真题（共1套）',
                    subtitle: '60/100',
                    entries: [
                      ResetCatalogEntry(
                        id: 'paper_1',
                        title: '模拟卷一',
                        progress: '60/100',
                      ),
                    ],
                  ),
                ],
                onConfirm: onConfirm,
              ),
            );
          },
          child: const Text('打开重置'),
        ),
      ),
    );
  }
}

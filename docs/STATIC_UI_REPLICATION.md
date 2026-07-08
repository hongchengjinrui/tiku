# 静态 UI 高保真复刻推进表

本阶段目标：先按 Pencil 画布逐页落地 Flutter 静态页面，不接后端接口、不接中台数据、不处理真实登录与支付。

## 复刻原则

1. 页面本体使用 Flutter Widget 实现，不使用整页截图直接充当页面。
2. Pencil 截图作为视觉校验参考；题图、资料封面、文档预览图等原本属于内容资产的位置可以使用图片或占位内容区。
3. 页面宽度以 Pencil 移动画布 `390px` 为基准。
4. 先落地静态显示和页面间跳转，再补真实状态、接口和缓存。
5. 底部导航固定为：`练习 / 考试 / 资料 / 我的`。

## 页面路由索引

### 练习链路

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| P00 启动页 | `P00SplashPage` | `/splash` | 已落地 |
| P01 练习模式首页 | `P01PracticeHomePage` | `/practice` | 已落地 |
| P01A 切换科目弹窗 | `P01ASwitchSubjectSheet` | `/practice/switch-subject` | 已落地 |
| P02 练习目录页 | `P02PracticeCatalogPage` | `/practice/catalog` | 已落地 |
| P02A 重置进度弹窗 | `P02AResetProgressSheet` | `/practice/reset` | 已落地 |
| P02B 重置-全部目录全选 | `P02BResetAllSelectedPage` | `/practice/reset/all` | 已落地 |
| P02C 重置-二级目录全选 | `P02CResetLevel2SelectedPage` | `/practice/reset/level2` | 已落地 |
| P02D 重置-自定义半选 | `P02DResetCustomSelectedPage` | `/practice/reset/custom` | 已落地 |
| P02E 重置二次确认 | `P02EConfirmResetDialog` | `/practice/reset/confirm` | 已落地 |
| P03 章节练习小节列表 | `P03ChapterSectionListPage` | `/practice/sections` | 已落地 |
| P03A 小节重置确认 | `P03ASectionResetConfirmationModal` | `/practice/sections/reset-confirm` | 已落地 |
| P04 真题练习试卷列表 | `P04RealExamPaperListPage` | `/practice/papers` | 已落地 |
| P04A 真题重置确认 | `P04APaperResetConfirmationModal` | `/practice/papers/reset-confirm` | 已落地 |
| P05 刷题页 | `P05QuestionPracticePage` | `/practice/quiz` | 已落地 |
| P06 随机练习设置 | `P06RandomPracticePage` | `/practice/random` | 已落地 |
| P06A 自选章节展开 | `P06ARandomPracticeExpandedPage` | `/practice/random/custom` | 已落地 |
| P07 收藏练习 | `P07FavoritePracticePage` | `/practice/favorite` | 已落地 |
| P08 错题练习入口 | `P08WrongPracticeEntryPage` | `/practice/wrong` | 已落地 |
| P08A 清空错题确认 | `P08AClearWrongDialog` | `/practice/wrong/clear-confirm` | 已落地 |
| P08B 错题练习页 | `P08BWrongPracticePage` | `/practice/wrong/quiz` | 已落地 |

### 考试链路

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| P20 考试模式首页 | `P20ExamHomePage` | `/exam` | 已落地 |
| P20A 考试规则弹窗 | `P20AExamRulesModal` | `/exam/rules` | 已落地 |
| P21 章节考试目录页 | `P21ChapterExamCatalogPage` | `/exam/catalog` | 已落地 |
| P21A 章节考试小节列表 | `P21AChapterExamSectionListPage` | `/exam/sections` | 已落地 |
| P21B 重考确认 | `P21BRetakeConfirmationModal` | `/exam/retake-confirm` | 已落地 |
| P22 真题考试试卷列表 | `P22RealExamPaperListPage` | `/exam/papers` | 已落地 |
| P23 考试重置弹窗 | `P23ExamResetModal` | `/exam/reset` | 已落地 |
| P23A 重置-全部目录全选 | `P23AResetAllSelectedPage` | `/exam/reset/all` | 已落地 |
| P23B 重置-二级目录全选 | `P23BResetLevel2SelectedPage` | `/exam/reset/level2` | 已落地 |
| P23C 重置-自定义半选 | `P23CResetCustomSelectedPage` | `/exam/reset/custom` | 已落地 |
| P23D 重置二次确认 | `P23DResetSecondaryConfirmationPage` | `/exam/reset/confirm` | 已落地 |
| P24 组卷设置页 | `P24ExamAssemblySettingsPage` | `/exam/assemble` | 已落地 |
| P24A 组卷-全部章节 | `P24AAssemblyAllChaptersPage` | `/exam/assemble/all` | 已落地 |
| P25 考试答题页 | `P25ExamAnsweringPage` | `/exam/answer` | 已落地 |
| P26 答题卡页 | `P26AnswerCardPage` | `/exam/card` | 已落地 |
| P27 交卷确认-有未答 | `P27SubmitExamConfirmationModal` | `/exam/submit-confirm` | 已落地 |
| P27A 交卷确认-全部已答 | `P27ASubmitAllAnsweredModal` | `/exam/submit-confirm/all-answered` | 已落地 |
| P28 考试解析页 | `P28ExamAnalysisPage` | `/exam/analysis` | 已落地 |
| P28A 解析详情-未作答 | `P28AAnalysisUnansweredPage` | `/exam/analysis/unanswered` | 已落地 |
| P28B 解析详情-答错 | `P28BAnalysisWrongPage` | `/exam/analysis/wrong` | 已落地 |
| P28C 解析详情-答对 | `P28CAnalysisCorrectPage` | `/exam/analysis/correct` | 已落地 |

### 资料链路

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| P40 资料中心 | `P40ResourceCenterPage` | `/resources` | 已落地 |
| P40A 免费资料详情 | `P40AFreeResourceDetailPage` | `/resources/free` | 已落地 |
| P40B 链接复制 Toast | `P40BLinkCopiedToastPage` | `/resources/free/toast` | 已落地 |
| P41 付费资料预览 | `P41PaidResourcePreviewPage` | `/resources/paid` | 已落地 |
| P41A VIP 开通页 | `P41AVipPage` | `/vip` | 已落地 |
| P42 已解锁资料详情 | `P42UnlockedResourceDetailPage` | `/resources/unlocked` | 已落地 |

### 我的与账号

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| P50 我的页面 | `P50ProfilePage` | `/profile` | 已落地 |
| P51 全部练习记录 | `P51PracticeRecordsPage` | `/profile/practice-records` | 已落地 |
| P51A 删除单条练习记录 | `P51ADeletePracticeRecordConfirmPage` | `/profile/practice-records/delete` | 已落地 |
| P51B 删除全部练习记录 | `P51BDeleteAllPracticeRecordsConfirmPage` | `/profile/practice-records/delete-all` | 已落地 |
| P52 全部考试记录 | `P52ExamRecordsPage` | `/profile/exam-records` | 已落地 |
| P52A 删除单条考试记录 | `P52ADeleteExamRecordConfirmPage` | `/profile/exam-records/delete` | 已落地 |
| P52B 删除全部考试记录 | `P52BDeleteAllExamRecordsConfirmPage` | `/profile/exam-records/delete-all` | 已落地 |
| P53 我的-错题入口 | `P53WrongEntryPage` | `/profile/wrong` | 已落地 |
| P54 题目纠错 | `P54FeedbackPage` | `/profile/correction` | 已落地 |
| P55 上传题库 | `P55UploadBankPage` | `/profile/upload` | 已落地 |
| P56 意见反馈 | `P56FeedbackPage` | `/profile/feedback` | 已落地 |
| P57 关于页面 | `P57AboutPage` | `/profile/about` | 已落地 |
| P58 登录页 | `P58LoginPage` | `/login` | 已落地 |
| P58A 一键登录页 | `P58AQuickLoginPage` | `/login/quick` | 已落地 |
| P59 VIP 开通页 | `P59VipPage` | `/profile/vip` | 已落地 |
| P59A 支付成功页 | `P59APaymentSuccessPage` | `/vip/success` | 已落地 |
| P60 会员协议 | `P60AgreementPage` | `/agreement/member` | 已落地 |
| P61 用户协议 | `P60AgreementPage` | `/agreement/user` | 已落地 |
| P62 隐私协议 | `P60AgreementPage` | `/agreement/privacy` | 已落地 |

### 空状态

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| E01 无练习记录 | `E01NoPracticeRecordPage` | `/empty/practice` | 已落地 |
| E02 无错题 | `E02NoWrongQuestionPage` | `/empty/wrong` | 已落地 |
| E03 无收藏 | `E03NoFavoritePage` | `/empty/favorite` | 已落地 |
| E04 无考试记录 | `E04NoExamRecordPage` | `/empty/exam` | 已落地 |

### 题型状态

| 页面 | Flutter 页面 | 路由 | 状态 |
| --- | --- | --- | --- |
| QT01 单选作答 | `QT01SingleChoicePage` | `/qt/single` | 已落地 |
| QT02 多选作答 | `QT02MultipleChoicePage` | `/qt/multiple` | 已落地 |
| QT03 判断作答 | `QT03TrueFalsePage` | `/qt/truefalse` | 已落地 |
| QT04 填空作答 | `QT04FillBlankPage` | `/qt/fillblank` | 已落地 |
| QT05 简答作答 | `QT05ShortAnswerPage` | `/qt/short` | 已落地 |
| QT06 材料题作答 | `QT06MaterialPage` | `/qt/material` | 已落地 |
| QT07 图片题作答 | `QT07ImageQuestionPage` | `/qt/image` | 已落地 |
| QT08 图片加载失败 | `QT08ImageLoadFailedPage` | `/qt/image-error` | 已落地 |
| QT09 单选结果态 | `QT09SingleChoiceResultPage` | `/qt/single/result` | 已落地 |
| QT10 多选结果态 | `QT10MultipleChoiceResultPage` | `/qt/multiple/result` | 已落地 |
| QT11 判断结果态 | `QT11TrueFalseResultPage` | `/qt/truefalse/result` | 已落地 |
| QT12 填空结果态 | `QT12FillBlankResultPage` | `/qt/fillblank/result` | 已落地 |
| QT13 简答评分结果 | `QT13ShortAnswerScoredResultPage` | `/qt/short/result` | 已落地 |
| QT14 材料题结果态 | `QT14MaterialResultPage` | `/qt/material/result` | 已落地 |
| QT15 图片题结果态 | `QT15ImageResultPage` | `/qt/image/result` | 已落地 |
| QT16 题干多图结果 | `QT16MultiImageResultPage` | `/qt/multi-image/result` | 已落地 |
| QT17 解析多图结果 | `QT17AnalysisMultiImageResultPage` | `/qt/analysis-images/result` | 已落地 |

## 验证记录

- `dart format`：已执行。
- `flutter analyze`：通过。
- `flutter test`：通过。
- `client/test/static_routes_test.dart`：逐个打开全部静态路由，已通过。

# 真机回归待办

记录日期：2026-07-10

## 背景

今晚真机将从电脑移除，后续开发先跳过 Android 真机安装、截图和焦点确认，优先推进客户端逻辑主线。真机明天接回后，再统一补回这里列出的回归项。

## 今晚跳过的真机步骤

- `adb devices` 设备在线确认。
- `flutter build apk --debug` 后的 `adb install -r -d -t ...` 真机安装。
- 启动 `com.example.tiku_muban/.MainActivity` 并确认前台焦点。
- 真机截图或录屏检查。
- 真机手动点击冒烟：练习、考试、资料、我的四个底部导航来回切换。

## 明天补测重点

- 练习链路：章节练习、模拟真题、随机练习、收藏练习、错题练习、答题页退出来源是否正确。
- 练习答题卡：练习答题页打开答题卡，点击题号跳到对应题目，点击“返回答题”保留当前题。
- 收藏练习空态：无收藏时点击“去练习”回到练习首页；当前题型筛选为空但仍有其它收藏时点击“查看全部”恢复全部收藏列表。
- 错题练习空态：无错题时点击“去练习”回到练习首页；当前筛选为空但仍有其它错题时点击“重置筛选”恢复全部错题列表。
- 我的页错题入口：无错题时点击“去练习”回到练习首页；有错题时进入完整错题练习筛选页。
- 练习空状态：答题页会话丢失或无练习内容时，点击“返回练习入口”能回到练习首页。
- 考试链路：章节考试、真题卷考试、自选章节组卷、答题卡、交卷确认、解析页。
- 考试答题空状态：答题页会话丢失或无考试内容时，点击“返回考试入口”能回到考试首页。
- 考试答题卡：点击题号跳回对应试题、返回答题保留当前题、未答题交卷弹窗确认后进入解析。
- 考试解析：未作答、答错题、已答对三类的“查看全部”和题号入口能进入正确详情页，上一题/下一题只在当前分类内切换；分类为空时可点击“返回解析总览”回到解析页。
- 考试空状态：无考试会话时进入答题卡、解析总览、解析详情页，点击“返回考试入口”能回到考试首页。
- 全局切换科目：练习首页、考试首页、资料页打开切换弹窗后，选择科目能回到来源页并刷新数据。
- 资料链路：直接进入免费资料详情默认展示免费资料，直接进入 VIP 资料详情默认展示 VIP 资料；点击获取下载链接后出现复制提示并写入资料领取记录。
- 我的页：题库维护入口、意见反馈、题目纠错、反馈记录、缓存管理、练习记录/考试记录删除全部、资料领取记录、关于我们/协议入口。
- 资料领取记录：有记录时复制链接出现提示；无记录时点击“去资料中心”回到资料页。
- 反馈记录：单条移除、清空全部、清空后的“去反馈”入口都能正常跳转。
- 我的页记录空态：练习记录清空后点击“去练习”回到练习首页；考试记录清空后点击“去考试”回到考试首页。
- 记录链路：练习记录点击“重新练习”进入对应练习；练习/考试记录单条删除后列表与统计数量同步更新；未交卷考试记录点击“继续考试”进入答题；已交卷考试记录点击“查看解析”进入解析。
- 占位边界：登录页、一键登录页、VIP 页、VIP 成功页均保持开放体验/本地游客模式，不出现真实支付、登录、VIP 开通流程。
- 弹窗/底部浮层：确认弹窗、删除记录弹窗、重置进度弹窗在真机上不遮挡按钮，点击后能返回正确页面。
- 独立弹窗路由：`/exam/rules`、`/exam/submit-confirm`、`/exam/submit-confirm/all-answered`、练习重置确认路由在真机点击后能安全返回或提交。
- 竖屏锁定：旋转手机后 App 仍保持竖屏。
- 顶部系统占位：客户端页面不再显示设计稿里的假时间和假状态栏图标。

## 建议命令

```bash
cd /Users/hnf/Desktop/tiku/client
flutter analyze
flutter test test/mock_app_store_test.dart test/static_routes_test.dart test/practice_question_page_test.dart test/exam_interaction_test.dart
flutter build apk --debug
adb devices
adb install -r -d -t build/app/outputs/flutter-apk/app-debug.apk
adb shell monkey -p com.example.tiku_muban 1
adb shell dumpsys window | rg "mCurrentFocus|mFocusedApp"
```

## 说明

支付、登录、VIP、签名仍保持不上架前再接入。本清单只覆盖当前阶段需要补回的真机交互与显示回归。

## 真机已补回

- Android 设备已重新连接并确认在线：`NOH AL10 / Android 12 (API 31)`。
- 已重新执行 `flutter build apk --debug` 并通过 `adb install -r -d -t` 安装到真机。
- 已启动 `com.example.tiku_muban/.MainActivity`，并确认前台焦点保持在 App。
- 已补回底部导航真机烟测：练习、考试、资料、我的、我的返回练习。
- 已将底部导航项改为四等分可点击区域，避免真机点击仅命中图标/文字窄区域导致误判。
- 已保存真机截图：
  - `docs/device-screenshots/android-practice-home-2026-07-10.png`
  - `docs/device-screenshots/android-exam-home-2026-07-10.png`
  - `docs/device-screenshots/android-resources-home-2026-07-10.png`
  - `docs/device-screenshots/android-profile-home-2026-07-10.png`
  - `docs/device-screenshots/android-practice-return-2026-07-10.png`
- 已确认顶部只保留系统原生状态栏和白色背景，不再显示设计稿中的假时间与假状态栏图标。
- 已确认竖屏方向保持正常；后续完整回归时仍需单独做旋转验证。
- 已恢复本机 `pnpm` Corepack shim，并执行项目级回归：`RUN_ANDROID=0 pnpm regression:local`。
- 项目级回归已通过：后端构建、中台构建、Flutter 分析、Store 测试、后端/客户端/中台 E2E smoke。
- 已执行 Android 联调安装：`RUN_CHECKS=0 RUN_SMOKE=0 RUN_ADMIN=0 RUN_ANDROID=1 pnpm regression:local`。
- 已确认真机通过 `adb reverse tcp:3000 tcp:3000` 连到本机后端，首页展示 `在线同步`、科目为电网题库的 `综合类`。
- 已修复远端题库水合后残留旧本地会话的问题；真机保留旧缓存重装后，旧的 `电力工程基础` 继续练习卡已自动清理。
- 已保存远端联通截图：`docs/device-screenshots/android-linked-practice-home-after-session-prune-2026-07-10.png`。
- 已确认联网切换科目成功：从 `综合类` 切换到 `其他理工科类` 后，练习进度更新为该科目的 `0/4559`。
- 已修复练习/考试记录跨科目串数据；真机切换到无记录科目后，“最近练习”展示标准空态。
- 已通过数据库 E2E 验证错题规则：答错加入错题本，第一次答对仍保留，第二次答对后按 `2/2` 阈值移出。
- 已将练习/考试进度改为按题目去重，重复作答不再导致进度超过总题量；本地测试用户旧累计值已重算。
- 已确认上次选择的科目在强制结束并重新启动 App 后仍会恢复，不再被服务端默认科目覆盖。
- 已确认资料按当前科目隔离：无资料科目展示空态，`综合类` 数据卡展示真实的 `5份VIP备考资料 + 1份免费备考资料`。
- 已将考试历史记录改为结构化保存真实题目、答案和服务端判分；真机 2 题记录准确展示 `1题未作答 / 0题答错 / 1题答对 / 50分`。
- 已补齐离线反馈启动后自动重传、题目 ID 关联，以及离线状态条的手动重连入口。
- 已保存本轮联网截图：
  - `docs/device-screenshots/android-online-sync-batch-2026-07-10.png`
  - `docs/device-screenshots/android-subject-switch-other-engineering-2026-07-10.png`
  - `docs/device-screenshots/android-subject-record-isolation-2026-07-10.png`
  - `docs/device-screenshots/android-exact-exam-record-analysis-2026-07-10.png`
  - `docs/device-screenshots/android-resource-subject-counts-2026-07-10.png`
- 已验证资料统计长文案会在真机宽度下完整显示，不再以省略号截断：
  - `docs/device-screenshots/android-final-resources-title-fit-2026-07-10.png`
- 已验证离线缓存与手动重连完整闭环：移除 `adb reverse` 后显示重连入口，恢复端口映射并点击后回到“在线同步”。
- 已将远端科目元数据纳入 v6 本地快照；在线写入快照后离线冷启动仍显示当前科目“综合类”，不会回退到模板科目“小学教师”。
- 已保存离线与恢复在线截图：
  - `docs/device-screenshots/android-final-offline-reconnect-2026-07-10.png`
  - `docs/device-screenshots/android-final-manual-reconnect-2026-07-10.png`
  - `docs/device-screenshots/android-final-offline-subject-cache-v6-2026-07-10.png`
  - `docs/device-screenshots/android-final-online-after-v6-reconnect-2026-07-10.png`

## 今晚本地已覆盖

- `flutter analyze`
- `flutter test test/mock_app_store_test.dart test/static_routes_test.dart test/practice_question_page_test.dart test/exam_interaction_test.dart`
- `flutter test test/mock_app_store_test.dart` 已覆盖全部题型在本地快照中的标准化存储与恢复，包括富文本、图片、答案、错题时间、活动练习/考试会话与题目缓存
- `flutter test test/mock_app_store_test.dart` 已覆盖练习/考试进度重置后的章节、真题卷与总数据面板聚合统计同步
- `flutter test test/practice_question_page_test.dart` 已覆盖练习答题卡跳题与返回答题
- `flutter test test/practice_question_page_test.dart` 已覆盖练习答题页收藏切换、题目纠错提交、错题练习移出题目后的会话更新与空态返回
- `flutter test test/progress_reset_sheet_test.dart` 已覆盖通用重置进度浮层的全选、二级目录切换、自定义选择、空选择禁用确认与二次确认
- `flutter test test/custom_selection_flow_test.dart`
- `flutter test test/record_flow_test.dart`，已覆盖练习/考试记录单条删除后的列表与统计同步
- `flutter test test/static_routes_test.dart` 已覆盖练习首页与考试首页数据面板会展示聚合后的进度、正确率、错题量、题目覆盖和记录天数
- `flutter test test/static_routes_test.dart` 已覆盖错题练习按条件筛选后清空当前筛选错题，取消确认不删除，确认后仅移出当前筛选项并保留其它错题
- `flutter test`
- `flutter test --update-goldens test/preview_screenshots_test.dart`
- `RUN_CHECKS=0 RUN_ANDROID=0 pnpm regression:local`
- `flutter build apk --debug`

以上均已通过；此前跳过的 Android 安装、真机截图和关键点击已在设备重新连接后逐步补回，清单顶部未勾选项仍需继续回归。

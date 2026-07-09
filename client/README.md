# Client

Flutter iOS/Android 客户端。当前阶段先承接 Pencil 高保真页面复刻，后续接入真实 API 和本地缓存。

## 启动

```bash
flutter pub get
flutter run
```

本地联调后端时，Android 真机先执行：

```bash
adb reverse tcp:3000 tcp:3000
```

电网主库调试包：

```bash
flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000/api \
  --dart-define=APP_KEY=grid-exam-android \
  --dart-define=DEV_USER_ID=dev-user-001
```

南方电网题库包含填空题/简答题，可用于非选择题链路验证：

```bash
flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000/api \
  --dart-define=APP_KEY=south-grid-android \
  --dart-define=DEV_USER_ID=dev-user-001
```

## 目录约定

```text
lib/core       通用脚手架与基础组件
lib/features   业务页面
lib/routes     App 路由
lib/theme      设计变量与主题
```

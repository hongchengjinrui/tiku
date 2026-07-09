# 技术选型

## 客户端

- Flutter + Dart
- Riverpod 状态管理
- go_router 路由
- Dio 网络请求
- Drift + SQLite 本地缓存

### 客户端数据层约束

- 页面不直接绑定后端接口，统一通过 Store / Repository 读取数据。
- Repository 已具备 Mock + Remote 边界：启动时优先异步拉取后端数据，失败时自动保留 Mock 兜底，避免真机测试白屏。
- 题库目录、题目、练习记录、考试记录、进度统计等模型需保持客户端与后端接口字段一致。
- 练习与考试的会话状态由客户端 Store 管理，后端只接收最终进度、记录和答题结果。
- 第一期本地缓存只做基础缓存与弱网兜底，不支持离线刷题。

### 三端 SDK 接入原则

- 登录、支付、推送、统计、文档预览、分享等能力优先接入成熟 SDK，不重复自研成熟通用能力。
- 每个 SDK 接入前必须分别评估 iOS、Android、鸿蒙三端覆盖情况。
- 若同一 SDK 无法同时覆盖三端，需要为缺口端补充官方 SDK、兼容 SDK 或平台通道封装。
- Flutter 层只暴露统一业务接口，不让页面感知具体平台 SDK 差异。
- 支付能力需分别考虑微信支付、支付宝支付、苹果 IAP；鸿蒙端支付方案在落地前单独确认。
- 所有 SDK 接入需记录版本、初始化位置、回调链路、隐私权限、平台配置和降级策略。

## 后端

- NestJS + TypeScript
- PostgreSQL 主数据库
- Prisma 管理数据模型与迁移
- Swagger / OpenAPI 接口文档
- JWT + Refresh Token 鉴权
- 当前本地联调阶段提供 `client` 与 `admin` 两套 API 命名空间；登录与支付暂不启用，使用固定开发测试用户。
- V4 电网题库通过 `backend/scripts/import-v4-grid.ts` 导入，按科目 → 章节练习/模拟真题 → 章/卷类型 → 四级入口建目录。
- 简答题第一期采用程序评分：关键词、别名、must-have 得分点命中，暂不接大模型语义评分。

## 中台管理端

- React + TypeScript
- Vite
- Ant Design
- React Router
- Axios
- 当前中台覆盖运营概览、题库目录、题目抽查、资料管理、用户查看、反馈处理、AI 模型配置、App 配置。

## 资源与部署

- 题图、PDF、Word、封面图走 OSS + CDN
- ECS 首期跑 API、中台、Nginx 和轻量任务
- 生产数据库优先使用 RDS PostgreSQL
- 本地开发使用 Docker Compose PostgreSQL

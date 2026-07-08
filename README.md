# 题库 APP

本仓库是题库母版 APP 的主项目仓库，包含客户端、后端 API 和中台管理端。

## 目录结构

```text
backend/   NestJS + PostgreSQL 后端 API
admin/     React + Ant Design 中台管理端
client/    Flutter iOS/Android 客户端
docs/      技术方案与开发文档
```

## 本地前置环境

- Node.js 24 LTS
- pnpm 11+
- Flutter stable
- Docker Desktop

## 常用命令

```bash
pnpm install
pnpm db:up
pnpm dev:backend
pnpm dev:admin
cd client && flutter pub get
cd client && flutter run
```

## 本地数据

`/V4版题库_简答拆解/` 是本地题库原始数据目录，已加入 `.gitignore`，不提交到 Git。

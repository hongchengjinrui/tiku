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
pnpm db:push
pnpm db:seed:grid
pnpm dev:backend
pnpm dev:admin
cd client && flutter pub get
cd client && flutter run
```

## 电网刷题本地联调

首期以 `V4版题库_简答拆解/电网刷题真题库` 为基准题库。登录、支付和 VIP 遮挡先不启用，客户端使用 `dev-user-001` 本地测试用户，资料全部开放展示。

1. 启动 PostgreSQL。

```bash
pnpm db:up
```

如果 macOS 已安装 Docker Desktop 但没有 `docker` 命令，可先启动 Docker Desktop，并临时使用：

```bash
pnpm db:up
```

项目脚本会自动查找系统 `docker compose`、`docker-compose` 或 Docker Desktop 内置的 compose 插件。

如果不使用 Docker，也可以用本机 PostgreSQL：

```bash
brew install postgresql@17
brew services start postgresql@17
createuser -s tiku
createdb -O tiku tiku_dev
psql -d postgres -c "ALTER USER tiku WITH PASSWORD 'tiku_dev_password';"
```

2. 初始化数据库结构并导入电网题库。

```bash
pnpm db:push
pnpm db:seed:grid
```

3. 启动后端和中台。

```bash
pnpm dev:backend
pnpm dev:admin
```

后端 Swagger：`http://localhost:3000/api/docs`

中台：`http://localhost:5173`

4. 客户端连接本机后端。

安卓真机建议先做端口反向代理：

```bash
adb reverse tcp:3000 tcp:3000
cd client
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api --dart-define=APP_KEY=grid-exam-android --dart-define=DEV_USER_ID=dev-user-001
```

## 本地数据

`/V4版题库_简答拆解/` 是本地题库原始数据目录，已加入 `.gitignore`，不提交到 Git。

# Backend

NestJS 后端 API，负责题库、用户、练习记录、考试记录、资料权限和中台接口。

## 启动

```bash
cp .env.example .env
pnpm install
pnpm db:up
pnpm --dir backend prisma:generate
pnpm --dir backend dev
```

健康检查：

```text
GET http://localhost:3000/api/health
```

Swagger：

```text
http://localhost:3000/api/docs
```

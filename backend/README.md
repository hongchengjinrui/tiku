# Backend

NestJS 后端 API，负责题库、用户、练习记录、考试记录、资料权限和中台接口。

## 启动

```bash
cp .env.example .env
pnpm install
pnpm db:up
pnpm --dir backend db:push
pnpm --dir backend prisma:generate
pnpm --dir backend seed:grid
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

## V4 题库导入

默认导入项目目录下：

```text
/Users/hnf/Desktop/tiku/V4版题库_简答拆解/电网刷题真题库
```

导入命令：

```bash
pnpm --dir backend seed:grid
```

南方电网题库包含填空题和简答题，适合验证非选择题答题与程序判分链路：

```bash
pnpm --dir backend seed:south-grid
```

可通过环境变量覆盖数据源：

```bash
V4_DATA_ROOT=/path/to/V4版题库_简答拆解 \
V4_BANK_DIR=南方电网真题库 \
BANK_SLUG=south-grid \
DEFAULT_SUBJECT=综合类 \
pnpm --dir backend seed:v4
```

脚本会按 `BANK_SLUG` 重建对应题库，写入科目、四层目录、题目、开发测试用户、Android/iOS/HarmonyOS App 配置、资料样例、AI 模型配置样例和运营指标样例。导入完成后会输出题型统计，便于核对填空题、简答题等类型是否落库成功。

import {
  App as AntdApp,
  Button,
  Card,
  Col,
  Descriptions,
  Drawer,
  Empty,
  Form,
  Input,
  Layout,
  Menu,
  Popconfirm,
  Progress,
  Row,
  Select,
  Space,
  Statistic,
  Table,
  Tabs,
  Tag,
  Tree,
  Typography,
} from 'antd';
import {
  ApiOutlined,
  AppstoreOutlined,
  BarChartOutlined,
  BookOutlined,
  BranchesOutlined,
  CloudServerOutlined,
  DatabaseOutlined,
  FileTextOutlined,
  MessageOutlined,
  RobotOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { useEffect, useMemo, useState } from 'react';
import { apiClient } from './api/http';

const { Header, Sider, Content } = Layout;

type AnyRecord = Record<string, any>;

const menuItems = [
  { key: 'dashboard', icon: <BarChartOutlined />, label: '运营概览' },
  { key: 'banks', icon: <DatabaseOutlined />, label: '题库与目录' },
  { key: 'questions', icon: <BookOutlined />, label: '题目维护' },
  { key: 'materials', icon: <FileTextOutlined />, label: '资料管理' },
  { key: 'users', icon: <TeamOutlined />, label: '用户查看' },
  { key: 'feedback', icon: <MessageOutlined />, label: '错题反馈' },
  { key: 'ai', icon: <RobotOutlined />, label: 'AI 模型配置' },
  { key: 'apps', icon: <AppstoreOutlined />, label: 'App 配置' },
];

function App() {
  const { message } = AntdApp.useApp();
  const [activeKey, setActiveKey] = useState('dashboard');
  const [loading, setLoading] = useState(false);
  const [dashboard, setDashboard] = useState<AnyRecord | null>(null);
  const [banks, setBanks] = useState<AnyRecord[]>([]);
  const [selectedBankId, setSelectedBankId] = useState<string>();
  const [catalog, setCatalog] = useState<AnyRecord[]>([]);
  const [questions, setQuestions] = useState<AnyRecord[]>([]);
  const [questionTotal, setQuestionTotal] = useState(0);
  const [materials, setMaterials] = useState<AnyRecord[]>([]);
  const [users, setUsers] = useState<AnyRecord[]>([]);
  const [feedback, setFeedback] = useState<AnyRecord[]>([]);
  const [aiModels, setAiModels] = useState<AnyRecord[]>([]);
  const [apps, setApps] = useState<AnyRecord[]>([]);
  const [userDetail, setUserDetail] = useState<AnyRecord | null>(null);
  const [drawer, setDrawer] = useState<{
    type: 'material' | 'ai' | 'question' | 'user' | null;
    record?: AnyRecord;
  }>({ type: null });

  const selectedBank = useMemo(
    () => banks.find((item) => item.id === selectedBankId) ?? banks[0],
    [banks, selectedBankId],
  );

  useEffect(() => {
    void loadAll();
  }, []);

  useEffect(() => {
    if (!selectedBank?.id) return;
    void loadCatalog(selectedBank.id);
    void loadQuestions(selectedBank.id);
    void loadMaterials(selectedBank.id);
  }, [selectedBank?.id]);

  async function loadAll() {
    setLoading(true);
    try {
      const [
        dashboardResponse,
        banksResponse,
        usersResponse,
        feedbackResponse,
        aiResponse,
        appsResponse,
      ] = await Promise.all([
        apiClient.get('/admin/dashboard'),
        apiClient.get('/admin/banks'),
        apiClient.get('/admin/users'),
        apiClient.get('/admin/feedback'),
        apiClient.get('/admin/ai-models'),
        apiClient.get('/admin/apps'),
      ]);
      setDashboard(dashboardResponse.data);
      setBanks(banksResponse.data);
      setSelectedBankId((current) => current ?? banksResponse.data[0]?.id);
      setUsers(usersResponse.data);
      setFeedback(feedbackResponse.data);
      setAiModels(aiResponse.data);
      setApps(appsResponse.data);
    } catch (error) {
      message.warning('暂时无法连接后端，请确认 PostgreSQL 已启动且后端服务正在运行。');
    } finally {
      setLoading(false);
    }
  }

  async function loadCatalog(bankId: string) {
    const response = await apiClient.get(`/admin/banks/${bankId}/catalog`);
    setCatalog(response.data);
  }

  async function loadQuestions(bankId: string) {
    const response = await apiClient.get('/admin/questions', {
      params: { bankId, pageSize: 20 },
    });
    setQuestions(response.data.items);
    setQuestionTotal(response.data.total);
  }

  async function loadMaterials(bankId: string) {
    const response = await apiClient.get('/admin/materials', {
      params: { bankId },
    });
    setMaterials(response.data);
  }

  async function submitMaterial(values: AnyRecord) {
    const previewPages = String(values.previewPages ?? '')
      .split(/\n---+\n|\n\n+/)
      .map((item) => item.trim())
      .filter(Boolean);
    const payload: AnyRecord = {
      ...values,
      sortOrder: Number(values.sortOrder ?? 0),
      previewMeta: previewPages.length ? { pages: previewPages } : undefined,
    };
    delete payload.previewPages;
    if (drawer.record?.id) {
      await apiClient.patch(`/admin/materials/${drawer.record.id}`, payload);
    } else {
      await apiClient.post('/admin/materials', {
        ...payload,
        bankId: selectedBank?.id,
      });
    }
    message.success('资料已保存');
    setDrawer({ type: null });
    if (selectedBank?.id) await loadMaterials(selectedBank.id);
  }

  async function deleteMaterial(record: AnyRecord) {
    await apiClient.delete(`/admin/materials/${record.id}`);
    message.success('资料已删除');
    if (selectedBank?.id) await loadMaterials(selectedBank.id);
  }

  async function submitAi(values: AnyRecord) {
    if (drawer.record?.id) {
      await apiClient.patch(`/admin/ai-models/${drawer.record.id}`, values);
    } else {
      await apiClient.post('/admin/ai-models', values);
    }
    message.success('AI 模型配置已保存');
    setDrawer({ type: null });
    const response = await apiClient.get('/admin/ai-models');
    setAiModels(response.data);
  }

  async function submitQuestion(values: AnyRecord) {
    if (!drawer.record?.id) return;
    let answer: unknown | undefined;
    let options: unknown | undefined;
    try {
      answer = values.answerJson?.trim()
        ? JSON.parse(values.answerJson)
        : undefined;
      options = values.optionsJson?.trim()
        ? JSON.parse(values.optionsJson)
        : undefined;
    } catch {
      message.error('答案或选项不是合法 JSON');
      return;
    }
    await apiClient.patch(`/admin/questions/${drawer.record.id}`, {
      stemText: values.stemText,
      analysisText: values.analysisText,
      answer,
      options,
    });
    message.success('题目已更新');
    setDrawer({ type: null });
    if (selectedBank?.id) {
      await loadQuestions(selectedBank.id);
    }
    const response = await apiClient.get('/admin/feedback');
    setFeedback(response.data);
  }

  async function openUserDetail(record: AnyRecord) {
    const response = await apiClient.get(`/admin/users/${record.id}`);
    setUserDetail(response.data);
    setDrawer({ type: 'user', record });
  }

  async function handleFeedbackStatus(id: string, status: string) {
    await apiClient.patch(`/admin/feedback/${id}`, { status });
    const response = await apiClient.get('/admin/feedback');
    setFeedback(response.data);
    const dashboardResponse = await apiClient.get('/admin/dashboard');
    setDashboard(dashboardResponse.data);
    message.success('反馈状态已更新');
  }

  return (
    <Layout className="app-shell">
      <Sider width={232} className="app-sider">
        <div className="brand">
          <CloudServerOutlined />
          <span>题库中台</span>
        </div>
        <Menu
          mode="inline"
          selectedKeys={[activeKey]}
          items={menuItems}
          onClick={({ key }) => setActiveKey(key)}
        />
      </Sider>
      <Layout>
        <Header className="app-header">
          <div>
            <Typography.Title level={4}>电网刷题运营工作台</Typography.Title>
            <Typography.Text type="secondary">
              V4 数据源 · PostgreSQL · 本地开发环境
            </Typography.Text>
          </div>
          <Space>
            <Select
              className="bank-select"
              value={selectedBank?.id}
              placeholder="选择题库"
              options={banks.map((bank) => ({ label: bank.name, value: bank.id }))}
              onChange={setSelectedBankId}
            />
            <Button icon={<ApiOutlined />} onClick={loadAll} loading={loading}>
              刷新
            </Button>
          </Space>
        </Header>
        <Content className="app-content">
          {activeKey === 'dashboard' && <DashboardView dashboard={dashboard} />}
          {activeKey === 'banks' && (
            <BanksView
              banks={banks}
              selectedBank={selectedBank}
              catalog={catalog}
            />
          )}
          {activeKey === 'questions' && (
            <QuestionsView
              questions={questions}
              total={questionTotal}
              onEdit={(record) => setDrawer({ type: 'question', record })}
              onSearch={(keyword) =>
                selectedBank?.id &&
                apiClient
                  .get('/admin/questions', {
                    params: { bankId: selectedBank.id, keyword, pageSize: 20 },
                  })
                  .then((response) => {
                    setQuestions(response.data.items);
                    setQuestionTotal(response.data.total);
                  })
              }
            />
          )}
          {activeKey === 'materials' && (
            <MaterialsView
              materials={materials}
              onCreate={() => setDrawer({ type: 'material' })}
              onEdit={(record) => setDrawer({ type: 'material', record })}
              onDelete={(record) => void deleteMaterial(record)}
            />
          )}
          {activeKey === 'users' && (
            <UsersView users={users} onOpen={(record) => void openUserDetail(record)} />
          )}
          {activeKey === 'feedback' && (
            <FeedbackView
              feedback={feedback}
              onStatus={handleFeedbackStatus}
              onEditQuestion={(record) =>
                record.question && setDrawer({ type: 'question', record: record.question })
              }
            />
          )}
          {activeKey === 'ai' && (
            <AiView
              aiModels={aiModels}
              onCreate={() => setDrawer({ type: 'ai' })}
              onEdit={(record) => setDrawer({ type: 'ai', record })}
            />
          )}
          {activeKey === 'apps' && <AppsView apps={apps} />}
        </Content>
      </Layout>
      <Drawer
        width={520}
        title={drawerTitle(drawer.type)}
        open={drawer.type !== null}
        onClose={() => setDrawer({ type: null })}
        destroyOnClose
      >
        {drawer.type === 'material' && (
          <MaterialForm record={drawer.record} onSubmit={submitMaterial} />
        )}
        {drawer.type === 'ai' && (
          <AiForm record={drawer.record} onSubmit={submitAi} />
        )}
        {drawer.type === 'question' && (
          <QuestionForm record={drawer.record} onSubmit={submitQuestion} />
        )}
        {drawer.type === 'user' && <UserDetailView detail={userDetail} />}
      </Drawer>
    </Layout>
  );
}

function DashboardView({ dashboard }: { dashboard: AnyRecord | null }) {
  const totals = dashboard?.totals ?? {};
  return (
    <Space direction="vertical" size={18} className="full-width">
      <Row gutter={[16, 16]}>
        <Metric title="题库数量" value={totals.bankCount ?? 0} suffix="套" />
        <Metric title="题目总量" value={totals.questionCount ?? 0} suffix="题" />
        <Metric title="用户数量" value={totals.userCount ?? 0} suffix="人" />
        <Metric title="待处理反馈" value={totals.feedbackOpenCount ?? 0} suffix="条" />
      </Row>
      <Row gutter={[16, 16]}>
        <Col span={14}>
          <Card title="访问趋势" className="work-card">
            <div className="bar-list">
              {(dashboard?.appMetrics ?? []).slice(0, 7).map((item: AnyRecord) => (
                <div className="bar-row" key={item.id}>
                  <span>{formatDay(item.day)}</span>
                  <Progress
                    percent={Math.min(100, item.visits)}
                    showInfo={false}
                    strokeColor="#3b82f6"
                  />
                  <b>{item.visits}</b>
                </div>
              ))}
            </div>
          </Card>
        </Col>
        <Col span={10}>
          <Card title="销售概览" className="work-card">
            <Space direction="vertical" className="full-width">
              {(dashboard?.salesMetrics ?? []).slice(0, 5).map((item: AnyRecord) => (
                <div className="sales-row" key={item.id}>
                  <span>{formatDay(item.day)}</span>
                  <b>{item.orders} 单</b>
                  <Tag color="blue">¥{((item.amountFen ?? 0) / 100).toFixed(2)}</Tag>
                </div>
              ))}
            </Space>
          </Card>
        </Col>
      </Row>
    </Space>
  );
}

function BanksView({
  banks,
  selectedBank,
  catalog,
}: {
  banks: AnyRecord[];
  selectedBank?: AnyRecord;
  catalog: AnyRecord[];
}) {
  return (
    <Row gutter={[16, 16]}>
      <Col span={8}>
        <Card title="题库列表" className="work-card">
          <Table
            rowKey="id"
            dataSource={banks}
            pagination={false}
            columns={[
              { title: '题库', dataIndex: 'name' },
              { title: '题量', dataIndex: 'questionCount', width: 96 },
            ]}
          />
        </Card>
      </Col>
      <Col span={16}>
        <Card title="目录树" className="work-card">
          {selectedBank && (
            <Descriptions size="small" column={3} className="detail-strip">
              <Descriptions.Item label="题库">{selectedBank.name}</Descriptions.Item>
              <Descriptions.Item label="版本">{selectedBank.version}</Descriptions.Item>
              <Descriptions.Item label="科目">{selectedBank.subjects?.length ?? 0}</Descriptions.Item>
            </Descriptions>
          )}
          <Tree
            showLine
            defaultExpandAll={false}
            treeData={catalog.flatMap((subject) =>
              (subject.catalogs ?? []).map((node: AnyRecord) =>
                toTreeNode(node, subject.name),
              ),
            )}
          />
        </Card>
      </Col>
    </Row>
  );
}

function QuestionsView({
  questions,
  total,
  onSearch,
  onEdit,
}: {
  questions: AnyRecord[];
  total: number;
  onSearch: (keyword: string) => void | Promise<void>;
  onEdit: (record: AnyRecord) => void;
}) {
  return (
    <Card
      title={`题目维护 · 共 ${total} 题`}
      extra={
        <Input.Search
          allowClear
          placeholder="按题干关键词抽查"
          onSearch={(value) => void onSearch(value)}
          className="search-input"
        />
      }
      className="work-card"
    >
      <Table
        rowKey="id"
        dataSource={questions}
        pagination={false}
        columns={[
          {
            title: '题型',
            dataIndex: 'type',
            width: 120,
            render: (value) => <Tag>{value}</Tag>,
          },
          {
            title: '题干',
            dataIndex: 'stemText',
            ellipsis: true,
          },
          {
            title: '目录',
            dataIndex: ['catalogPath'],
            width: 220,
            render: (value, record) => value ?? record.catalog?.name ?? '-',
          },
          {
            title: '操作',
            width: 96,
            render: (_, record) => <Button type="link" onClick={() => onEdit(record)}>编辑</Button>,
          },
        ]}
      />
    </Card>
  );
}

function MaterialsView({
  materials,
  onCreate,
  onEdit,
  onDelete,
}: {
  materials: AnyRecord[];
  onCreate: () => void;
  onEdit: (record: AnyRecord) => void;
  onDelete: (record: AnyRecord) => void;
}) {
  return (
    <Card
      title="资料管理"
      extra={<Button type="primary" onClick={onCreate}>新增资料</Button>}
      className="work-card"
    >
      <Table
        rowKey="id"
        dataSource={materials}
        pagination={false}
        columns={[
          { title: '资料名称', dataIndex: 'title' },
          { title: '科目', dataIndex: 'subjectName', width: 160 },
          { title: '排序', dataIndex: 'sortOrder', width: 80 },
          {
            title: '权限',
            dataIndex: 'accessType',
            width: 100,
            render: (value) => <Tag color={value === 'free' ? 'green' : 'gold'}>{value}</Tag>,
          },
          { title: '类型', dataIndex: 'fileType', width: 96 },
          {
            title: '领取/预览',
            dataIndex: 'previewMeta',
            width: 110,
            render: (value) => `${value?.pages?.length ?? 0} 页`,
          },
          {
            title: '操作',
            width: 140,
            render: (_, record) => (
              <Space>
                <Button type="link" onClick={() => onEdit(record)}>编辑</Button>
                <Popconfirm
                  title="删除这份资料？"
                  description="删除后客户端将不再展示该资料。"
                  onConfirm={() => onDelete(record)}
                >
                  <Button type="link" danger>删除</Button>
                </Popconfirm>
              </Space>
            ),
          },
        ]}
      />
    </Card>
  );
}

function UsersView({
  users,
  onOpen,
}: {
  users: AnyRecord[];
  onOpen: (record: AnyRecord) => void;
}) {
  return (
    <Card title="用户查看" className="work-card">
      <Table
        rowKey="id"
        dataSource={users}
        pagination={false}
        columns={[
          { title: '昵称', dataIndex: 'nickname' },
          { title: '默认科目', dataIndex: 'defaultSubjectName', render: (value) => value ?? '-' },
          { title: '手机号', dataIndex: 'phone', render: (value) => value ?? '-' },
          {
            title: '练习记录',
            dataIndex: ['_count', 'practiceRecords'],
            width: 120,
          },
          {
            title: '考试记录',
            dataIndex: ['_count', 'examRecords'],
            width: 120,
          },
          {
            title: '错题',
            dataIndex: ['_count', 'wrongQuestions'],
            width: 100,
          },
          {
            title: '操作',
            width: 100,
            render: (_, record) => <Button type="link" onClick={() => onOpen(record)}>详情</Button>,
          },
        ]}
      />
    </Card>
  );
}

function FeedbackView({
  feedback,
  onStatus,
  onEditQuestion,
}: {
  feedback: AnyRecord[];
  onStatus: (id: string, status: string) => Promise<void>;
  onEditQuestion: (record: AnyRecord) => void;
}) {
  return (
    <Card title="错题反馈" className="work-card">
      <Table
        rowKey="id"
        dataSource={feedback}
        pagination={false}
        columns={[
          { title: '类型', dataIndex: 'type', width: 140 },
          { title: '内容', dataIndex: 'content' },
          {
            title: '状态',
            dataIndex: 'status',
            width: 120,
            render: (value) => <Tag color={feedbackStatusColor(value)}>{feedbackStatusText(value)}</Tag>,
          },
          {
            title: '题目',
            dataIndex: ['question', 'stemText'],
            ellipsis: true,
            render: (value, record) => value ?? record.questionId ?? '-',
          },
          {
            title: '目录',
            dataIndex: ['question', 'catalogPath'],
            width: 240,
            ellipsis: true,
            render: (value) => value ?? '-',
          },
          {
            title: '操作',
            width: 250,
            render: (_, record) => (
              <Space>
                <Button size="small" onClick={() => void onStatus(record.id, 'processing')}>
                  处理中
                </Button>
                <Button size="small" type="primary" onClick={() => void onStatus(record.id, 'resolved')}>
                  已解决
                </Button>
                <Button size="small" danger onClick={() => void onStatus(record.id, 'rejected')}>
                  驳回
                </Button>
                <Button size="small" disabled={!record.question} onClick={() => onEditQuestion(record)}>
                  改题
                </Button>
              </Space>
            ),
          },
        ]}
      />
    </Card>
  );
}

function AiView({
  aiModels,
  onCreate,
  onEdit,
}: {
  aiModels: AnyRecord[];
  onCreate: () => void;
  onEdit: (record: AnyRecord) => void;
}) {
  return (
    <Card
      title="AI 大模型配置"
      extra={<Button type="primary" onClick={onCreate}>新增模型</Button>}
      className="work-card"
    >
      <Table
        rowKey="id"
        dataSource={aiModels}
        pagination={false}
        columns={[
          { title: '名称', dataIndex: 'name' },
          { title: '供应商', dataIndex: 'provider', width: 160 },
          { title: '模型', dataIndex: 'model', width: 180 },
          {
            title: '状态',
            dataIndex: 'status',
            width: 110,
            render: (value) => <Tag color={value === 'enabled' ? 'green' : 'default'}>{value}</Tag>,
          },
          {
            title: '操作',
            width: 100,
            render: (_, record) => <Button type="link" onClick={() => onEdit(record)}>编辑</Button>,
          },
        ]}
      />
    </Card>
  );
}

function AppsView({ apps }: { apps: AnyRecord[] }) {
  return (
    <Card title="App 配置" className="work-card">
      <Table
        rowKey="id"
        dataSource={apps}
        pagination={false}
        columns={[
          { title: 'App Key', dataIndex: 'appKey' },
          { title: '名称', dataIndex: 'name' },
          { title: '平台', dataIndex: 'platform', width: 120 },
          { title: '包名', dataIndex: 'packageName' },
          { title: '题库', dataIndex: ['bank', 'name'], width: 180 },
        ]}
      />
    </Card>
  );
}

function MaterialForm({
  record,
  onSubmit,
}: {
  record?: AnyRecord;
  onSubmit: (values: AnyRecord) => Promise<void>;
}) {
  const previewPages = (record?.previewMeta?.pages ?? []).join('\n\n---\n\n');
  return (
    <Form
      layout="vertical"
      initialValues={record ? { ...record, previewPages } : { accessType: 'free', fileType: 'pdf', sortOrder: 0 }}
      onFinish={(values) => void onSubmit(values)}
    >
      <Form.Item name="title" label="资料名称" rules={[{ required: true }]}>
        <Input />
      </Form.Item>
      <Form.Item name="subjectName" label="适用科目">
        <Input placeholder="如 电气工程类" />
      </Form.Item>
      <Form.Item name="description" label="资料说明">
        <Input.TextArea rows={3} />
      </Form.Item>
      <Form.Item name="coverUrl" label="封面地址">
        <Input placeholder="可填写图片 URL，客户端用于资料封面展示" />
      </Form.Item>
      <Form.Item name="accessType" label="权限">
        <Select options={[{ label: '免费', value: 'free' }, { label: 'VIP', value: 'vip' }]} />
      </Form.Item>
      <Form.Item name="fileType" label="文件类型">
        <Select options={[{ label: 'PDF', value: 'pdf' }, { label: 'Word', value: 'docx' }, { label: '飞书链接', value: 'feishu' }]} />
      </Form.Item>
      <Form.Item name="fileUrl" label="资料地址">
        <Input placeholder="本地开发可先填写 URL 或对象存储地址" />
      </Form.Item>
      <Form.Item name="sortOrder" label="排序值">
        <Input type="number" />
      </Form.Item>
      <Form.Item name="previewPages" label="在线预览正文">
        <Input.TextArea rows={8} placeholder="多页内容用空行或 --- 分隔" />
      </Form.Item>
      <Button type="primary" htmlType="submit" block>
        保存资料
      </Button>
    </Form>
  );
}

function AiForm({
  record,
  onSubmit,
}: {
  record?: AnyRecord;
  onSubmit: (values: AnyRecord) => Promise<void>;
}) {
  return (
    <Form layout="vertical" initialValues={record ?? { status: 'disabled' }} onFinish={(values) => void onSubmit(values)}>
      <Form.Item name="name" label="配置名称" rules={[{ required: true }]}>
        <Input />
      </Form.Item>
      <Form.Item name="provider" label="供应商" rules={[{ required: true }]}>
        <Input placeholder="openai / custom-compatible / aliyun ..." />
      </Form.Item>
      <Form.Item name="model" label="模型名称" rules={[{ required: true }]}>
        <Input placeholder="如 gpt-5" />
      </Form.Item>
      <Form.Item name="endpoint" label="接口地址">
        <Input />
      </Form.Item>
      <Form.Item name="apiKeyAlias" label="密钥环境变量名">
        <Input placeholder="如 OPENAI_API_KEY" />
      </Form.Item>
      <Form.Item name="status" label="状态">
        <Select options={[{ label: '启用', value: 'enabled' }, { label: '停用', value: 'disabled' }]} />
      </Form.Item>
      <Button type="primary" htmlType="submit" block>
        保存配置
      </Button>
    </Form>
  );
}

function QuestionForm({
  record,
  onSubmit,
}: {
  record?: AnyRecord;
  onSubmit: (values: AnyRecord) => Promise<void>;
}) {
  if (!record) return <Empty description="暂无题目数据" />;
  return (
    <Form
      layout="vertical"
      initialValues={{
        stemText: record.stemText,
        analysisText: record.analysisText,
        answerJson: jsonString(record.answer),
        optionsJson: jsonString(record.options),
      }}
      onFinish={(values) => void onSubmit(values)}
    >
      <Descriptions size="small" column={1} className="detail-strip">
        <Descriptions.Item label="题目 ID">{record.id}</Descriptions.Item>
        <Descriptions.Item label="题型">{record.type}</Descriptions.Item>
        <Descriptions.Item label="目录">{record.catalogPath ?? record.catalog?.name ?? '-'}</Descriptions.Item>
      </Descriptions>
      <Form.Item name="stemText" label="题干文本" rules={[{ required: true }]}>
        <Input.TextArea rows={5} />
      </Form.Item>
      <Form.Item name="analysisText" label="解析文本">
        <Input.TextArea rows={4} />
      </Form.Item>
      <Form.Item name="answerJson" label="答案 JSON">
        <Input.TextArea rows={4} />
      </Form.Item>
      <Form.Item name="optionsJson" label="选项 JSON">
        <Input.TextArea rows={6} />
      </Form.Item>
      <Button type="primary" htmlType="submit" block>
        保存题目
      </Button>
    </Form>
  );
}

function UserDetailView({ detail }: { detail: AnyRecord | null }) {
  if (!detail) return <Empty description="正在加载用户详情" />;
  const user = detail.user ?? {};
  return (
    <Space direction="vertical" size={16} className="full-width">
      <Descriptions size="small" column={1} className="detail-strip">
        <Descriptions.Item label="用户 ID">{user.id}</Descriptions.Item>
        <Descriptions.Item label="昵称">{user.nickname ?? '-'}</Descriptions.Item>
        <Descriptions.Item label="手机号">{user.phone ?? '-'}</Descriptions.Item>
        <Descriptions.Item label="开发用户">{user.isDev ? '是' : '否'}</Descriptions.Item>
      </Descriptions>
      <Tabs
        items={[
          {
            key: 'practice',
            label: `练习记录 ${detail.practiceRecords?.length ?? 0}`,
            children: (
              <Table
                rowKey="id"
                size="small"
                dataSource={detail.practiceRecords ?? []}
                pagination={false}
                columns={[
                  { title: '题目/小节', dataIndex: 'questionTitle', ellipsis: true },
                  { title: '模式', dataIndex: 'mode', width: 120 },
                  {
                    title: '结果',
                    dataIndex: 'correct',
                    width: 90,
                    render: (value) =>
                      value == null ? '-' : <Tag color={value ? 'green' : 'red'}>{value ? '正确' : '错误'}</Tag>,
                  },
                  {
                    title: '时间',
                    dataIndex: 'createdAt',
                    width: 150,
                    render: formatDateTime,
                  },
                ]}
              />
            ),
          },
          {
            key: 'exam',
            label: `考试记录 ${detail.examRecords?.length ?? 0}`,
            children: (
              <Table
                rowKey="id"
                size="small"
                dataSource={detail.examRecords ?? []}
                pagination={false}
                columns={[
                  { title: '考试', dataIndex: 'title', ellipsis: true },
                  { title: '模式', dataIndex: 'mode', width: 120 },
                  {
                    title: '正确率',
                    dataIndex: 'accuracy',
                    width: 100,
                    render: (value) => (value == null ? '-' : `${formatNumber(value)}%`),
                  },
                  {
                    title: '时间',
                    dataIndex: 'createdAt',
                    width: 150,
                    render: formatDateTime,
                  },
                ]}
              />
            ),
          },
          {
            key: 'feedback',
            label: `反馈 ${detail.feedbacks?.length ?? 0}`,
            children: (
              <Table
                rowKey="id"
                size="small"
                dataSource={detail.feedbacks ?? []}
                pagination={false}
                columns={[
                  { title: '类型', dataIndex: 'type', width: 120 },
                  { title: '内容', dataIndex: 'content', ellipsis: true },
                  {
                    title: '状态',
                    dataIndex: 'status',
                    width: 100,
                    render: (value) => <Tag color={feedbackStatusColor(value)}>{feedbackStatusText(value)}</Tag>,
                  },
                  {
                    title: '时间',
                    dataIndex: 'createdAt',
                    width: 150,
                    render: formatDateTime,
                  },
                ]}
              />
            ),
          },
        ]}
      />
    </Space>
  );
}

function Metric({ title, value, suffix }: { title: string; value: number; suffix: string }) {
  return (
    <Col span={6}>
      <Card className="metric-card">
        <Statistic title={title} value={value} suffix={suffix} />
      </Card>
    </Col>
  );
}

function toTreeNode(node: AnyRecord, subjectName: string): AnyRecord {
  return {
    key: node.id,
    title: (
      <Space>
        <BranchesOutlined />
        <span>{node.name}</span>
        <Tag>{node.questionCount}题</Tag>
        {node.level === 2 && <Tag color="blue">{subjectName}</Tag>}
      </Space>
    ),
    children: (node.children ?? []).map((child: AnyRecord) =>
      toTreeNode(child, subjectName),
    ),
  };
}

function formatDay(value: string) {
  return new Date(value).toLocaleDateString('zh-CN', {
    month: '2-digit',
    day: '2-digit',
  });
}

function formatDateTime(value: string) {
  if (!value) return '-';
  return new Date(value).toLocaleString('zh-CN', {
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatNumber(value: unknown) {
  const number = Number(value);
  return Number.isFinite(number) ? Math.round(number) : 0;
}

function jsonString(value: unknown) {
  if (value == null) return '';
  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return String(value);
  }
}

function feedbackStatusText(value: string) {
  const map: Record<string, string> = {
    open: '待处理',
    processing: '处理中',
    resolved: '已解决',
    rejected: '已驳回',
  };
  return map[value] ?? value;
}

function feedbackStatusColor(value: string) {
  const map: Record<string, string> = {
    open: 'red',
    processing: 'blue',
    resolved: 'green',
    rejected: 'default',
  };
  return map[value] ?? 'default';
}

function drawerTitle(type: 'material' | 'ai' | 'question' | 'user' | null) {
  const map = {
    material: '资料信息',
    ai: 'AI 模型配置',
    question: '题目编辑',
    user: '用户详情',
  };
  return type ? map[type] : '';
}

export default App;

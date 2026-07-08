import { Button, Card, Layout, Menu, Space, Statistic, Typography } from 'antd';
import { apiClient } from './api/http';

const { Header, Sider, Content } = Layout;

const menuItems = [
  { key: 'banks', label: '题库管理' },
  { key: 'subjects', label: '科目目录' },
  { key: 'materials', label: '资料管理' },
  { key: 'apps', label: 'App 配置' },
  { key: 'users', label: '用户会员' },
];

function App() {
  const checkHealth = async () => {
    const response = await apiClient.get('/health');
    window.alert(`API 状态：${response.data.status}`);
  };

  return (
    <Layout className="app-shell">
      <Sider width={220} className="app-sider">
        <div className="brand">题库中台</div>
        <Menu mode="inline" defaultSelectedKeys={['banks']} items={menuItems} />
      </Sider>
      <Layout>
        <Header className="app-header">
          <Typography.Title level={4}>运营工作台</Typography.Title>
          <Button type="primary" onClick={checkHealth}>
            检查 API
          </Button>
        </Header>
        <Content className="app-content">
          <Space direction="vertical" size={16} className="full-width">
            <div>
              <Typography.Title level={3}>题库母版管理后台</Typography.Title>
              <Typography.Text type="secondary">
                这里会承载题库导入、目录维护、资料管理、用户会员和多 App 配置。
              </Typography.Text>
            </div>
            <div className="metric-grid">
              <Card>
                <Statistic title="题库数量" value={17} suffix="套" />
              </Card>
              <Card>
                <Statistic title="题目规模" value={28.8} suffix="万题" precision={1} />
              </Card>
              <Card>
                <Statistic title="资源分发" value="OSS/CDN" />
              </Card>
            </div>
          </Space>
        </Content>
      </Layout>
    </Layout>
  );
}

export default App;

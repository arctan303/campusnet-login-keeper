# 校园网自动认证脚本安装说明

## 快速安装

### 一键安装命令（推荐）

```bash
# 一行命令：下载、赋权、运行
curl -s https://arctan.top/github/install.sh -o /tmp/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh || curl -s http://arctan.top/github/install.sh -o /tmp/install.sh && chmod +x /tmp/install.sh && /tmp/install.sh
```

或者更简单的方式（直接运行，不保存文件）：

```bash
# 直接运行（推荐）
sh -c "$(curl -s https://arctan.top/github/install.sh)" || sh -c "$(curl -s http://arctan.top/github/install.sh)"
```

### 方法二：分步安装

```bash
# 下载安装脚本
curl -f -o install.sh https://arctan.top/github/install.sh || curl -f -o install.sh http://arctan.top/github/install.sh

# 如果下载失败，检查错误信息
if [ ! -f install.sh ]; then
    echo "下载失败，请检查网络连接"
    exit 1
fi

# 设置执行权限
chmod +x install.sh

# 运行安装脚本
./install.sh
```

### 方法二：使用 wget 下载

```bash
# 下载安装脚本
wget -O install.sh https://arctan.top/github/install.sh || wget -O install.sh http://arctan.top/github/install.sh

# 设置执行权限
chmod +x install.sh

# 运行安装脚本
./install.sh
```

### 方法三：手动下载（如果网络有问题）

1. 在浏览器中访问：`https://arctan.top/github/install.sh`
2. 保存文件到路由器的 `/tmp` 目录
3. 执行：
```bash
chmod +x /tmp/install.sh
/tmp/install.sh
```

## 安装步骤

1. **一键安装**：自动下载脚本、配置账号、设置自启动
2. **配置维护**：修改账号密码、登录方式等
3. **测试运行**：测试登录功能
4. **查看日志**：查看运行日志

## 配置文件位置

- 配置文件：`/data/school_net/config.conf`
- 登录脚本：`/data/school_net/campus_login.sh`
- 保活脚本：`/data/school_net/keepalive.sh`
- 日志文件：`/tmp/campus_login.log`

## 常见问题

### 1. 下载失败
- 检查网络连接
- 尝试使用 HTTP 协议（如果 HTTPS 失败）
- 检查防火墙设置

### 2. 权限问题
- 确保使用 root 用户运行
- 检查文件权限：`ls -l install.sh`

### 3. 脚本无法执行
- 检查脚本格式：`file install.sh`
- 修复格式：`sed -i 's/\r$//' install.sh`
- 重新设置权限：`chmod +x install.sh`


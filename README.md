# Dr.COM 广州热点校园网自动登录、保活脚本

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

适用于 Dr.COM 广州热点校园网的自动登录和保活脚本，支持路由器和 Linux 系统。

## 功能特性

- 🚀 自动登录校园网
- 🔄 自动保活，防止掉线
- ⚙️ 一键安装配置
- 📝 详细日志记录
- 🔧 支持多种登录方式
- 💾 配置持久化保存

## 快速安装

### 方法一：一键安装（推荐）

使用 GitHub 源（推荐）：

```bash
# 直接运行安装脚本
sh -c "$(curl -fsSL https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh)"
```

或使用备用源：

```bash
# 使用网站源（备用）
sh -c "$(curl -fsSL https://arctan.top/github/install.sh)" || sh -c "$(curl -fsSL http://arctan.top/github/install.sh)"
```

### 方法二：分步安装

从 GitHub 下载：

```bash
# 下载安装脚本
curl -fsSL -o install.sh https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh

# 设置执行权限
chmod +x install.sh

# 运行安装脚本
./install.sh
```

从备用源下载：

```bash
# 下载安装脚本
curl -fsSL -o install.sh https://arctan.top/github/install.sh || curl -fsSL -o install.sh http://arctan.top/github/install.sh

# 设置执行权限
chmod +x install.sh

# 运行安装脚本
./install.sh
```

### 方法三：使用 wget

```bash
# 从 GitHub 下载
wget -O install.sh https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh

# 或从备用源下载
wget -O install.sh https://arctan.top/github/install.sh || wget -O install.sh http://arctan.top/github/install.sh

# 设置执行权限并运行
chmod +x install.sh && ./install.sh
```


## 使用说明

### 安装后配置

安装脚本会自动完成以下操作：

1. 下载登录和保活脚本
2. 引导配置账号密码
3. 设置系统自启动
4. 启动保活服务

### 手动配置

如需修改配置，编辑配置文件：

```bash
vi /data/school_net/config.conf
```

配置项说明：

```bash
USERNAME="你的学号"          # 校园网账号
PASSWORD="你的密码"          # 校园网密码
LOGIN_TYPE="1"              # 登录方式：1-PC 2-移动设备
CHECK_INTERVAL="60"         # 保活检测间隔（秒）
```

### 手动控制

```bash
# 测试登录
/data/school_net/campus_login.sh

# 启动保活服务
/data/school_net/keepalive.sh &

# 查看运行日志
tail -f /tmp/campus_login.log

# 停止保活服务
killall keepalive.sh
```

## 文件说明

| 文件路径 | 说明 |
|---------|------|
| `/data/school_net/config.conf` | 配置文件（账号密码等） |
| `/data/school_net/campus_login.sh` | 登录脚本 |
| `/data/school_net/keepalive.sh` | 保活脚本 |
| `/tmp/campus_login.log` | 运行日志 |

## 常见问题

### 下载失败

**问题**：无法下载安装脚本

**解决方案**：
- 检查网络连接是否正常
- 尝试使用备用源（网站源）
- 如果 GitHub 访问困难，使用 `https://arctan.top/github/install.sh`
- 检查防火墙设置

### 权限问题

**问题**：提示权限不足

**解决方案**：
```bash
# 确保使用 root 用户运行
sudo su

# 检查文件权限
ls -l install.sh

# 重新设置权限
chmod +x install.sh
```

### 脚本无法执行

**问题**：脚本下载后无法运行

**解决方案**：
```bash
# 检查脚本格式
file install.sh

# 修复 Windows 换行符问题
sed -i 's/\r$//' install.sh

# 重新设置权限
chmod +x install.sh
```

### 登录失败

**问题**：脚本运行但无法登录

**解决方案**：
- 检查账号密码是否正确
- 确认登录方式（LOGIN_TYPE）是否正确
- 查看日志文件：`cat /tmp/campus_login.log`
- 手动测试登录：`/data/school_net/campus_login.sh`

### 保活服务未启动

**问题**：安装后仍然掉线

**解决方案**：
```bash
# 检查保活进程是否运行
ps | grep keepalive

# 手动启动保活服务
/data/school_net/keepalive.sh &

# 检查系统自启动配置
cat /etc/rc.local
```

## 卸载

如需卸载脚本：

```bash
# 停止保活服务
killall keepalive.sh

# 删除脚本文件
rm -rf /data/school_net

# 移除自启动配置（根据实际情况修改）
# 编辑 /etc/rc.local 或相应的启动脚本，删除相关行
```

## 支持的系统

- ✅ OpenWrt 路由器
- ✅ Linux 系统（Debian/Ubuntu/CentOS 等）
- ✅ 其他支持 Bash 的 Unix-like 系统

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关链接

- 项目主页：[GitHub](https://github.com/arctan303/campusnet-login-keeper)
- 备用下载：[https://arctan.top/github/](https://arctan.top/github/)

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

---

**注意**：本脚本仅供学习交流使用，请遵守学校网络使用规定。

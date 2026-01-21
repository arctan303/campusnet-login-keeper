# CampusNet Login Keeper（校园网自动认证/保活脚本）

一个用于 **校园网自动登录**、**掉线自动重连**、可配合 **systemd/cron** 长期运行的脚本集合。

仓库地址：<https://github.com/arctan303/campusnet-login-keeper>

---

## 特性

- ✅ 自动认证登录（账号密码）
- ✅ 断网/掉线自动检测并重连
- ✅ 日志记录，便于排查
- ✅ 可选自启动（systemd / cron，视脚本实现）
- ✅ 适用于 Linux / 路由器 OpenWrt（如脚本支持）

---

## 快速开始

### 1）一键运行（推荐）

> 直接从 GitHub RAW 拉取并执行 `install.sh`  
> **注意：执行前请确认你信任该仓库脚本。**

#### 方式 A：下载到本地再执行（更稳、更好排查）

```bash
# 下载
curl -fL -o /tmp/install.sh https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh \
  || wget -O /tmp/install.sh https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh

# 赋权 + 执行
chmod +x /tmp/install.sh
sudo /tmp/install.sh

````

#### 方式 B：不落盘，直接执行（更简洁）

```bash
# curl 方式
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh)"

# 或 wget 方式
sudo sh -c "$(wget -qO- https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh)"
```

---

### 2）国内网络备用源（可选）

> 如果你所在网络访问 `raw.githubusercontent.com` 不稳定，可尝试下面备用（不保证长期可用）。

#### 备用 1：ghproxy（示例）

```bash
sudo sh -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/arctan303/campusnet-login-keeper/main/install.sh)"
```

#### 备用 2：fastgit（示例）

```bash
sudo sh -c "$(curl -fsSL https://raw.fastgit.org/arctan303/campusnet-login-keeper/main/install.sh)"
```

---

## 安装后文件位置（以 install.sh 实际行为为准）

> 下面是“建议结构”。如果你的 install.sh 已经固定了目录，请以脚本为准并把此处改成一致。

常见约定例如：

* 配置文件：`/data/school_net/config.conf`
* 登录脚本：`/data/school_net/campus_login.sh`
* 保活脚本：`/data/school_net/keepalive.sh`
* 日志文件：`/tmp/campus_login.log`

---

## 配置说明

安装完成后一般需要配置账号密码/认证地址等（示例）：

```bash
sudo nano /data/school_net/config.conf
```

常见配置项示例（仅示意，按你的脚本实际字段调整）：

```conf
USERNAME="你的账号"
PASSWORD="你的密码"
# LOGIN_URL="http://xxx/login"
# CHECK_URL="https://www.baidu.com"
```

---

## 运行与测试

### 手动运行（测试用）

```bash
# 登录脚本（示例）
sudo /data/school_net/campus_login.sh

# 保活脚本（示例）
sudo /data/school_net/keepalive.sh
```

### 查看日志

```bash
tail -n 200 /tmp/campus_login.log
```

---


### systemd（推荐，Linux）

> 以下仅为模板。服务文件/路径请按你项目实际脚本路径修改。

创建服务文件：

```bash
sudo tee /etc/systemd/system/campusnet-login-keeper.service >/dev/null <<'EOF'
[Unit]
Description=CampusNet Login Keeper
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/data/school_net/keepalive.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

启动并设置开机自启：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now campusnet-login-keeper
sudo systemctl status campusnet-login-keeper --no-pager
```

---

## 卸载


```bash
sudo systemctl disable --now campusnet-login-keeper 2>/dev/null || true
sudo rm -f /etc/systemd/system/campusnet-login-keeper.service
sudo systemctl daemon-reload

sudo rm -rf /data/school_net
sudo rm -f /tmp/campus_login.log
```

---

## 常见问题（FAQ）

### 1. 下载失败 / 连接 raw 失败

* 尝试上面的 “国内备用源”
* 或换 DNS / 换网络
* 确认系统时间正确（HTTPS 证书验证会受影响）

### 2. 权限问题

请使用 root 或 sudo：

```bash
sudo /tmp/install.sh
```

### 3. 脚本提示 `^M` / 无法执行

可能是 Windows 换行符导致，修复：

```bash
sed -i 's/\r$//' /tmp/install.sh
chmod +x /tmp/install.sh
```

---

## License

MIT（如果你仓库不是 MIT，改成实际许可证）

```

---

### 我还可以顺手帮你把 README 做到“完全贴合脚本”
现在我只能按“常见 install.sh 行为”写模板。你把仓库里的 **install.sh / keepalive.sh / config 示例**贴出来（或把文件发我），我可以把 README 里这些地方改成**100% 对应你的真实路径、参数名、systemd 服务名、日志位置**。
```


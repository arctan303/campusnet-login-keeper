#!/bin/sh

# 使用方法: ./campus_login.sh [pc|mobile]
# 默认: mobile
MODE=${1:-mobile}

BASE_URL="http://1.1.1.1:801/eportal/portal/login"

# ================= 配置读取 =================
SCRIPT_DIR="/data/school_net"
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# 读取配置文件（如果存在）
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
fi

# ================= 账号配置 =================

# 从配置文件读取账号（手机和PC共用）
LOGIN_ACCOUNT_NUM=${LOGIN_ACCOUNT:-""}
LOGIN_PASSWORD=${LOGIN_PASS:-""}

# --- 移动端/手机模式 (推荐, 账号前缀 ,1,) ---
MOBILE_ACCOUNT=",1,${LOGIN_ACCOUNT_NUM}"
MOBILE_PASS="${LOGIN_PASSWORD}"
MOBILE_TYPE="2"
MOBILE_V="3387"
MOBILE_UA="Mozilla/5.0 (Linux; Android 13; SM-S9080) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"

# --- PC/电脑模式 (账号前缀 ,0,) ---
PC_ACCOUNT=",0,${LOGIN_ACCOUNT_NUM}"
PC_PASS="${LOGIN_PASSWORD}"
PC_TYPE="1"
PC_V="7169"
PC_UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ================= 逻辑处理 =================

# 检查账号和密码是否配置
if [ -z "$LOGIN_ACCOUNT_NUM" ] || [ -z "$LOGIN_PASSWORD" ]; then
    echo "错误: 账号或密码未配置，请先运行安装脚本进行配置"
    exit 1
fi

if [ "$MODE" = "pc" ]; then
    ACCOUNT=$PC_ACCOUNT
    PASSWORD=$PC_PASS
    TYPE=$PC_TYPE
    V_CODE=$PC_V
    UA=$PC_UA
    echo ">>> 正在执行 PC 模式登录..."
else
    ACCOUNT=$MOBILE_ACCOUNT
    PASSWORD=$MOBILE_PASS
    TYPE=$MOBILE_TYPE
    V_CODE=$MOBILE_V
    UA=$MOBILE_UA
    echo ">>> 正在执行 移动/手机 模式登录..."
fi

# 1. 自动获取本机IP (智能版)
# 不需要指定网口，自动查询去往 1.1.1.1 时会用哪个本机IP
CURRENT_IP=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')

if [ -z "$CURRENT_IP" ]; then
    echo "错误: 无法获取本机IP，请检查网线是否连接。"
    exit 1
fi

echo "    当前IP: $CURRENT_IP"

# 2. 发送请求 (不绑定接口，由系统路由决定)
URL="${BASE_URL}?callback=dr1003&login_method=1&user_account=${ACCOUNT}&user_password=${PASSWORD}&wlan_user_ip=${CURRENT_IP}&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.2.1&terminal_type=${TYPE}&lang=zh-cn&v=${V_CODE}"

RESULT=$(curl --user-agent "$UA" --connect-timeout 5 -s "$URL")

# 3. 输出结果
if echo "$RESULT" | grep -qE '"result":"1"|"success"'; then
    echo ">>> 登录成功！"
else
    echo ">>> 登录返回: $RESULT"
fi
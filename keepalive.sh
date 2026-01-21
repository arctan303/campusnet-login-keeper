#!/bin/sh

# ================= 配置区域 =================
# 脚本所在目录 (小米路由器持久化目录)
SCRIPT_DIR="/data/school_net"
CONFIG_FILE="$SCRIPT_DIR/config.conf"
LOGIN_SCRIPT="$SCRIPT_DIR/campus_login.sh"
LOG_FILE="/tmp/campus_login.log"

# 读取配置文件（如果存在）
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
fi

# -------------------------------------------
# [关键设置] 选择登录模式
# 可选值: mobile (联通/手机) 或 pc (电信/电脑)
# 如果配置文件中没有设置，使用默认值
LOGIN_MODE=${LOGIN_MODE:-"mobile"}
# -------------------------------------------

# [修改点] 检测目标: www.baidu.com
# 理由: 日志证明 1.1.1.1 和 223.5.5.5 在未登录时也能Ping通(白名单)。
# 只有百度无法访问，说明只有 Ping 百度才能真实反映网络状态。
CHECK_TARGET="www.baidu.com"

# 日志最大行数
MAX_LOG_LINES=1000
# ===========================================

# 日志清理逻辑
if [ -f "$LOG_FILE" ] && [ $(wc -l < "$LOG_FILE") -gt $MAX_LOG_LINES ]; then
    tail -n 50 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

# 检测网络 (-c 3: Ping 3次; -W 5: 稍微加长超时时间，防止DNS解析慢)
# 使用域名检测，如果DNS解析失败或Ping不通，都会触发重连
if ping -c 3 -W 5 "$CHECK_TARGET" > /dev/null 2>&1; then
    # 网络通畅，什么都不做
    exit 0
else
    echo "[$(date '+%H:%M:%S')] 无法访问互联网($CHECK_TARGET)，判断为断网！正在重连 ($LOGIN_MODE)..." >> "$LOG_FILE"
    
    if [ -f "$LOGIN_SCRIPT" ]; then
        # 调用登录脚本
        /bin/sh "$LOGIN_SCRIPT" "$LOGIN_MODE" >> "$LOG_FILE" 2>&1
    else
        echo "错误: 找不到登录脚本 $LOGIN_SCRIPT" >> "$LOG_FILE"
    fi
fi
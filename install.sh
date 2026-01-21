#!/bin/sh

# ================= 配置区域 =================
SCRIPT_DIR="/data/school_net"
CONFIG_FILE="$SCRIPT_DIR/config.conf"
LOGIN_SCRIPT="$SCRIPT_DIR/campus_login.sh"
KEEPALIVE_SCRIPT="$SCRIPT_DIR/keepalive.sh"
LOG_FILE="/tmp/campus_login.log"

# 默认使用 GitHub 源，传入 backup 参数使用备用源
# 使用方法: 
#   从 GitHub: sh install.sh
#   从备用源: sh install.sh backup
if [ "$1" = "backup" ]; then
    BASE_DOMAIN="arctan.top/share/scripts/campus"
    echo "[信息] 使用备用源: $BASE_DOMAIN"
else
    BASE_DOMAIN="raw.githubusercontent.com/arctan303/campusnet-login-keeper/main"
fi
# ===========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 读取配置文件
read_config() {
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi
}

# 写入配置文件
write_config() {
    cat > "$CONFIG_FILE" << EOF
# 校园网自动认证配置文件
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

# 登录账号（只填写数字部分，手机和PC共用）
LOGIN_ACCOUNT="${LOGIN_ACCOUNT:-}"
LOGIN_PASS="${LOGIN_PASS:-}"

# 默认登录模式: mobile 或 pc
LOGIN_MODE="${LOGIN_MODE:-mobile}"

# 检测间隔（分钟）
CHECK_INTERVAL="${CHECK_INTERVAL:-5}"

# 是否启用自启动: yes 或 no
AUTO_START="${AUTO_START:-yes}"
EOF
}

# 下载脚本文件
download_scripts() {
    print_info "正在下载脚本文件..."
    
    # 创建目录
    mkdir -p "$SCRIPT_DIR"
    
    # 尝试 HTTPS，失败则使用 HTTP
    for protocol in https http; do
        print_info "尝试使用 $protocol 协议下载..."
        
        # 下载 campus_login.sh
        if curl -s -f "${protocol}://${BASE_DOMAIN}/campus_login.sh" -o "$LOGIN_SCRIPT.tmp" 2>/dev/null; then
            mv "$LOGIN_SCRIPT.tmp" "$LOGIN_SCRIPT"
            print_success "campus_login.sh 下载成功"
        else
            print_error "campus_login.sh 下载失败"
            continue
        fi
        
        # 下载 keepalive.sh
        if curl -s -f "${protocol}://${BASE_DOMAIN}/keepalive.sh" -o "$KEEPALIVE_SCRIPT.tmp" 2>/dev/null; then
            mv "$KEEPALIVE_SCRIPT.tmp" "$KEEPALIVE_SCRIPT"
            print_success "keepalive.sh 下载成功"
        else
            print_error "keepalive.sh 下载失败"
            continue
        fi
        
        # 修复格式和权限
        sed -i 's/\r$//' "$LOGIN_SCRIPT" 2>/dev/null || sed -i '' 's/\r$//' "$LOGIN_SCRIPT" 2>/dev/null
        sed -i 's/\r$//' "$KEEPALIVE_SCRIPT" 2>/dev/null || sed -i '' 's/\r$//' "$KEEPALIVE_SCRIPT" 2>/dev/null
        chmod +x "$LOGIN_SCRIPT"
        chmod +x "$KEEPALIVE_SCRIPT"
        
        print_success "脚本文件下载完成"
        return 0
    done
    
    print_error "所有协议下载均失败"
    return 1
}

# 配置账号信息
setup_accounts() {
    print_info "开始配置账号信息..."
    
    echo ""
    read -p "登录账号（只输入数字部分）: " login_account
    if [ -z "$login_account" ]; then
        print_warning "登录账号为空，跳过"
    else
        LOGIN_ACCOUNT="$login_account"
    fi
    
    echo ""
    read -sp "登录密码: " login_pass
    echo ""
    if [ -z "$login_pass" ]; then
        print_warning "登录密码为空，跳过"
    else
        LOGIN_PASS="$login_pass"
    fi
    
    echo ""
    echo "请选择默认登录方式："
    echo "1) mobile (手机/联通模式，推荐)"
    echo "2) pc (电脑/电信模式)"
    read -p "请选择 [1-2] (默认: 1): " login_choice
    case "$login_choice" in
        2) LOGIN_MODE="pc" ;;
        *) LOGIN_MODE="mobile" ;;
    esac
    
    echo ""
    read -p "请输入检测间隔（分钟，默认: 5）: " interval
    if [ -z "$interval" ]; then
        CHECK_INTERVAL=5
    else
        CHECK_INTERVAL="$interval"
    fi
    
    write_config
    print_success "账号配置完成"
}

# 设置自启动
# 参数: $1 - 如果提供，则跳过交互，直接使用配置文件中的 AUTO_START 值
setup_autostart() {
    if [ -z "$1" ]; then
        print_info "配置自启动..."
        read -p "是否启用自启动？[Y/n] (默认: Y): " enable_auto
        case "$enable_auto" in
            [Nn]*) AUTO_START="no" ;;
            *) AUTO_START="yes" ;;
        esac
        write_config
    else
        # 从配置文件读取
        read_config
    fi
    
    if [ "$AUTO_START" = "yes" ]; then
        # 检查 crontab 是否已存在
        crontab -l 2>/dev/null | grep -q "$KEEPALIVE_SCRIPT"
        if [ $? -eq 0 ]; then
            print_warning "自启动任务已存在，正在更新..."
            # 删除旧任务
            crontab -l 2>/dev/null | grep -v "$KEEPALIVE_SCRIPT" | crontab - 2>/dev/null
        fi
        
        # 添加新任务
        read_config
        INTERVAL=${CHECK_INTERVAL:-5}
        (crontab -l 2>/dev/null; echo "*/${INTERVAL} * * * * /bin/sh $KEEPALIVE_SCRIPT > /dev/null 2>&1") | crontab -
        print_success "自启动已设置，每 ${INTERVAL} 分钟检测一次"
    else
        # 删除自启动任务
        crontab -l 2>/dev/null | grep -v "$KEEPALIVE_SCRIPT" | crontab - 2>/dev/null
        print_success "自启动已取消"
    fi
}

# 一键安装
install_all() {
    print_info "开始一键安装..."
    
    # 下载脚本
    if ! download_scripts; then
        print_error "脚本下载失败，安装中止"
        return 1
    fi
    
    # 配置账号
    setup_accounts
    
    # 设置自启动
    setup_autostart
    
    print_success "安装完成！"
    echo ""
    print_info "配置文件位置: $CONFIG_FILE"
    print_info "登录脚本位置: $LOGIN_SCRIPT"
    print_info "保活脚本位置: $KEEPALIVE_SCRIPT"
    print_info "日志文件位置: $LOG_FILE"
}

# 配置维护
maintain_config() {
    read_config
    
    while true; do
        echo ""
        echo "========== 配置维护 =========="
        echo "1) 修改登录账号密码"
        echo "2) 修改登录方式"
        echo "3) 修改检测间隔"
        echo "4) 启用/取消自启动"
        echo "5) 查看当前配置"
        echo "0) 返回主菜单"
        echo "=============================="
        read -p "请选择 [0-5]: " choice
        
        case "$choice" in
            1)
                echo ""
                read -p "登录账号 (当前: ${LOGIN_ACCOUNT:-未设置}): " login_account
                if [ -n "$login_account" ]; then
                    LOGIN_ACCOUNT="$login_account"
                fi
                read -sp "登录密码: " login_pass
                echo ""
                if [ -n "$login_pass" ]; then
                    LOGIN_PASS="$login_pass"
                fi
                write_config
                print_success "登录账号密码已更新"
                ;;
            2)
                echo ""
                echo "当前登录方式: ${LOGIN_MODE:-mobile}"
                echo "1) mobile (手机/联通模式)"
                echo "2) pc (电脑/电信模式)"
                read -p "请选择 [1-2]: " login_choice
                case "$login_choice" in
                    2) LOGIN_MODE="pc" ;;
                    *) LOGIN_MODE="mobile" ;;
                esac
                write_config
                print_success "登录方式已更新为: $LOGIN_MODE"
                ;;
            3)
                echo ""
                read -p "检测间隔（分钟，当前: ${CHECK_INTERVAL:-5}）: " interval
                if [ -n "$interval" ]; then
                    CHECK_INTERVAL="$interval"
                    write_config
                    print_success "检测间隔已更新为: ${CHECK_INTERVAL} 分钟"
                    print_warning "需要重新设置自启动才能生效"
                fi
                ;;
            4)
                echo ""
                echo "当前自启动状态: ${AUTO_START:-yes}"
                read -p "是否启用自启动？[Y/n]: " enable_auto
                case "$enable_auto" in
                    [Nn]*) AUTO_START="no" ;;
                    *) AUTO_START="yes" ;;
                esac
                write_config
                setup_autostart skip_interactive
                ;;
            5)
                echo ""
                echo "========== 当前配置 =========="
                echo "登录账号: ${LOGIN_ACCOUNT:-未设置}"
                echo "登录密码: ${LOGIN_PASS:+已设置}"
                echo "登录方式: ${LOGIN_MODE:-mobile}"
                echo "检测间隔: ${CHECK_INTERVAL:-5} 分钟"
                echo "自启动: ${AUTO_START:-yes}"
                echo "=============================="
                ;;
            0)
                break
                ;;
            *)
                print_error "无效选择"
                ;;
        esac
    done
}

# 测试运行
test_login() {
    read_config
    
    if [ ! -f "$LOGIN_SCRIPT" ]; then
        print_error "登录脚本不存在，请先执行一键安装"
        return 1
    fi
    
    echo ""
    echo "========== 测试登录 =========="
    echo "1) 测试手机模式登录"
    echo "2) 测试PC模式登录"
    echo "0) 返回主菜单"
    echo "=============================="
    read -p "请选择 [0-2]: " choice
    
    case "$choice" in
        1)
            print_info "正在测试手机模式登录..."
            /bin/sh "$LOGIN_SCRIPT" mobile
            ;;
        2)
            print_info "正在测试PC模式登录..."
            /bin/sh "$LOGIN_SCRIPT" pc
            ;;
        0)
            return
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
}

# 查看日志
view_log() {
    if [ ! -f "$LOG_FILE" ]; then
        print_warning "日志文件不存在，可能还没有断线记录"
        return
    fi
    
    echo ""
    echo "========== 日志内容 =========="
    echo "（按 Ctrl+C 退出实时查看）"
    echo "=============================="
    tail -f "$LOG_FILE"
}

# 主菜单
main_menu() {
    while true; do
        echo ""
        echo "=========================================="
        echo "    校园网自动认证脚本管理工具"
        echo "=========================================="
        echo "1) 一键安装"
        echo "2) 配置维护"
        echo "3) 测试运行"
        echo "4) 查看日志"
        echo "0) 退出"
        echo "=========================================="
        read -p "请选择 [0-4]: " choice
        
        case "$choice" in
            1)
                install_all
                ;;
            2)
                maintain_config
                ;;
            3)
                test_login
                ;;
            4)
                view_log
                ;;
            0)
                print_info "再见！"
                exit 0
                ;;
            *)
                print_error "无效选择，请重新输入"
                ;;
        esac
    done
}

# 主程序入口
main() {
    # 检查是否为 root 用户（某些操作需要 root 权限）
    if [ "$(id -u)" -ne 0 ]; then
        print_warning "建议使用 root 权限运行此脚本"
    fi
    
    main_menu
}

# 运行主程序
main


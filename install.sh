#!/bin/bash

# Archive Tool 安装脚本
# 用法: sudo ./install.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印彩色消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then 
    print_warning "建议使用root权限运行安装脚本"
    read -p "继续安装? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    # 检查gcc
    if ! command -v gcc &> /dev/null; then
        print_error "未找到gcc编译器"
        print_info "正在安装gcc..."
        if [ -x "$(command -v apt-get)" ]; then
            apt-get update && apt-get install -y gcc
        elif [ -x "$(command -v yum)" ]; then
            yum install -y gcc
        elif [ -x "$(command -v dnf)" ]; then
            dnf install -y gcc
        elif [ -x "$(command -v pacman)" ]; then
            pacman -S --noconfirm gcc
        else
            print_error "无法自动安装gcc，请手动安装"
            exit 1
        fi
    fi
    
    # 检查make
    if ! command -v make &> /dev/null; then
        print_info "正在安装make..."
        if [ -x "$(command -v apt-get)" ]; then
            apt-get install -y make
        elif [ -x "$(command -v yum)" ]; then
            yum install -y make
        elif [ -x "$(command -v dnf)" ]; then
            dnf install -y make
        elif [ -x "$(command -v pacman)" ]; then
            pacman -S --noconfirm make
        fi
    fi
    
    # 检查zlib开发库
    print_info "检查zlib开发库..."
    if [ ! -f /usr/include/zlib.h ]; then
        print_info "正在安装zlib开发库..."
        if [ -x "$(command -v apt-get)" ]; then
            apt-get install -y zlib1g-dev
        elif [ -x "$(command -v yum)" ]; then
            yum install -y zlib-devel
        elif [ -x "$(command -v dnf)" ]; then
            dnf install -y zlib-devel
        elif [ -x "$(command -v pacman)" ]; then
            pacman -S --noconfirm zlib
        fi
    fi
    
    # 检查OpenSSL开发库
    print_info "检查OpenSSL开发库..."
    if [ ! -f /usr/include/openssl/ssl.h ]; then
        print_info "正在安装OpenSSL开发库..."
        if [ -x "$(command -v apt-get)" ]; then
            apt-get install -y libssl-dev
        elif [ -x "$(command -v yum)" ]; then
            yum install -y openssl-devel
        elif [ -x "$(command -v dnf)" ]; then
            dnf install -y openssl-devel
        elif [ -x "$(command -v pacman)" ]; then
            pacman -S --noconfirm openssl
        fi
    fi
}

# 编译源代码
compile_source() {
    print_info "开始编译归档库..."
    
    # 编译静态库
    make static
    if [ $? -ne 0 ]; then
        print_error "编译静态库失败"
        exit 1
    fi
    
    # 编译动态库
    make
    if [ $? -ne 0 ]; then
        print_error "编译动态库失败"
        exit 1
    fi
    
    # 编译命令行工具
    print_info "编译命令行工具..."
    gcc -Wall -Wextra -O2 -std=c99 -o archive archive-tool.c -L. -larchive -lz -lcrypto -lm
    if [ $? -ne 0 ]; then
        print_error "编译命令行工具失败"
        exit 1
    fi
}

# 安装到系统
install_to_system() {
    print_info "开始安装到系统..."
    
    # 创建必要的目录
    mkdir -p /usr/local/include
    mkdir -p /usr/local/lib
    mkdir -p /usr/local/bin
    mkdir -p /usr/local/share/man/man1
    
    # 安装头文件
    print_info "安装头文件..."
    cp archive.h /usr/local/include/
    chmod 644 /usr/local/include/archive.h
    
    # 安装库文件
    print_info "安装库文件..."
    
    # 安装静态库
    if [ -f libarchive.a ]; then
        cp libarchive.a /usr/local/lib/
        chmod 644 /usr/local/lib/libarchive.a
    fi
    
    # 安装动态库
    if [ -f libarchive.so ]; then
        cp libarchive.so /usr/local/lib/libarchive.so.1.0.0
        chmod 755 /usr/local/lib/libarchive.so.1.0.0
        ln -sf /usr/local/lib/libarchive.so.1.0.0 /usr/local/lib/libarchive.so.1
        ln -sf /usr/local/lib/libarchive.so.1.0.0 /usr/local/lib/libarchive.so
    elif [ -f libarchive.dylib ]; then
        cp libarchive.dylib /usr/local/lib/libarchive.1.0.0.dylib
        chmod 755 /usr/local/lib/libarchive.1.0.0.dylib
        ln -sf /usr/local/lib/libarchive.1.0.0.dylib /usr/local/lib/libarchive.1.dylib
        ln -sf /usr/local/lib/libarchive.1.0.0.dylib /usr/local/lib/libarchive.dylib
    fi
    
    # 安装命令行工具
    print_info "安装命令行工具..."
    cp archive /usr/local/bin/
    chmod 755 /usr/local/bin/archive
    
    # 创建man手册
    print_info "创建man手册..."
    cat > /usr/local/share/man/man1/archive.1 << 'EOF'
.\" Archive Tool Man Page
.TH ARCHIVE 1 "2024-01-01" "v1.0.0" "Archive Tool Manual"
.SH NAME
archive \- file archiving utility with compression and encryption
.SH SYNOPSIS
.B archive
[\fICOMMAND\fR] [\fIOPTIONS\fR] [\fIARGUMENTS\fR]
.SH DESCRIPTION
Archive Tool is a powerful command-line utility for creating, extracting,
and managing archive files with support for compression and encryption.
.SH COMMANDS
.TP
\fBcreate, c\fR
Create a new archive
.TP
\fBextract, x\fR
Extract files from an archive
.TP
\fBlist, l\fR
List contents of an archive
.TP
\fBadd, a\fR
Add files to an existing archive
.TP
\fBremove, r\fR
Remove files from an archive
.TP
\fBverify, v\fR
Verify integrity of an archive
.TP
\fBupdate, u\fR
Update files in an archive
.TP
\fBtest, t\fR
Test archive file integrity
.TP
\fBhelp, h\fR
Show help message
.TP
\fBversion, V\fR
Show version information
.SH OPTIONS
.TP
\fB-v, --verbose\fR
Verbose output
.TP
\fB-q, --quiet\fR
Quiet mode (no output)
.TP
\fB-c, --compression N\fR
Compression level (0-9, default: 6)
.TP
\fB-p, --password PASS\fR
Password for encryption
.TP
\fB-n, --no-progress\fR
Disable progress display
.SH EXAMPLES
Create an archive:
.B archive create backup.arc file1.txt file2.txt
.PP
Extract an archive:
.B archive extract backup.arc
.PP
List archive contents:
.B archive list backup.arc
.SH SEE ALSO
.BR tar (1),
.BR zip (1),
.BR gzip (1)
.SH AUTHOR
Archive Tool Team
.SH COPYRIGHT
Copyright © 2024 Archive Tool Team
EOF
    
    # 更新动态链接器缓存
    print_info "更新动态链接器缓存..."
    if command -v ldconfig &> /dev/null; then
        ldconfig
    fi
    
    # 更新man数据库
    if command -v mandb &> /dev/null; then
        mandb
    fi
}

# 创建卸载脚本
create_uninstaller() {
    print_info "创建卸载脚本..."
    
    cat > uninstall.sh << 'EOF'
#!/bin/bash

# Archive Tool 卸载脚本
# 用法: sudo ./uninstall.sh

set -e

echo "开始卸载Archive Tool..."

# 删除头文件
rm -f /usr/local/include/archive.h

# 删除库文件
rm -f /usr/local/lib/libarchive.a
rm -f /usr/local/lib/libarchive.so*
rm -f /usr/local/lib/libarchive*.dylib

# 删除命令行工具
rm -f /usr/local/bin/archive

# 删除man手册
rm -f /usr/local/share/man/man1/archive.1

# 更新动态链接器缓存
if command -v ldconfig &> /dev/null; then
    ldconfig
fi

# 更新man数据库
if command -v mandb &> /dev/null; then
    mandb
fi

echo "Archive Tool 卸载完成"
EOF
    
    chmod +x uninstall.sh
    print_info "卸载脚本已创建: ./uninstall.sh"
}

# 创建配置文件
create_configuration() {
    print_info "创建配置文件..."
    
    mkdir -p /etc/archive
    cat > /etc/archive/default.conf << 'EOF'
# Archive Tool 默认配置文件
# 此文件包含全局默认设置

# 默认压缩级别 (0-9)
default_compression = 6

# 是否显示进度条
show_progress = true

# 默认归档文件扩展名
default_extension = .arc

# 排除的文件模式 (每行一个)
exclude_patterns = [
    "*.tmp",
    "*.log",
    "*.swp",
    ".*.swp",
    ".DS_Store",
    "Thumbs.db",
    "*.bak",
    "*.backup"
]

# 日志设置
log_level = info
log_file = /var/log/archive.log

# 加密设置
# 默认加密算法
default_encryption = aes256

# 性能设置
# 缓冲区大小 (字节)
buffer_size = 65536

# 是否启用多线程压缩
enable_multithreading = false

# 线程数 (如果启用多线程)
thread_count = 4

# 归档格式设置
# 是否存储文件权限
store_permissions = true

# 是否存储文件时间戳
store_timestamps = true

# 是否存储符号链接
store_symlinks = true
EOF
    
    chmod 644 /etc/archive/default.conf
}

# 测试安装
test_installation() {
    print_info "测试安装..."
    
    # 测试库是否可用
    if [ -f /usr/local/bin/archive ]; then
        echo "测试命令行工具..."
        /usr/local/bin/archive version
        
        echo -e "\n测试创建归档..."
        echo "Test file content" > test_file.txt
        /usr/local/bin/archive create test.arc test_file.txt
        
        echo -e "\n测试列出归档..."
        /usr/local/bin/archive list test.arc
        
        echo -e "\n测试提取归档..."
        mkdir -p test_extract
        /usr/local/bin/archive extract test.arc test_extract
        
        echo -e "\n清理测试文件..."
        rm -f test_file.txt test.arc
        rm -rf test_extract
        
        print_info "安装测试完成!"
    else
        print_error "命令行工具未正确安装"
    fi
}

# 主安装流程
main() {
    print_info "========================================"
    print_info "   Archive Tool 安装程序 v1.0.0"
    print_info "========================================"
    
    # 检查当前目录
    if [ ! -f "archive.h" ] || [ ! -f "archive.c" ]; then
        print_error "请在源代码目录中运行此脚本"
        exit 1
    fi
    
    # 检查依赖
    check_dependencies
    
    # 编译源代码
    compile_source
    
    # 安装到系统
    install_to_system
    
    # 创建配置文件
    create_configuration
    
    # 创建卸载脚本
    create_uninstaller
    
    # 测试安装
    test_installation
    
    print_info "========================================"
    print_info "   Archive Tool 安装完成!"
    print_info "========================================"
    echo ""
    print_info "使用方法:"
    echo "  创建归档:     archive create backup.arc file1 file2"
    echo "  提取归档:     archive extract backup.arc"
    echo "  列出归档:     archive list backup.arc"
    echo "  查看帮助:     archive help"
    echo ""
    print_info "配置文件位置: /etc/archive/default.conf"
    print_info "卸载脚本: ./uninstall.sh"
    echo ""
}

# 运行主函数
main
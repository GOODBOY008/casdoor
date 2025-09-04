#!/bin/bash

# 默认值
TARGET_ARCHES=()

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  空             编译当前架构"
    echo "  amd64          编译 amd64 架构"
    echo "  arm64          编译 arm64 架构"
    echo "  all            编译所有架构 (amd64 和 arm64)"
    echo "  -h, --help     显示此帮助信息"
}

# 解析参数
parse_args() {
    case "$1" in
        ""|"current")
             TARGET_ARCHES=("$(get_current_arch)")
            ;;
        "amd64")
            TARGET_ARCHES=("amd64")
            ;;
        "arm64")
            TARGET_ARCHES=("arm64")
            ;;
        "all")
            TARGET_ARCHES=("amd64" "arm64")
            ;;
        "-h"|"--help")
            show_help
            exit 0
            ;;
        *)
            echo "错误: 未知参数 '$1'" >&2
            show_help
            exit 1
            ;;
    esac
}

# 检测网络连接并设置代理
setup_proxy() {
    if curl www.google.com -o /dev/null --connect-timeout 5 2> /dev/null; then
        echo "Successfully connected to Google, no need to use Go proxy"
    else
        echo "Google is blocked, Go proxy is enabled: GOPROXY=https://goproxy.cn,direct"
        export GOPROXY="https://goproxy.cn,direct"
    fi
}

# 获取当前架构
get_current_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "未知架构: $(uname -m)"
            exit 1
            ;;
    esac
}

# 主函数
main() {

    # 解析参数
    parse_args "$1"

    # 设置代理
    setup_proxy

    for arch in "${TARGET_ARCHES[@]}" ; do
        CGO_ENABLED=0 GOOS=linux GOARCH=${arch} go build -ldflags="-w -s" -o server_linux_"${arch}" .
    done
}

# 执行主函数
main "$1"
#!/bin/sh

# 定义展开IPv6地址的函数
expand_ipv6() {
    ip="$1"

    # 处理双冒号，替换为标记
    ip=$(echo "$ip" | sed 's/::/:z:/g')
    
    # 分割为数组
    OLD_IFS="$IFS"
    IFS=":"
    # shellcheck disable=SC2086
    set -- $ip
    IFS="$OLD_IFS"
    
    expanded=""
    segment_count=0
    for segment in "$@"; do
        if [ "$segment" = "z" ]; then
            # 计算需要填充的零段数量
            fill=$((8 - ($# - 1)))
            i=1
            while [ $i -le $fill ]; do
                expanded="${expanded}0000:"
                segment_count=$((segment_count + 1))
                i=$((i + 1))
            done
        else
            # 补全段到4位十六进制
            segment=$(printf "%04x" "0x$segment" 2>/dev/null)
            expanded="${expanded}${segment}:"
            segment_count=$((segment_count + 1))
        fi
    done

    # 移除末尾冒号并补全可能的缺失段
    expanded=$(echo "$expanded" | sed 's/:$//')
    echo "$expanded"
}

# polyfill for tac
tac() {
    awk '{for(i=length($0); i>0;i--) printf (substr($0,i,1));}'
}

# 主逻辑
ipv6_address="$1"
if [ -z "$ipv6_address" ]; then
    echo "Usage: $0 <IPv6 Address>"
    exit 1
fi

# 展开IPv6地址
expanded=$(expand_ipv6 "$ipv6_address")

# 合并并处理字符串
hex_str=$(echo "$expanded" | tr -d ':')
reversed=$(echo "$hex_str" | tac | grep -o . | tr '\n' '.' | sed 's/\.$//')

# 生成最终域名
arpa_domain="${reversed}.ip6.arpa"
echo "$arpa_domain"

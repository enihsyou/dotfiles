# Merlin Clash 配置备忘

本文件记录了在 ASUS RT-AX86U 路由器上使用 Merlin 固件和 Clash 的配置备忘，因为在那里无法写注释。

## 前置分流

### Iptables 转发白名单

```text

```

### Iptables 转发黑名单

使用时按列选择只保留注释前的部分，页面并不能识别注释。

```text
45.112.123.225    # file4.gofile.io
203.17.244.25     # file5.gofile.io
172.96.160.199    # file6.gofile.io
172.96.161.63     # file7.gofile.io
172.96.160.116    # file8.gofile.io
203.15.121.21     # file9.gofile.io
103.107.198.185   # file10.gofile.io
202.165.69.5      # file-eu-par-1.gofile.io
202.165.69.3      # file-eu-par-2.gofile.io
203.10.97.133     # file-na-lax-1.gofile.io
```

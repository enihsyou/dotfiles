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

## 子网转发

在开启了 Merlin Clash + Tproxy mode 的路由器上挂了一个与路由器同网段的 192.168.9.17 设备，
上面运行了处在 192.168.2/24 网段的虚拟机，并且设备当做路由器处理转发。
奇怪的是两个网段可以 ping 通但是无法建立 TCP 连接。

怀疑是 A(192.168.9.18) to B(192.168.2.82) 跨网段经路由器路由，B to A 直接链路直连不经过路由器，
被 Merlin Clash 添加的 mangle 规则把局域网中经过路由器未硬件加速的流量 DROP 了。

```shell
# iptables -t mangle -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
merlinclash_divert  tcp  --  anywhere             anywhere
merlinclash_divert  udp  --  anywhere             anywhere

Chain merlinclash_divert (2 references)
target     prot opt source               destination
CONNMARK   all  --  anywhere             anywhere             CONNMARK restore
TPROXY     tcp  --  anywhere             anywhere             mark match 0x2333 ctstate RELATED,ESTABLISHED TPROXY redirect 127.0.0.1:23458 mark 0x0/0x0
TPROXY     udp  --  anywhere             anywhere             mark match 0x2333 ctstate RELATED,ESTABLISHED TPROXY redirect 127.0.0.1:23458 mark 0x0/0x0
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
DROP       all  --  anywhere             anywhere             ctstate INVALID
```

简单的修复是提前绕过透明代理，本地流量不 mangle

```shell
iptables -t mangle -I PREROUTING -s 192.168.9.0/24 -d 192.168.2.0/24 -j RETURN
iptables -t mangle -I PREROUTING -s 192.168.2.0/24 -d 192.168.9.0/24 -j RETURN
```

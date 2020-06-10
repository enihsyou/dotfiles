# 往这些设备当添加永久路由
# 通过 `networksetup -listlocations` 命令查看自己有哪些活跃设备
# 然后相应修改列表元素
services=(
	"Wi-Fi"
    "Ethernet"
#	"USB 10/100/1000 LAN"
)

# 为这些子网添加路由信息
subnets=(
	10.10.0.0
	10.16.0.0
	10.88.0.0
	10.110.0.0
	10.121.0.0
	10.123.0.0
)

# 使用一个不同的位置来应用路由规则
USE_LOCATION=
# 除特殊需要，以下无需修改

# 子网掩码
subnet_mask=255.255.0.0
# 目标路由
target_route=10.0.4.1
# 使用位置(macOS Location)，系统默认是Automatic
location=Hypers

# 接下来构建setadditionalroutes所需的语句
statement=""
for subnet in "${subnets[@]}"; do
	statement="$statement $subnet $subnet_mask $target_route"
done

# 切换到一个网络位置
if [ "$USE_LOCATION" ]; then
	networksetup -createlocation $location > /dev/null 2>&1
	networksetup -switchtolocation $location > /dev/null 2>&1
fi

# 为当前位置(Location)的设备(service)设置永久路由
for service in "${services[@]}"; do
	# shellcheck disable=SC2086
	networksetup -setadditionalroutes "$service" $statement
done

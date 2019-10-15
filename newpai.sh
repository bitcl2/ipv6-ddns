#此脚本需要先转换为unix格式执行.sources.list不能用https！！！
#有必要的话修改pip源。需要先确定版本。armbian是python3.不过之后做镜像就不需要了。
#bt面板自动切换源了。
#有线不稳定的解决办法
ethtool --set-eee eth0 eee off
cat /sys/module/apparmor/parameters/enabled

echo "ethtool --set-eee eth0 eee off" >> /etc/init.d/eee.sh && rm -f /etc/init.d/eee.sh && echo "ethtool --set-eee eth0 eee off" >> /etc/init.d/eee.sh && chmod a+x /etc/init.d/eee.sh
#无论执行几次都保证只有一行 
#此为第一步
mkdir /bitcl && mkdir /bitcl/tools && cd /bitcl/tools
#安装hassio
cd /bitcl/tools &&  curl -sL -o install.sh https://raw.githubusercontent.com/neroxps/hassio_install/master/install.sh && chmod a+x install.sh && echo -e "y\n2\ny\n3\n5\ny\n/bitcl/tools/hass\n" | ./install.sh
echo "安装hassio完成。IP:8123"
sleep 5s
#安装docker图形面板
docker run --name portainer --restart=always -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer:arm64
echo "docker面板完成。IP：9000"
#docker pull centos:latest
#echo "下载centos镜像完成，将在里边安装宝塔面板"
mkdir /bitcl/tools/bt && mkdir /bitcl/tools/bt/www
#docker run --name centos --restart=always --net=host -i -t -d --privileged=true -v /bitcl/tools/bt/www:/www centos
#centos国内无arm64源，弃用
#不主动映射端口。host模式 
#host它可以与主机共享Root Network Namespace，容器有完整的权限操纵主机的网络配置，出于安全考虑，不推荐使用这种模式。 
#启动host模式非常简单，依旧是在docker run中加入--net=host参数即可。
#另外，还有none模式、container模式、bridge模式(默认模式)、overlay模式



#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#注：如果之后保存为镜像，可以直接pull。
docker pull arm64v8/debian:10.1
docker run --name debian --restart=always --net=host -i -t -d --privileged=true -v /bitcl/tools/bt/www:/www debian /sbin/init
echo "下载centos镜像完成，将在里边安装宝塔面板"
#换软件源先在宿主机搭建http下载目录：
nohup python3 -m http.server 889 --directory /etc/apt -d  > /dev/null 2>&1 &
#或者复制进、bitcl/tools、www，与debian内的www是共享目录
#docker exec -d debian /bin/bash "apt-get install wget -y && rm -f /etc/apt/sources.list && wget -P /etc/apt http://127.0.0.1:889/sources.list"
#docker里没有wget和vi等，没有ca。连https也用不了。所以：
echo "安装依赖"
cp -f /etc/apt/sources.list /bitcl/tools/bt/www/sources.list && docker exec -d debian /bin/bash -c "rm -f /etc/apt/sources.list && mv /www/sources.list /etc/apt/sources.list"
sleep 1s
docker exec -d debian /bin/bash -c "apt-get update && apt-get upgrade -y && apt-get install procps tmux wget curl apt-utils build-essential autoconf libtool libssl-dev gcc git clang -y"
echo "开始安装bt面板"
sleep 3s
docker exec -d debian /bin/bash -c "mkdir /bitcl && mkdir /bitcl/tools && mkdir /bitcl/tools/bt && cd /bitcl/tools/bt && wget -4 -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && chmod a+x install.sh && echo -e "y\n" | bash install.sh"
#!!!!!时常检查更新
echo "安装中，等一会儿"






















#！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

编译安装nginx需要注意加上两个命令。
apt-get install ssh
输入bt命令修改面板配置。可以安装ssh。修改root登录进入里边。
nginx 编译支持：/www/server/panel/install/nginx.sh stream已经有了。
cd /www/server/panel/install && wget wget https://github.com/arut/nginx-rtmp-module/archive/master.zip && unzip master.zip
目录是/www/server/panel/install/nginx-rtmp-module-master。
nginx.sh找到。、configure添加。 --add-module=/www/server/panel/install/nginx-rtmp-module-master
编译完作镜像要删除ssh等。也不用，主防火墙关闭宿主端口就行。平常docke端口也关闭。  还是删了吧，纯净docker，需要别的再加。
这样的bt开机不会自启：https://www.cnblogs.com/yougewe/p/10425387.html 创建的时候就要加 -c 命令。https://blog.csdn.net/codemonkeyyyyyyy/article/details/90294222或者加一个脚本。

不行：：方法https://blog.csdn.net/JOYIST/article/details/93115849





之后先导出旧的。删除，导入新的加命令.
docker export debian > /bitcl/mydebian1.tar
docker rm debian
docker import /bitcl/mydebian1.tar mydebian:v1
docker run --name mydebianv1 --restart=always --net=host -i -t -d --privileged=true -v /bitcl/tools/bt/www:/www mydebian:v1 /sbin/init

####################################################################################

或者直接写明什么start在后面。
失败了，尝试在www目录写吧。
/var/lib/docker/overlay2 有很多旧文件需要删除。！！！！！！！！！！！！！！！不能删！删了就启动不了了啊！！/var/lib/docker/overlay2 占用很大，清理Docker占用的磁盘空间，迁移 /var/lib/docker 目录
其实可以这样，先用命令创建容器，虽然没有shell脚本，创建完进去创建就好了。
但是用户可以通过docker run命令重新定义（译者注：docker run可以控制一个容器运行时的行为，它可以覆盖docker build在构建镜像时的一些默认配置），这也是为什么run命令相比于其它命令有如此多的参数的原因。
https://www.cnblogs.com/zhuochong/p/10070516.html
https://m.imooc.com/wenda/detail/431864
Docker 不能使用systemctl 的问题
2018年06月07日 16:07:13 sunnyfg 阅读数 3358更多
分类专栏： Docker
版权声明：本文为博主原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接和本声明。
本文链接：https://blog.csdn.net/sunnyfg/article/details/80610868
在docker容器里安装了mariadb，启动的时候执行

systemctl start mariadb
Failed to get D-Bus connection: Operation not permitted
1
2
上网搜索，这个是Docker的一个bug,在centos7.2以后已解决，但是我用的centos已经升级到了7.5版本，仍然会有这个问题出现。

比较有效的方法是启动容器的时候加上/usr/sbin/init的参数

sudo docker run -dit centos /usr/sbin/init
1
之后再安装mariadb的时候，就可以启动了！！！！！！！！！！！！！！！！！！！！！！！！！！

容器内服务也自动启动了！！！！！！！！！！！！






##############################################################################



#####################################################################################
放弃docker宝塔。
hub里搜索arm64v8有惊喜。



更改vm.swappiness=10。
更改主机软件源、cocker源、pip源。hassio做到前两者，宝塔后两者。
armbian-config更换armbian的清欢源。另配置固定ip。



docker run --name debian --restart=always --net=host -i -t -d --privileged=true -v /bitcl/tools/debian/www:/www debian /bin/bash

cp -f /etc/apt/sources.list /bitcl/tools/debian/www/sources.list && docker exec -d debian /bin/bash -c "rm -f /etc/apt/sources.list && mv /www/sources.list /etc/apt/sources.list"
docker exec -it debian /bin/bash
apt-get install ssh vim wget -y
service ssh restart
passwd root
apt-get install nginx-full
php7.3* -y 报错
apt-get install aptitude -y
aptitude install php7.3* -y 不行
apt-get install nginx php7.0-fpm php7.0-cli php7.0-curl php7.0-gd php7.0-mcrypt php7.0-cgi
注意替换  http://shumeipai.nxez.com/2018/04/25/install-pi-dashboard-with-nginx-php7-on-pi.html


bt面板开启防火墙。


###################
因为nginx可以通过9000端口读取php-fpm，因此docker远程化php成为可能。见conf。
mysql就完全docker化吧。
docker run --name mysql --restart=always -di -p 3306:3306 mysql/mysql-server:8.0:arm64 -e MYSQL_ROOT_PASSWORD=..1134491249abc mysql

https://www.cnblogs.com/yui66/p/9728732.html
安装phpadmin
mkdir /www/default/mysql
cd /www/default/mysql && wget wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-all-languages.zip && unzip phpMyAdmin-4.9.1-all-languages.zip
解决方法把phpmyadmin目录中的配置文件config.sample.inc.php改成config.inc.php
打开编辑config.inc.php
找到：
$cfg['Servers'][$i]['host'] = 'localhost';
改成：
$cfg['Servers'][$i]['host'] = '127.0.0.1';
再次刷新页面就不会出现mysqli_real_connect(): (HY000/2002): No such file or directory的错误提示了
配置移动目录。并修改打开libraries下的config.default.php文件，https://www.php.cn/php-weizijiaocheng-383120.html
$cfg['Servers'][$i]['host'] = 'localhost';
改成：
$cfg['Servers'][$i]['host'] = '127.0.0.1';
http://www.jutuibao.com/read-173374.html

原因是如果你使用localhost，pma会尝试连接到mysql.socket。如果您使用127.0.0.1 PMA进行TCP连接应该工作。



apt-get install php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dba php7.3-dev php7.3-enchant php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-interbase php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell php7.3-readline php7.3-snmp php7.3-soap php7.3-sqlite3 php7.3-sybase php7.3-recode php7.3-tidy php7.3-xml php7.3-xmlrp php7.3-zip php7.3-xsl

service php7.3-fpm restart




docker stop debian
docker export debian > /bitcl/mydebian1.tar

reboot

docker import /bitcl/mydebian1.tar mydebian:v1
docker run --name mydebian --restart=always --net=host -i -t -d --privileged=true -v /bitcl/tools/debian/www:/www mydebian:v1 /sbin/init


#####################mysql
是php不支持mysql8.降级镜像。先删除旧的。命令也出错了。
docker run --name mariadb --restart=always -di -p 3306:3306 -e MYSQL_ROOT_PASSWORD=..1134491249abc arm64v8/mariadb:latest

复制.pip配置。
至此docker的 lnmp成功。之后主要修改、etc/nginx 和www（宿主机共享，需要单独备份）。不行。
docker stop mydebian
docker export mydebian > /bitcl/mydebian2.tar
docker rm mydebian
docker import /bitcl/mydebian2.tar mydebian:v2

docker run --name mydebian --restart=always --net=host -i -t -d --privileged=true mydebian:v2 /sbin/init






################################################################################################################
nginx重写(隐藏)index.php目录
访问某域名时，去掉index.php目录时达到效果一样

如： 　　

　　www.test1/index.php/test2跟www.test1/test2效果一致

　　nginx配置中加入如下内容：

　　location / { 　　

　　　　if (!-e $request_filename) { 　　

　　　　rewrite ^(.*)$ /index.php?s=$1 last; 　　

break; 　　

　　}

}

不行的。

###############################
安装filemanager
n0cloud/filebrowser-multiarch:arm64>不用docker了，我主要是想修改web页面。
mkdir /www/filebrowser && cd /www/filebrowser
wget https://github.com/filebrowser/filebrowser/releases/download/v2.0.12/linux-arm64-filebrowser.tar.gz
tar -xzvf linux-arm64-filebrowser.tar.gz
创建filebrowser用户并制定目录。
useradd -d /www -m filebrowser
apt-get install sudo
chmod 777 /www && cd /www && sudo -u filebrowser /www/filebrowser -a 0.0.0.0 -p 8000   (一般用户不能使用低端口)
echo "cd /www && nohup sudo -u filebrowser /www/filebrowser -a 0.0.0.0 -p 8000 > /dev/null 2>&1 &" >> /etc/init.d/filebrowser.sh && chmod a+x /etc/init.d/filebrowser.sh
开启防火墙 8080



小问题，不显示温度。
armbian 不显示CPU温度的问题修复
2018年02月08日 08:53:24 CHN悠远 阅读数 1146
版权声明：本文为博主原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接和本声明。
本文链接：https://blog.csdn.net/qadzhangc/article/details/79285823
armbian有时候再更新后或者不知道咋的就不会在登录和armbianmonitor里面显示CPU目前温度



其实就是一个链接文件没有了

CPU的温度还是一直有的,只是armbian使用的那个链接需要重新做一下



 ln  -s   /sys/devices/virtual/thermal/thermal_zone0/temp /etc/armbianmonitor/datasources/soctemp
 不行，目录不可写。


 pi面板咋办，在dervice.php里找到temp修改命令
    if (($str = @file("/sys/class/thermal/thermal_zone0/temp")) !== false){

    	改为

    if (($str = @file("/etc/armbianmonitor/datasources/soctemp")) !== false){

    	不行，是armbian更新的锅。目录无权限了。htop都不显示温度了。

    	呵。原因是宝塔删除了apt里的arm源。恢复apt-get update就行了。/etc/apt/sources.list.d/armbian.list   << deb http://mirrors.tuna.tsinghua.edu.cn/armbian/ buster main buster-utils buster-desktop



reboot



内核参数。：不能这么多！现在开机卡死了。硬盘精灵可以进入分区写文件。
/etc/sysctl.conf





net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
#sysctl -n net.ipv4.tcp_tw_recycle 查看已经打开了。该项为0比较好。
vm.swappiness=10



ddns脚本
#!/bin/bash
source /etc/profile
AuthKey="ffcfbdf43d666c32762111372a2e671cf49ab" ##在这里输入 API Key
AuthMail="bitshiyuzhe@163.com" ##在这里输入在 Cloudflare 使用的邮箱
DDnsName="home.bitcl.win" ##在这里输入已经添加的，预计用于ddns的完整域名（完整的。。比如希望使用ddns.example.com作为ddns域名时，输入ddns.example.com）
domain="bitcl.win" ##在这里输入绑定到 Cloudflare 的域名（比如希望使用ddns.example.com作为ddns域名时，输入example.com）
type="AAAA"
new_ip=$(ifconfig eth0 | awk '{print $2}' | sed -n '4p')
zone_id=$(curl "https://api.cloudflare.com/client/v4/zones?name=$domain" -H "X-Auth-Email: $AuthMail" -H "X-Auth-Key: $AuthKey" | grep -oP "\"id\":\"[a-f\d]{32}"|grep -oP "[a-f\d]{32}"|head -n1)
dns_record_id=$(curl "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=$type&name=$DDnsName" -H "X-Auth-Email: $AuthMail" -H "X-Auth-Key: $AuthKey" | grep -oP "\"id\":\"[a-f\d]{32}"|grep -oP "[a-f\d]{32}"|head -n1)
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_id" -H "X-Auth-Email: $AuthMail" -H "X-Auth-Key: $AuthKey" -H "Content-Type: application/json" --data '{"type":"'$type'","name":"'$DDnsName'","content":"'$new_ip'","ttl":120,"proxied":false}' 




创建个/etc/rc.local


乱加内核参数启动不了了！
硬盘精灵删除它就好了。

检查网卡eee
ethtool --show-eee eth0
执行了rc.local  注意转换unix格式。



filebrowser 单启动失败，docker化：
docker run --name filebrowser --restart=always -p 8080:8080 -i -t -d n0cloud/filebrowser-multiarch:arm64
n0cloud/filebrowser-multiarch

docker exec -it filebrowser /bin/bash

php和nginx也可以挂载一目录实现挂载sock和网页目录。并且较安全。
参考：
docker run --name filebrowser --restart=always -d -v /www/filebrowser/data:/srv -v /www/filebrowser/filebrowserconfig.json:/etc/config.json -v /www/filebrowser/database.db:/etc/database.db -p 8080:80 n0cloud/filebrowser-multiarch:arm64

!!!!!下载工具和它们可以挂载同一个Volumes文件夹！！！！这样下载查看可以在一起了。


完毕。清理内存。
导出镜像以及备份主机镜像。

查看端口占用：
netstat -nl | grep 8388























###########################################################################################
备份后续：打算加入一个test的debian。
一=网盘和下载镜像等换了大容量硬盘加上再说。

docker run --name testdebian --restart=always --net=host -i -t -d --privileged=true mydebian:v2 /sbin/init
docker exec -it testdebian /bin/bash
cd /etc/ssh
vim sshd_config                  ————————————————————————————需要配置监听ipv6！！！！其他的都一样。
service ssh restart
apt-get autoremove nginx* -f --purge
apt-get remove php* --purge  不能auto -f 否则看到gcc g++也被删了。之后重新安装吧。
以上操作是因为重复端口无法启动。
apache2-bin 删除
netstat -nl
之后不能autoremove。


重启宿主机才行。



phpadmin提示tmp不行运行缓慢办法：（运行缓慢原因）

cd /www/web/mysql 
ln -s /tmp ./
源>目标链接
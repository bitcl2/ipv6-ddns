# ipv6-ddns  
使用cloudflare api，api文档参照https://api.cloudflare.com/  
原则上传统的ddns插件代码能满足大家需求，但是由于ipv4内网化趋势，运营商基本不在下发给个人用户公有ipv4地址。  
呐，现在大家都用nas，远程主机等，还是需要这个的。在服务器上使用过内网穿透，但是效率和方便性都不够。偶然发现各运营商都已经普及ipv6，计划直接走ipv6ddns。  
（注意：做好安全防护，有必要的话升级内核要支持ip6tables。）

需要注意的是获取ip的指令，不能用网上流传的外网api获取，结合本机实际硬件获取。  
比如我的路由因为是双拨，会有两个多个ipv6地址，因此需要在命令中指定。又部分系统不存在eht0接口，可以只用ppp0e0或者br0。  
# 2020更新
这几个月cloudflare接口更新频繁，主要是数据返回格式的问题。五月份又改回原来的了。主要是dns_record_id的数据返回格式，前段时间变成了很工整有换行的jason格式，但是id前错误加了个空格。
估计是cloudflare换了新员工，代码很工整，但是太不认真了，出问题直接回滚。


#!/bin/bash
source /etc/profile
AuthKey="" ##API Key
AuthMail="" ##输入邮箱
DDnsName="" ##二级域名
domain="" ##一级域名
type="AAAA"
new_ip=$(ifconfig eth0 | awk '{print $2}' | sed -n '4p')
zone_id=$(curl "https://api.cloudflare.com/client/v4/zones?name=$domain"  \ 
-H "X-Auth-Email: $AuthMail"  \
-H "X-Auth-Key: $AuthKey" | grep -oP "\"id\":\"[a-f\d]{32}"|grep -oP "[a-f\d]{32}"|head -n1)
dns_record_id=$(curl "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=$type&name=$DDnsName"  \ 
-H "X-Auth-Email: $AuthMail" -H "X-Auth-Key: $AuthKey" | grep -oP "\"id\":\"[a-f\d]{32}"|grep -oP "[a-f\d]{32}"|head -n1)
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_id"  \ 
-H "X-Auth-Email: $AuthMail" -H "X-Auth-Key: $AuthKey"  \ 
-H "Content-Type: application/json"  \ 
--data '{"type":"'$type'","name":"'$DDnsName'","content":"'$new_ip'","ttl":120,"proxied":false}' 

# deploy-codo
Deploy a Production Ready DevOps Platform

# Usage

```
git clone https://github.com/ysicing/deploy-codo.git
vagrant up 
ssh 172.20.0.101 (root/vagrant)
cd /opt/codo
# 参数可选,更多参数可参考setup.sh
./setup.sh --domain <自定义域名> --user <登录用户> --password <登录密码>
```

## 其他

```
1. 53端口问题,默认起来一个dnsmasq服务用来解析域名服务 <ip:8080> ,其他参数看配置

  dnsmasq:
    image: hub.ops.talk.com/library/dnsmasq <内网镜像仓库>
    container_name: dnsmasq
    volumes:
      - /usr/share/ln/dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf
    environment:
      - HTTP_USER=talk
      - HTTP_PASS=talk.com
    network_mode: host
    restart: always
```

# deploy-codo
Deploy a Production Ready DevOps Platform

# Usage

> 仅在Debian 9上测试过,Debian 10需要等待https://get.docker.com/更新

```
git clone https://github.com/ysicing/deploy-codo.git
vagrant up 
ssh 172.20.0.101 (root/vagrant)
cd /opt/codo
# 参数可选,更多参数可参考setup.sh
./setup.sh --domain <自定义域名> --user <登录用户> --password <登录密码>
```

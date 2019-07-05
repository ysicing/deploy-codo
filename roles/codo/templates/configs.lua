json = require("cjson")

--mysql_config = {
--    host = "127.0.0.1",
--    port = 3306,
--    database = "lua",
--    user = "root",
--    password = "",
--    max_packet_size = 1024 * 1024
--}

redis_config = {
    host = '{{ REDIS_HOST }}',
    --host = '172.16.0.121',
    port = {{ REDIS_PORT }},
    auth_pwd = '{{ REDIS_PASSWORD }}',
    db = 8,
    alive_time = 3600 * 24 * 7,
    channel = 'gw'
}

--mq_conf = {
--	host = '172.16.0.121',
--	port = 5672,
--	username = 'sz',
--	password = '123456',
--	vhost = '/'
--}

token_secret = "{{ TOKEN_SECRET }}"
logs_file = '/var/log/gw.log'

--刷新权限到redis接口
rewrite_cache_url = 'http://{{ MG_DOMAIN }}:8010/v2/accounts/verify/'
rewrite_cache_token = '{{ SECRET_KEY }}'

--并发限流配置
limit_conf = {
    rate = 10, --限制ip每分钟只能调用n*60次接口
    burst = 10, --桶容量,用于平滑处理,最大接收请求次数
}

--upstream匹配规则
gw_domain_name = '{{ GW_DOMAIN }}'

rewrite_conf = {
    [gw_domain_name] = {
        rewrite_urls = {
            {
                uri = "/dns",
                rewrite_upstream = "{{ DNS_DOMAIN }}:8060"
            },
            {
                uri = "/cmdb2",
                rewrite_upstream = "{{ CMDB2_DOMAIN }}:8050"
            },
            {
                uri = "/tools",
                rewrite_upstream = "{{ TOOLS_DOMAIN }}:8040"
            },
            {
                uri = "/kerrigan",
                rewrite_upstream = "{{ CONFIG_DOMAIN }}:8030"
            },
            {
                uri = "/cmdb",
                rewrite_upstream = "{{ CMDB1_DOMAIN }}:8002"
            },
            {
                uri = "/k8s",
                rewrite_upstream = "{{ K8S_DOMAIN }}:8001"
            },
            {
                uri = "/task",
                rewrite_upstream = "{{ TASK_DOMAIN }}:8020"
            },
            {
                uri = "/cron",
                rewrite_upstream = "{{ CRON_DOMAIN }}:9900"
            },
            {
                uri = "/mg",
                rewrite_upstream = "{{ MG_DOMAIN }}:8010"
            },
            {
                uri = "/accounts",
                rewrite_upstream = "{{ MG_DOMAIN }}:8010"
            },
        }
    }
}
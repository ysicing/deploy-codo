FROM  opencodo/python

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg2 vim nano \
    && curl https://mirrors.xtom.com/sb/nginx/public.key | apt-key add - \
    && echo "deb https://mirrors.xtom.com/sb/nginx/ stretch main" > /etc/apt/sources.list.d/sb-nginx.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y nginx \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /var/www
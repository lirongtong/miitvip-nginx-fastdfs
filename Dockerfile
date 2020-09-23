FROM alpine:3.10

LABEL maintainer="NGINX FastDFS Docker Maintainers <lirongtong@hotmail.com>"

ENV NGINX_VERSION=1.17.1 \
    NGINX_HTTP_PORT=80 \
    NGINX_HTTPS_PORT=443 \
    STORAGE_HTTP_PORT=8888 \
    STORAGE_PORT=23000 \
    TRACKER_PORT=22122 \
    NET_VAR=eth0 \
    HOME=/.build-src

# 添加配置文件
ADD conf/client.conf /etc/fdfs/
ADD conf/http.conf /etc/fdfs/
ADD conf/mime.types /etc/fdfs/
ADD conf/storage.conf /etc/fdfs/
ADD conf/tracker.conf /etc/fdfs/
ADD fastdfs.sh /home
ADD conf/mod_fastdfs.conf /etc/fdfs/

RUN set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        bash \
        gcc \
    	make \
    	linux-headers \
    	curl \
    	gnupg \
    	gd-dev \
    	pcre-dev \
    	zlib-dev \
    	libc-dev \
    	libxslt-dev \
    	openssl-dev \
    	geoip-dev \
    && mkdir - p ${HOME} \
    && chmod u+x /home/fastdfs.sh \

    # 下载 / 安装 libfastcommon
    && cd /${HOME} \
    && wget https://github.com/happyfish100/libfastcommon/archive/master.tar.gz -O libfastcommon.tar.gz \
    && tar zxf libfastcommon.tar.gz \
    && cd ./libfastcommon-master \
    && ./make.sh \
    && ./make.sh install \

    # 下载 / 安装 FastDFS
    && cd /${HOME} \
    && wget https://github.com/happyfish100/fastdfs/archive/master.tar.gz -O fastdfs.tar.gz \
    && tar zxf fastdfs.tar.gz \
    && cd ./fastdfs-master \
    && ./make.sh \
    && ./make.sh install \
    
    # 下载 nginx 插件
    && cd /${HOME} \
    && wget https://github.com/happyfish100/fastdfs-nginx-module/archive/master.tar.gz -O fastdfs-nginx-module.tar.gz \
    && tar zxf fastdfs-nginx-module.tar.gz \
    && chmod u+x ./fastdfs-nginx-module-master/src/config \

    # 下载 nginx
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \

    # 编译 nginx 及 fastdfs 的 nginx 插件
    && mkdir -p /var/cache/nginx \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
    	--prefix=/etc/nginx \
    	--sbin-path=/usr/sbin/nginx \
    	--modules-path=/usr/lib/nginx/modules \
    	--conf-path=/etc/nginx/nginx.conf \
    	--error-log-path=/var/log/nginx/error.log \
    	--http-log-path=/var/log/nginx/access.log \
    	--pid-path=/var/run/nginx.pid \
    	--lock-path=/var/run/nginx.lock \
    	--http-client-body-temp-path=/var/cache/nginx/client_temp \
    	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    	--user=nginx \
    	--group=nginx \
    	--with-compat \
    	--with-file-aio \
    	--with-threads \
    	--with-http_addition_module \
    	--with-http_auth_request_module \
    	--with-http_dav_module \
    	--with-http_flv_module \
    	--with-http_gunzip_module \
    	--with-http_gzip_static_module \
    	--with-http_mp4_module \
    	--with-http_random_index_module \
    	--with-http_realip_module \
    	--with-http_secure_link_module \
    	--with-http_slice_module \
    	--with-http_ssl_module \
    	--with-http_stub_status_module \
    	--with-http_sub_module \
    	--with-http_v2_module \
    	--with-mail \
    	--with-mail_ssl_module \
    	--with-stream \
    	--with-stream_realip_module \
    	--with-stream_ssl_module \
    	--with-stream_ssl_preread_module \
    	--with-cc-opt='-g -O2 -fdebug-prefix-map=/data/builder/debuild/nginx-1.17.1/debian/debuild-base/nginx-1.17.1=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    	--with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    	--add-module=../fastdfs-nginx-module-master/src \
    && make && make install \

    # 清理临时文件
    && rm -rf ${HOME} \
    && apk del .build-deps bash gcc make linux-headers curl gnupg gd-dev pcre-dev zlib-dev libc-dev libxslt-dev openssl-dev geoip-dev \
    && apk add bash pcre-dev zlib-dev

EXPOSE ${NGINX_HTTP_PORT} ${NGINX_HTTPS_PORT} ${TRACKER_PORT} ${STORAGE_PORT} ${STORAGE_HTTP_PORT}

STOPSIGNAL SIGTERM

ENTRYPOINT ["/home/fastdfs.sh"]
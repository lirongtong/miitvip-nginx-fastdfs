# Docker 镜像 - 麦可易特网

### 1. 拉取镜像

`docker pull miitvip/nginx-fastdfs`

### 2. 创建目录
```
# 运行之前，创建好相应的文件目录
mkdir -p /miitvip/logs/nginx /miitvip/docker/nginx/ \
/miitvip/docker/nginx/ssl /miitvip/docker/nginx/letsencrypt /miitvip/docker/fastdfs/tracker \
/miitvip/docker/fastdfs/storage /miitvip/docker/fastdfs/client \
/miitvip/docker/fastdfs/conf /miitvip/web/fastdfs
```

### 3. 启动 nginx
```
docker run -d -ti --name nginx \
-p 80:80 -p 443:443 \
-v /miitvip/web:/www \
-v /miitvip/logs/nginx:/var/log/nginx \
-v /miitvip/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
-v /miitvip/docker/nginx/conf.d:/etc/nginx/conf.d \
-v /miitvip/docker/nginx/ssl:/etc/nginx/ssl \
-v /miitvip/docker/nginx/letsencrypt:/etc/nginx/letsencrypt \
-v /miitvip/web/fastdfs:/fastdfs/store \
--restart=always miitvip/nginx-php-fastdfs nginx
```

### 4. 启动 fastdfs
```
docker run -d -ti --name fastdfs \
-p 8888:8888 -p 22122:22122 -p 23000:23000 \
-e GROUP_NAME=MIIT \
-e TRACKER_SERVER=服务器IP地址 \
-v /miitvip/docker/fastdfs/tracker:/fastdfs/tracker \
-v /miitvip/docker/fastdfs/storage:/fastdfs/storage \
-v /miitvip/docker/fastdfs/client:/fastdfs/client \
-v /miitvip/docker/fastdfs/conf/tracker.conf:/etc/fdfs/tracker.conf \
-v /miitvip/docker/fastdfs/conf/storage.conf:/etc/fdfs/storage.conf \
-v /miitvip/docker/fastdfs/conf/mod_fastdfs.conf:/etc/fdfs/mod_fastdfs.conf \
-v /miitvip/docker/fastdfs/conf/client.conf:/etc/fdfs/client.conf \
-v /miitvip/docker/fastdfs/conf/http.conf:/etc/fdfs/http.conf \
-v /miitvip/web/fastdfs:/fastdfs/store \
--restart=always miitvip/nginx-php-fastdfs fastdf
```
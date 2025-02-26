# loonflow
## 介绍
对原有项目做了配置优化，使用新镜像和新的docker、docker-compose启动方式运行项目。

[原项目介绍点击查看](https://github.com/blackholll/loonflow/blob/master/README.md)

## 快速开始
安装docker、docker-compose

#### 配置信息
docker-compose如下，可按需求更换配置
```yaml
version: '3'
services:
  loonflow-redis:
    hostname: loonflow-redis
    image: redis:latest
    restart: always
    command:
      redis-server --requirepass loonflow123

  db:
    image: mysql:5.7
    container_name: myslq-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 123456  # root用户密码
      MYSQL_DATABASE: loonflow    # 默认新建数据库
      MYSQL_USER: loonflow        # 新建数据库用户名
      MYSQL_PASSWORD: 123456      # 新建用户名密码
  
  loonflow-web:
    hostname: loonflow-web
    image: silencezhao90/loonflow-platform:v2.0.0
    depends_on:
      - loonflow-redis
    ports:
      - 8001:80
    environment:
      REDIS_HOST: loonflow-redis
      REDIS_PORT: 6379    # redis端口
      REDIS_DB: 0         # redis数据库
      DB_HOST: db         # 要连接的数据库地址
      DB_NAME: loonflow   # 要链接的数据库
      DB_USER: loonflow   # 数据库用户
      DB_PASSWORD: 123456 # 数据库用户密码
      DB_PORT: 3306       # 数据库端口
    command:
      - /bin/sh
      - -c
      - |
        uwsgi /opt/loonflow/uwsgi.ini 
        nginx -c /etc/nginx/nginx.conf -g "daemon off;"

#  loonflow-task:
#    hostname: loonflow-task
#    image: silencezhao90/loonflow-platform:v2.0.0
#    command:
#      - /bin/sh
#      - -c
#      - |
#        cd /opt/loonflow
#        celery -A tasks worker -l info -c 8 -Q loonflow
```
#### 启动项目
```bash
docker-compose up -d
```

#### 初始化数据，参数对应数据库用户密码
```bash
docker exec -i myslq-db mysql -uloonflow -p123456 -h127.0.0.1 -P 3306 -D loonflow  < loonflow2.0.0_init.sql
```

#### 打开项目
localhost:8001
FROM node:14.3.0-stretch-slim as build

RUN mkdir -p /opt/loonflow
COPY . /opt/loonflow/

RUN npm config set registry https://registry.npm.taobao.org
WORKDIR /opt/loonflow/frontend
# RUN npm audit fix --package-lock-only
RUN npm install --unsafe-perm --no-fund
RUN npm run build

FROM python:3.6-slim-stretch

RUN mkdir -p /opt/loonflow
WORKDIR /opt/loonflow
COPY requirements.txt /opt/loonflow
RUN apt-get update -y && apt-get install -y gcc default-libmysqlclient-dev
RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/ --trusted-host=pypi.tuna.tsinghua.edu.cn
COPY . /opt/loonflow/
COPY --from=build /opt/loonflow/frontend/dist /opt/loonflow/frontend/dist
RUN mkdir -p /var/log/loonflow

# 安装nginx
RUN apt-get install -y nginx
# uwsgi配置文件
ADD docker_compose_deploy/loonflow-web/uwsgi.ini /opt/loonflow/uwsgi.ini
# nginx配置文件
ADD docker_compose_deploy/loonflow-web/nginx.conf /etc/nginx/nginx.conf

FROM node:6.11.0
MAINTAINER Kohei Akiyama <kheiakiyama@gmail.com>

ENV APP_VERSION v1.2.11
ENV APP_DIR /opt/crowi-plus

COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/

RUN npm install -g pm2 \
     && mkdir -p /home/LogFiles \
     && echo "root:Docker!" | chpasswd \
     && apt update \
     && apt install -y --no-install-recommends openssh-server \
     && chmod 755 /bin/init_container.sh 

EXPOSE 2222 3000

ENV PORT 3000
ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance

# download crowi-plus
RUN mkdir -p ${APP_DIR} \
    && curl -SL https://github.com/weseek/crowi-plus/archive/${APP_VERSION}.tar.gz \
        | tar -xz -C ${APP_DIR} --strip-components 1

WORKDIR ${APP_DIR}

# setup
RUN yarn global add npm@4 \
    && yarn install --production \
    && npm run build:prod \
    && yarn cache clean

VOLUME /data
CMD ["/bin/init_container.sh"]

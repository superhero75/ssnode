FROM alpine:3.8
MAINTAINER codesheng<nstop.sheng@gmail.com>

ENV MYSQL_HOST=127.0.0.1          \
    MYSQL_PORT=3306               \
    MYSQL_USER=ss                 \
    MYSQL_PASS=ss                 \
    MYSQL_DB=shadowsocks          \
    METHOD=chacha20               \
    PROTOCOL=origin               \
    OBFS=plain                    \
    API_INTERFACE=sspanelv2

RUN  apk --no-cache add \
                        curl \
                        python3-dev \
                        libsodium-dev \
                        openssl-dev \
                        udns-dev \
                        mbedtls-dev \
                        pcre-dev \
                        libev-dev \
                        libtool \
                        libffi-dev            && \
     apk --no-cache add --virtual .build-deps \
                        git \
                        tar \
                        make \
                        py3-pip \
                        autoconf \
                        automake \
                        build-base \
                        linux-headers         && \
     ln -s /usr/bin/python3 /usr/bin/python   && \
     ln -s /usr/bin/pip3    /usr/bin/pip      && \
     git clone -b manyuser https://github.com/CodeSheng/shadowsocksr.git "/root/shadowsocks" --depth 1 && \
     cd  /root/shadowsocks                    && \
     cp apiconfig.py userapiconfig.py         && \
     cp config.json user-config.json          && \
     cp mysql.json usermysql.json             && \
     pip install cymysql                      && \
     rm -rf ~/.cache && touch /etc/hosts.deny && \
     apk del --purge .build-deps

WORKDIR /root/shadowsocks

CMD sed -i "s| \"host\": \"127.0.0.1\"| \"host\": \"${MYSQL_HOST}\"|"                        /root/shadowsocks/usermysql.json && \
    sed -i "s| \"port\": 3306| \"port\": \"${MYSQL_PORT}\"|"                                 /root/shadowsocks/usermysql.json && \
    sed -i "s| \"user\": \"ss\"| \"user\": \"${MYSQL_USER}\"|"                               /root/shadowsocks/usermysql.json && \
    sed -i "s| \"password\": \"pass\"| \"password\": \"${MYSQL_PASS}\"|"                     /root/shadowsocks/usermysql.json && \
    sed -i "s| \"db\": \"sspanel\"| \"db\": \"${MYSQL_DB}\"|"                                /root/shadowsocks/usermysql.json && \
    sed -i "s| \"method\": \"aes-128-ctr\"| \"method\": \"${METHOD}\"|"                      /root/shadowsocks/user-config.json && \
    sed -i "s| \"protocol\": \"auth_aes128_md5\"| \"protocol\": \"${PROTOCOL}\"|"            /root/shadowsocks/user-config.json && \
    sed -i "s| \"obfs\": \"tls1.2_ticket_auth_compatible\"| \"obfs\": \"${OBFS}\"|"          /root/shadowsocks/user-config.json && \
    python /root/shadowsocks/server.py
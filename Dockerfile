FROM alpine
MAINTAINER MO

# Install packages
RUN apk -U upgrade && \

### Netdata full
#    apk add alpine-sdk autoconf automake bash curl gawk gcc iw jq libmnl-dev libuuid linux-headers lm_sensors make musl-dev netcat-openbsd nodejs util-linux-dev pkgconf python py-mysqldb py-psycopg2 py-requests py-yaml zlib-dev && \
### Netdata minimal    
    apk add alpine-sdk autoconf automake bash curl gawk gcc iw jq libmnl-dev libuuid linux-headers make musl-dev netcat-openbsd util-linux-dev pkgconf python py-requests py-yaml zlib-dev && \

# Install netdata
    cd /root && \
    git clone https://github.com/firehol/netdata && \
    cd netdata && \
    ./netdata-installer.sh --dont-wait --dont-start-it && \
    sed -i s/egrep/grep/ /usr/libexec/netdata/plugins.d/cgroup-name.sh && \
    sed -i "s/# host: '127.0.0.1'/host: 'elasticsearch'/" /etc/netdata/python.d/elasticsearch.conf && \
    cd / && \

# Clean up
    apk del alpine-sdk autoconf automake gcc libmnl-dev linux-headers make musl-dev pkgconf util-linux-dev zlib-dev && \
    rm -rf /root/* && \
    rm -rf /var/cache/apk/*

# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'http://127.0.0.1:19999'

# Start netdata 
WORKDIR /
CMD ["/usr/sbin/netdata","-D","-s","/host","-p","19999"]

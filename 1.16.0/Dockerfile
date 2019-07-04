FROM alpine:3.8

# Build arguments.
ARG NGINX_VERSION="1.16.0"
ARG MOD_PAGESPEED_VERSION="v1.13.35.2"

# Copy our build assets.
COPY ./build-assets/ /

# Build nginx and mod_pagespeed from source.
RUN set -xe; \
     apk add --update --no-cache --virtual .build-deps \
        apache2-dev \
        apr-dev \
        apr-util-dev \
        build-base \
        curl \
        gcc \
        gd-dev \
        geoip-dev \
        gettext-dev \
        git \
        gnupg1 \
        gperf \
        icu-dev \
        libc-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libressl-dev \
        libxslt-dev \
        linux-headers \
        make \
        pcre-dev \
        perl \
        py-setuptools \
        zlib-dev; \
    mkdir -p /usr/src; \
    cd /usr/src; \
    git clone -b ${MOD_PAGESPEED_VERSION} \
        --recursive \
        --depth=1 \
        -j$(getconf _NPROCESSORS_ONLN) \
        -c advice.detachedHead=false \
        https://github.com/apache/incubator-pagespeed-mod.git mod_pagespeed; \
    git clone -b ${MOD_PAGESPEED_VERSION}-stable \
        --recurse-submodules \
        --shallow-submodules \
        --depth=1 \
        -c advice.detachedHead=false \
        -j$(getconf _NPROCESSORS_ONLN) \
        https://github.com/apache/incubator-pagespeed-ngx.git \
        ngxpagespeed; \
    # Patch pagespeed
    cd /usr/src/mod_pagespeed; \
    for patch in /usr/src/patches/mod_pagespeed/*.patch; \
    do \
        patch -p1 < ${patch}; \
    done; \
    build/gyp_chromium --depth=. -D use_system_libs=1; \
    # Build pagespeed debug
    cd /usr/src/mod_pagespeed/pagespeed/automatic; \
    make psol BUILDTYPE=Debug \
        CFLAGS+="-I/usr/include/apr-1" \
        CXXFLAGS+="-I/usr/include/apr-1 -DUCHAR_TYPE=uint16_t" \
        -j$(getconf _NPROCESSORS_ONLN); \
    cd /usr/src/mod_pagespeed; \
    mkdir -p /usr/src/ngxpagespeed/psol/include/out/Debug; \
    mkdir -p /usr/src/ngxpagespeed/psol/lib/Debug/linux/x64; \
    cp -R out/Debug/obj /usr/src/ngxpagespeed/psol/include/out/Debug/; \
    cp -R pagespeed/automatic/pagespeed_automatic.a /usr/src/ngxpagespeed/psol/lib/Debug/linux/x64/; \
    cp -R net \
        pagespeed \
        testing \
        third_party \
        url \
        /usr/src/ngxpagespeed/psol/include/; \
    # Build pagespeed release
    cd /usr/src/mod_pagespeed/pagespeed/automatic; \
    make psol BUILDTYPE=Release \
        CFLAGS+="-I/usr/include/apr-1" \
        CXXFLAGS+="-I/usr/include/apr-1 -DUCHAR_TYPE=uint16_t" \
        -j$(getconf _NPROCESSORS_ONLN); \
    cd /usr/src/mod_pagespeed; \
    mkdir -p /usr/src/ngxpagespeed/psol/include/out/Release; \
    mkdir -p /usr/src/ngxpagespeed/psol/lib/Release/linux/x64; \
    cp -R out/Release/obj /usr/src/ngxpagespeed/psol/include/out/Release/; \
    cp -R pagespeed/automatic/pagespeed_automatic.a /usr/src/ngxpagespeed/psol/lib/Release/linux/x64/; \
    cp -R net \
        pagespeed \
        testing \
        third_party \
        url \
        /usr/src/ngxpagespeed/psol/include/; \
    # Download nginx source.
    GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8; \
    addgroup -S nginx; \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx; \
    curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz; \
    curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc; \
    export GNUPGHOME="$(mktemp -d)"; \
    found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; \
    do \
    echo "Fetching GPG key ${GPG_KEYS} from ${server}"; \
    gpg --keyserver "${server}" --keyserver-options timeout=10 --recv-keys ${GPG_KEYS} && found=yes && break; \
    done; \
    test -z "${found}" && echo >&2 "error: failed to fetch GPG key ${GPG_KEYS}" && exit 1; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz; \
    rm -rf ${GNUPGHOME} nginx.tar.gz.asc; \
    mkdir -p /usr/src; \
    tar -zxC /usr/src -f nginx.tar.gz; \
    rm nginx.tar.gz; \
    cd /usr/src/nginx-${NGINX_VERSION}; \
    # Build Nginx
    CONFIG="\
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
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --add-module=/usr/src/ngxpagespeed \
    "; \
    ./configure $CONFIG --with-debug --with-ld-opt="-Wl,-z,relro,--start-group -lapr-1 -laprutil-1 -licudata -licuuc -lpng -lturbojpeg -ljpeg"; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    mv objs/nginx objs/nginx-debug; \
    mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so; \
    mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so; \
    mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so; \
    mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so; \
    ./configure $CONFIG --with-ld-opt="-Wl,-z,relro,--start-group -lapr-1 -laprutil-1 -licudata -licuuc -lpng -lturbojpeg -ljpeg"; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install; \
    rm -rf /etc/nginx/html/; \
    mkdir /etc/nginx/conf.d/; \
    mkdir -p /usr/share/nginx/html/; \
    install -m644 html/index.html /usr/share/nginx/html/; \
    install -m644 html/50x.html /usr/share/nginx/html/; \
    install -m755 objs/nginx-debug /usr/sbin/nginx-debug; \
    install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so; \
    install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so; \
    install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so; \
    install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so; \
    ln -s ../../usr/lib/nginx/modules /etc/nginx/modules; \
    strip /usr/sbin/nginx*; \
    strip /usr/lib/nginx/modules/*.so; \
    rm -rf /usr/src/nginx-${NGINX_VERSION}; \
    rm -rf /usr/src/page_speed; \
    \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    apk add --no-cache --virtual .gettext gettext; \
    mv /usr/bin/envsubst /tmp/; \
    \
    runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --update --no-cache --virtual .nginx-rundeps tzdata $runDeps; \
    apk del .build-deps; \
    apk del .gettext; \
    mv /tmp/envsubst /usr/local/bin/; \
    # forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    rm -rf /usr/src;

# Labels / Metadata.
ARG VCS_REF
ARG BUILD_DATE
LABEL maintainer="James Brink, brink.james@gmail.com" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.decription="NGINX" \
    org.label-schema.name="nginx" \
    org.label-schema.schema-version="1.0.0-rc1" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/jamesbrink/docker-nginx" \
    org.label-schema.vendor="Utensils" \
    org.label-schema.version="${NGINX_VERSION}"

# Copy our runtime assets.
COPY ./runtime-assets /

# Expose our http ports.
EXPOSE 80

# Set the exit signal.
STOPSIGNAL SIGTERM

# Set nginx as entry command.
CMD ["nginx", "-g", "daemon off;"]

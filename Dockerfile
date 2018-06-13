FROM alpine:3.7

LABEL maintainer="Michal Cichra <michal@cichra.cz>"
ENV LUA_VERSION=5.3 LUACHECK_VERSION=0.22.0

WORKDIR /tmp
COPY Gemfile* /tmp/
RUN adduser -D -H -h /code -u 9000 -s /bin/false app \
 && apk add --no-cache luarocks${LUA_VERSION} ruby-bundler ruby-json icu-libs zlib openssl \
 && apk add --no-cache --virtual build-dependencies \
                       lua${LUA_VERSION}-dev build-base curl ruby-dev icu-dev zlib-dev openssl-dev cmake \
 && luarocks-${LUA_VERSION} install luacheck ${LUACHECK_VERSION} \
 && luarocks-${LUA_VERSION} install lua-cjson 2.1.0-1 \
 && BUNDLE_SILENCE_ROOT_WARNING=1 bundle install --system \
 && apk del build-dependencies \
 && ln -s $(which lua${LUA_VERSION}) /usr/local/bin/lua \
 && lua -e 'require("cjson").encode({})'

USER app
VOLUME /code
WORKDIR /code

COPY engine.json /
COPY bin /usr/local/bin/
COPY lib /usr/local/share/lua/${LUA_VERSION}/

CMD ["engine-luacheck"]

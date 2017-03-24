FROM alpine:3.5

LABEL maintainer "Michal Cichra <michal@cichra.cz>"
ENV LUA_VERSION=5.3 LUACHECK_VERSION=0.19.1

WORKDIR /tmp
COPY Gemfile* /tmp/
RUN adduser -D -H -h /code -u 9000 -s /bin/false app \
 && apk add --no-cache luarocks${LUA_VERSION} ruby-bundler ruby-json icu-libs zlib \
                       lua${LUA_VERSION}-dev build-base curl ruby-dev icu-dev zlib-dev cmake \
 && luarocks-${LUA_VERSION} install luacheck ${LUACHECK_VERSION} \
 && luarocks-${LUA_VERSION} install lua-cjson \
 && BUNDLE_SILENCE_ROOT_WARNING=1 bundle install --system \
 && apk del build-base curl lua${LUA_VERSION}-dev ruby-dev zlib-dev icu-dev cmake \
 && ln -s $(which lua${LUA_VERSION}) /usr/local/bin/lua

USER app
VOLUME /code
WORKDIR /code

COPY engine.json /
COPY bin /usr/local/bin/
COPY lib /usr/local/share/lua/${LUA_VERSION}/

CMD ["engine-luacheck"]

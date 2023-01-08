#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM ghcr.io/graalvm/graalvm-ce:ol9-java17-22.3.0 AS build

# install musl-libc and zlib
# TODO need to pin version - fetch https://musl.libc.org/releases/musl-1.2.2.tar.gz and build it, install binutils, gmp, mpfr, mpc
ENV ARCH=x86_64
ENV TOOLCHAIN_DIR=/$ARCH-linux-musl-native
ENV CC=$TOOLCHAIN_DIR/bin/gcc
ENV PATH=$PATH:$TOOLCHAIN_DIR/bin
ENV ZLIB_VERSION=1.2.13
WORKDIR /
# TODO or https://musl.cc/$ARCH-linux-musl-native.tgz when https://github.com/oracle/graal/issues/4076 is done
RUN curl -kfLOsS https://more.musl.cc/10.2.1/x86_64-linux-musl/x86_64-linux-musl-native.tgz && \
    tar xf $ARCH-linux-musl-native.tgz && \
    curl -fLOsS https://zlib.net/zlib-$ZLIB_VERSION.tar.gz && \
    tar xf zlib-$ZLIB_VERSION.tar.gz && \
    cd zlib-$ZLIB_VERSION && \
    ./configure --prefix=$TOOLCHAIN_DIR --static && \
    make && \
    make install && \
    gu install native-image && \
    mkdir -p /tmp/empty && \
    touch /tmp/.trino_history

ARG LB_VERSION
COPY target/lone-bunny-${LB_VERSION}-shaded.jar /
RUN native-image \
      --static \
      --libc=musl \
      --no-fallback \
      -H:+AddAllCharsets \
      -Djdk.lang.Process.launchMechanism=vfork \
      -jar lone-bunny-${LB_VERSION}-shaded.jar

FROM alpine:3

RUN apk add less
COPY src/main/resources/passwd /etc/passwd
COPY --from=build --chown=trino /tmp/empty /tmp
COPY --from=build --chown=trino /tmp/.trino_history /

ARG LB_VERSION
COPY --from=build lone-bunny-${LB_VERSION}-shaded /usr/bin/lone-bunny

USER trino
ENV LANG en_US.UTF-8
ENTRYPOINT ["/usr/bin/lone-bunny"]

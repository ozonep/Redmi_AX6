FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Moscow

RUN rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc && apt update -y && apt upgrade -y && \
    apt install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync tzdata
RUN useradd -ms /bin/bash newuser
RUN useradd -rm -d /workdir/openwrt -s /bin/bash -u 1001 newuser
RUN mkdir -p /workdir && chown newuser /workdir
WORKDIR /workdir
USER newuser
RUN git clone https://github.com/coolsnowwolf/lede --depth 1 openwrt && \
    git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom --depth 1 openwrt/package/luci-theme-infinityfreedom && \
    git clone https://github.com/sirpdboy/luci-theme-opentopd --depth 1 openwrt/package/luci-theme-opentopd
WORKDIR /workdir/openwrt
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
COPY new.config ./.config
COPY addfwhdr.c tools/firmware-utils/src/addfwhdr.c
RUN sed -i 's/192.168.1.1/192.168.10.1/g' ./package/base-files/files/bin/config_generate
RUN make -j8 download V=s
RUN echo -e "compile" && \
    make -j1 V=s && \
    echo "::set-output name=status::success"


# FROM alpine:3 AS builder

# ENV TZ Europe/Moscow

# RUN apk add --no-cache asciidoc bash bc binutils bzip2 cdrkit coreutils diffutils findutils flex g++ gawk gcc gettext git grep intltool \
#     libxslt linux-headers make ncurses-dev openssl-dev patch perl python2-dev python3-dev rsync tar unzip util-linux wget zlib-dev tzdata
# RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# RUN addgroup -S -g 1000 openwrt && \
#     adduser -S -H -D -h /workdir/openwrt -s /bin/bash -u 1000 -G openwrt openwrt

# RUN mkdir -p /workdir && chown openwrt:openwrt /workdir
# WORKDIR /workdir
# USER 1000:1000
# RUN git clone https://github.com/coolsnowwolf/lede --depth 1 openwrt && \
#     git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom --depth 1 openwrt/package/luci-theme-infinityfreedom && \
#     git clone https://github.com/sirpdboy/luci-theme-opentopd --depth 1 openwrt/package/luci-theme-opentopd
# WORKDIR /workdir/openwrt
# RUN ./scripts/feeds update -a && ./scripts/feeds install -a
# COPY new.config ./.config
# COPY addfwhdr.c tools/firmware-utils/src/addfwhdr.c
# RUN sed -i 's/192.168.1.1/192.168.10.1/g' ./package/base-files/files/bin/config_generate
# RUN make -j8 download V=s
# RUN echo -e "compile" && \
#     make -j1 V=s && \
#     echo "::set-output name=status::success"


# FROM ubuntu:latest
# COPY --from=builder /workdir/openwrt/bin /openwrt
FROM ubuntu:latest AS builder

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV TZ Europe/Moscow

RUN rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc && apt update -y && apt upgrade -y && \
    apt install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev subversion flex uglifyjs git-core p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler antlr3 gperf wget curl swig rsync tzdata \ 
    libc6-dev libgcc1 gcc g++ && \
    apt autoremove -y
RUN useradd -rm -d /workdir -s /bin/bash -u 1001 newuser
RUN mkdir -p /workdir && chown newuser /workdir
WORKDIR /workdir
USER newuser
RUN git clone https://github.com/coolsnowwolf/lede --depth 1 openwrt
WORKDIR /workdir/openwrt
USER root
RUN rm -rf ./package/lean/luci-theme-argon && rm ./feeds.conf.default
COPY --chown=newuser patches/. ./
COPY --chown=newuser luci-theme-atmaterial_new/. ./package/lean/luci-theme-atmaterial_new/.
COPY --chown=newuser luci-theme-opentopd/. ./package/lean/luci-theme-opentopd/.
COPY --chown=newuser feeds.conf.default ./feeds.conf.default
COPY --chown=newuser new.config ./.config
RUN chmod +x ./.config && chmod +x ./feeds.conf.default
USER newuser
RUN git apply 7791.patch && git apply 7805.patch && rm 7791.patch 7805.patch
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
COPY --chown=newuser nextdns.config ./feeds/packages/net/nextdns/files/nextdns.config
RUN sed -i 's/192.168.1.1/192.168.31.1/g' ./package/base-files/files/bin/config_generate
RUN sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' ./package/base-files/files/etc/sysctl.conf
RUN make defconfig && make -j8 download V=s
RUN echo -e "compiling" && \
    make -j1 V=s && \
    echo "::set-output name=status::success"


FROM ubuntu:latest
COPY --from=builder /workdir/openwrt/bin /openwrt
FROM ubuntu:latest AS builder

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TZ Europe/Moscow

RUN rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc && apt update -y && apt upgrade -y && \
    apt install -y build-essential locales locales-all asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev subversion flex uglifyjs git-core p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler antlr3 gperf wget curl swig rsync tzdata \ 
    libc6-dev libgcc1 gcc g++ && \
    apt autoremove -y
RUN useradd -rm -d /workdir -s /bin/bash -u 1001 newuser
RUN mkdir -p /workdir && chown newuser /workdir
WORKDIR /workdir
USER newuser
RUN git clone https://github.com/Boos4721/openwrt --depth 1 openwrt
WORKDIR /workdir/openwrt
USER root
COPY --chown=newuser mymin.config ./.config
COPY --chown=newuser feeds.conf.default ./feeds.conf.default
COPY --chown=newuser mac80211.sh ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
USER newuser
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
COPY --chown=newuser Makefile feeds/packages/net/nextdns/Makefile
COPY --chown=newuser nextdns.config feeds/packages/net/nextdns/files/nextdns.config
RUN sed -i 's/10.10.10.1/192.168.30.1/g' package/base-files/files/bin/config_generate
RUN sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf
# RUN sed -i 's/OpenWrt_2.4G/OpenWrt_5G/g'  package/kernel/mac80211/files/lib/wifi/mac80211.sh
# RUN sed -i '185s/OpenWrt_5G/OpenWrt_2.4G/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
RUN make defconfig && make -j4 download
RUN echo -e "compiling" && \
    make -j4 && \
    echo "::set-output name=status::success"


FROM ubuntu:latest
COPY --from=builder /workdir/openwrt/bin /openwrt
COPY --from=builder /workdir/openwrt/.config /openwrt/.config
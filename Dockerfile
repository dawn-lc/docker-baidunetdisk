FROM jlesage/baseimage-gui:debian-12-v4.9.0

ENV APP_NAME="Baidunetdisk" \
HOME=/config \
TZ=Asia/Shanghai \
LC_ALL=C \
LANG=C.UTF-8 \
ENABLE_CJK_FONT=1 \
NOVNC_LANGUAGE="zh_Hans" \
WEB_AUDIO=1

COPY startapp.sh /startapp.sh

RUN set -ex \
&& chmod +x /startapp.sh \
&& sed -i 's@<decor>no</decor>@<decor>yes</decor>@g' /opt/base/etc/openbox/rc.xml.template \
&& sed -i 's@deb.debian.org@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list.d/debian.sources \
&& sed -i 's@security.debian.org@mirrors.tuna.tsinghua.edu.cn/debian-security@g' /etc/apt/sources.list.d/debian.sources \
&& apt-get update \
&& apt-get install -y curl jq \
xdg-utils procps pciutils desktop-file-utils libgtk-3-0 \
libnss3 libxss1 libasound2 libgbm1 \
libnotify4 libsecret-1-0 libsecret-common \
libdbusmenu-glib4 libdbusmenu-gtk3-4 \
libayatana-indicator3-7 libayatana-appindicator3-1 libayatana-ido3-0.4-0

RUN set -ex \
&& arch=$(uname -m); case "$arch" in x86_64) arch=amd64;; i386|i686) arch=i386;; aarch64) arch=arm64;; armv7l) arch=armhf;; armv6l) arch=armel;; riscv64) arch=riscv64;; ppc64le) arch=ppc64el;; s390x) arch=s390x;; loongarch64) arch=loong64;; *) arch=unknown;; esac \
&& curl -fsSL $(curl -fsSL 'https://pan.baidu.com/disk/cmsdata?do=client' -H 'Accept: application/json' | jq -r '.linux.url_1' | sed -E "s/_[^_]+\.deb$/_${arch}.deb/") -o baidunetdisk.deb \
&& dpkg -i baidunetdisk.deb || apt-get -f install -y \
&& rm -f baidunetdisk.deb \
&& apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
&& sed -i '/messagebus/d' /var/lib/dpkg/statoverride || true
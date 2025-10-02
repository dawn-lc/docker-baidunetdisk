git clone https://github.com/dawn-lc/docker-baidunetdisk
cd docker-baidunetdisk
docker build -t baidunetdisk:latest .
docker run baidunetdisk:latest \
 --name baidunetdisk \
 --device /dev/dri:/dev/dri \
 --shm-size=512m \
 -p 5800:5800 \
 -p 5900:5900 \
 -v /etc/baidunetdisk:/config \
 -v /downloads:/config/baidunetdiskdownload

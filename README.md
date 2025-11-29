# 开箱即用的百度网盘docker封装

命令行执行
```
git clone https://github.com/dawn-lc/docker-baidunetdisk
cd docker-baidunetdisk
docker build -t baidunetdisk:latest .
mkdir /etc/baidunetdisk
mkdir /downloads
docker run baidunetdisk:latest \
 --name baidunetdisk \
 -p 5800:5800 \
 -p 5900:5900 \
 -v /etc/baidunetdisk:/config \
 -v /downloads:/config/baidunetdiskdownload
```

浏览器打开
```
http://您的设备IP:5800/
```

Enjoy!

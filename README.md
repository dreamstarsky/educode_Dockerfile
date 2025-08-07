# about

An image that starts both sshd and code-server, using s6-overlay.

# usage

Ports: 
- 8080 -> code-server 
- 22 -> sshd

Change default code-server workspace：
```sh
# defalut:
CODE_WORKDIR=/home/ubuntu
```

# build

```sh
podman build -f Dockerfile .
```

or build with some mirrors.
```sh
podman build -f Dockerfile . \
    --build-arg UBUNTU_MIRROR=http://mirrors.aliyun.com/ubuntu \
    --build-arg UBUNTU_SECURITY_MIRROR=http://mirrors.aliyun.com/ubuntu \
    --build-arg MINICONDA_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
```

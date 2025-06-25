# about

一个同时启动了sshd和code-server（以ubuntu用户身份）的镜像，使用s6-overlay

# usage

code-server web 页面开放在8080端口，sshd在22端口

可以通过环境变量改变code-server默认路径：
```sh
# defalut:
CODE_WORKDIR=/home/ubuntu
```

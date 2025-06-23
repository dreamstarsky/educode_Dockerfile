# 注意事项



构建时记得注释一下这一行
```Dockerfile
# for faster download
RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142";' > /etc/apt/apt.conf.d/01proxy
```

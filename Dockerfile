# 使用官方 Golang 镜像作为构建环境
FROM golang:1.26-alpine AS builder

# 设置工作目录
WORKDIR /app

# 设置 Go 代理（加速依赖下载）
ENV GOPROXY=https://goproxy.cn,direct

# 复制 go.mod 和 go.sum
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o command-code-proxy .

# 使用轻量级镜像运行
FROM alpine:latest

# 安装 ca-certificates（用于 HTTPS 请求）
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# 从构建阶段复制可执行文件
COPY --from=builder /app/command-code-proxy .

# 暴露端口
EXPOSE 55990

# 运行应用
ENTRYPOINT ["./command-code-proxy"]

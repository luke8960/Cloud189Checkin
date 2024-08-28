FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build
ARG TARGETARCH
RUN arch=$TARGETARCH \
    && if [ "$TARGETARCH" = "amd64" ]; then arch="x64"; fi \
    && echo $arch > /tmp/arch

WORKDIR /src
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY . .

RUN bash aot.sh
RUN find /app -name "*.pdb"  | xargs rm -f
RUN find /app -name "*.dbg"  | xargs rm -f
RUN rm -f /app/appsettings.Development.json
RUN rm -f /app/Cloud189Checkin.xml

#移除 OSX Windows 下的库
RUN rm -rf /app/runtimes/osx* /app/runtimes/win* /app/runtimes/*x86 /app/runtimes/linux-armel /app/runtimes/unix

FROM --platform=$TARGETPLATFORM mcr.microsoft.com/dotnet/runtime-deps:8.0 AS final
ARG TARGETARCH
RUN arch=$TARGETARCH \
    && if [ "$TARGETARCH" = "amd64" ]; then arch="x64"; fi \
    && echo $arch > /tmp/arch
RUN echo $arch $ $TARGETARCH
WORKDIR /app
EXPOSE 80
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=build /app .

#指定IPv4优先
RUN echo precedence ::ffff:0:0/96 100 >> /etc/gai.conf

ENTRYPOINT ["./Cloud189Checkin"]

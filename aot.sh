sed -i s@/deb.debian.org/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list && \
sed -i s@/snapshot.debian.org/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list && \
sed -i s@/security.debian.org/@/mirrors.ustc.edu.cn/@g /etc/apt/sources.list && \
sed -i s/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
sed -i s/ports.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list

apt-get update -y || true
apt-get install clang zlib1g-dev -y

if [ "$TARGETARCH" = "arm64" ]; then
  . /etc/os-release
  apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu libc6-dev-arm64-cross -y 
  dpkg --add-architecture arm64 
  echo deb [arch=arm64] https://mirrors.ustc.edu.cn/ubuntu-ports/ $VERSION_CODENAME main restricted >> /etc/apt/sources.list.d/arm64.list
  echo deb [arch=arm64] https://mirrors.ustc.edu.cn/ubuntu-ports/ $VERSION_CODENAME-updates main restricted  >> /etc/apt/sources.list.d/arm64.list
  echo deb [arch=arm64] https://mirrors.ustc.edu.cn/ubuntu-ports/ $VERSION_CODENAME-backports main restricted universe multiverse >> /etc/apt/sources.list.d/arm64.list
  apt-get update -y || true 
  apt-get install zlib1g-dev:arm64 -y
fi;

dotnet restore Cloud189Checkin/Cloud189Checkin.csproj -s https://nuget.cdn.azure.cn/v3/index.json -a $TARGETARCH

if [ "$TARGETARCH" = "arm64" ]; then 
    export OBJCOPY=aarch64-linux-gnu-objcopy
else
    export OBJCOPY=objcopy 
fi;

dotnet publish Cloud189Checkin/Cloud189Checkin.csproj -c Release -a $TARGETARCH -o /app -p:ObjCopyName=$OBJCOPY -p:ShouldUnsetParentConfigurationAndPlatform=false -nowarn:cs0168,cs0105